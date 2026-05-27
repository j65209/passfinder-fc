-- 마이그레이션 009:
--   팀원 프로필 (주발 / 레벨 / 선호 포지션)
--   - dominant_foot text  (right|left|both)
--   - skill_level text    (beginner|intermediate|advanced)
--   - preferred_positions text[] (gk|def|fwd 의 부분집합, 중복 선택)
--   - update_member_profile RPC: 로그인된 누구나(뷰어 포함) 수정 가능 (SECURITY DEFINER)
-- Supabase 대시보드 → SQL Editor → New query → 이 파일 통째로 복사 → RUN

-- =========================================
-- 1. 컬럼 추가
-- =========================================
alter table members add column if not exists dominant_foot text
  check (dominant_foot is null or dominant_foot in ('right', 'left', 'both'));
alter table members add column if not exists skill_level text
  check (skill_level is null or skill_level in ('beginner', 'intermediate', 'advanced'));
alter table members add column if not exists preferred_positions text[];

-- =========================================
-- 2. members_public 뷰 갱신 — 새 컬럼 노출
-- =========================================
drop view if exists members_public;
create view members_public as
  select id, name, phone, joined, is_candidate,
         dominant_foot, skill_level, preferred_positions,
         created_at
  from members;
grant select on members_public to anon, authenticated;

-- =========================================
-- 3. update_member_profile RPC
--    누구나 호출 가능 → 프론트는 로그인된 사용자만 노출
-- =========================================
create or replace function update_member_profile(
  p_id uuid,
  p_foot text,
  p_level text,
  p_positions text[]
) returns void
language plpgsql
security definer
set search_path = public
as $UMP$
declare
  v_pos text;
begin
  if p_foot is not null and p_foot not in ('right','left','both') then
    raise exception 'invalid foot value: %', p_foot;
  end if;
  if p_level is not null and p_level not in ('beginner','intermediate','advanced') then
    raise exception 'invalid level value: %', p_level;
  end if;
  if p_positions is not null then
    foreach v_pos in array p_positions loop
      if v_pos not in ('gk','def','fwd') then
        raise exception 'invalid position value: %', v_pos;
      end if;
    end loop;
  end if;

  update members
  set dominant_foot = p_foot,
      skill_level = p_level,
      preferred_positions = p_positions
  where id = p_id;
end;
$UMP$;
grant execute on function update_member_profile(uuid, text, text, text[]) to anon, authenticated;
