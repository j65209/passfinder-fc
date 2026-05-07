-- 마이그레이션 007:
--   팀원 후보(유령회원) 도입
--   - members.is_candidate 플래그 추가 (기본 false)
--   - members_public 뷰에 is_candidate 노출
--   - add_candidate / set_candidate RPC (운영자 PIN 게이트는 프론트)
-- 후보는 프론트에서 state.candidates로 분리 → 참석/회비/팀짜기 로직에서 자동 제외됨
-- Supabase 대시보드 → SQL Editor → New query → 이 파일 통째로 복사 → RUN

-- =========================================
-- 1. is_candidate 컬럼 추가
-- =========================================
alter table members add column if not exists is_candidate boolean not null default false;

-- =========================================
-- 2. members_public 뷰 갱신 (is_candidate 포함)
-- =========================================
drop view if exists members_public;
create view members_public as
  select id, name, phone, joined, is_candidate, created_at from members;
grant select on members_public to anon, authenticated;

-- =========================================
-- 3. add_candidate: 후보로 신규 등록
--    - 같은 phone 있으면 그 ID 반환 (정식이든 후보든 중복 방지)
-- =========================================
create or replace function add_candidate(p_name text, p_phone text)
returns uuid
language plpgsql
security definer
set search_path = public
as $ADD_CAND$
declare v_id uuid;
begin
  select id into v_id from members where phone = p_phone;
  if v_id is not null then return v_id; end if;

  insert into members (name, phone, joined, is_candidate)
  values (p_name, p_phone, current_date, true)
  returning id into v_id;
  return v_id;
end;
$ADD_CAND$;
grant execute on function add_candidate(text, text) to anon, authenticated;

-- =========================================
-- 4. set_candidate: 후보 ↔ 정식 토글
--    승격(false) / 강등(true)
-- =========================================
create or replace function set_candidate(p_id uuid, p_is_candidate boolean)
returns void
language plpgsql
security definer
set search_path = public
as $SET_CAND$
begin
  update members set is_candidate = p_is_candidate where id = p_id;
end;
$SET_CAND$;
grant execute on function set_candidate(uuid, boolean) to anon, authenticated;
