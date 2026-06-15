-- 마이그레이션 010:
--   팀원 부상 상태 (회비 이월)
--   - members.is_injured boolean 추가 (기본 false)
--   - members_public 뷰에 is_injured 노출
--   - set_injured(p_id, p_is_injured) RPC
-- 부상 처리된 멤버는 프론트에서 미납/납부 목록에서 제외, "부상 이월" 섹션으로 분리됨
-- Supabase 대시보드 → SQL Editor → New query → 이 파일 통째로 복사 → RUN

-- =========================================
-- 1. is_injured 컬럼 추가
-- =========================================
alter table members add column if not exists is_injured boolean not null default false;

-- =========================================
-- 2. members_public 뷰 갱신 (is_injured 포함)
-- =========================================
drop view if exists members_public;
create view members_public as
  select id, name, phone, joined, is_candidate, is_injured,
         dominant_foot, skill_level, preferred_positions,
         created_at
  from members;
grant select on members_public to anon, authenticated;

-- =========================================
-- 3. set_injured: 부상 ↔ 정상 토글
-- =========================================
create or replace function set_injured(p_id uuid, p_is_injured boolean)
returns void
language plpgsql
security definer
set search_path = public
as $SET_INJ$
begin
  update members set is_injured = p_is_injured where id = p_id;
end;
$SET_INJ$;
grant execute on function set_injured(uuid, boolean) to anon, authenticated;
