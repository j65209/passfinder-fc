-- 마이그레이션 004:
--   1) phone 기준 중복 방지 (unique 제약)
--   2) signup_member: phone만으로 매칭 (이름 오타로 새로 가입되는 문제 해결)
--   3) delete_member: 운영자(anon, PIN 게이트는 프론트) 삭제 가능하도록 SECURITY DEFINER RPC
-- Supabase 대시보드 → SQL Editor → New query → 이 파일 통째로 복사 → RUN

-- =========================================
-- 0. 기존 phone 중복 정리 (가장 오래된 1개만 남기고 삭제)
--    NOTE: cascade로 attendance/payments 같이 사라짐
-- =========================================
delete from members m
using (
  select phone, min(created_at) as keep_at
  from members
  group by phone
  having count(*) > 1
) dup
where m.phone = dup.phone and m.created_at <> dup.keep_at;

-- =========================================
-- 1. phone unique 제약 추가
-- =========================================
alter table members drop constraint if exists members_phone_unique;
alter table members add constraint members_phone_unique unique (phone);

-- =========================================
-- 2. signup_member: phone 단일 키로 매칭
--    - 같은 phone이 있으면 → 이름이 달라도(오타여도) 그 ID 반환
--    - 없으면 → 새로 INSERT (입력한 이름으로 가입)
-- =========================================
create or replace function signup_member(p_name text, p_phone text)
returns uuid
language plpgsql
security definer
set search_path = public
as $SIGNUP$
declare v_id uuid;
begin
  select id into v_id from members where phone = p_phone;
  if v_id is not null then return v_id; end if;

  insert into members (name, phone, joined) values (p_name, p_phone, current_date)
  returning id into v_id;
  return v_id;
end;
$SIGNUP$;
grant execute on function signup_member(text, text) to anon, authenticated;

-- =========================================
-- 3. delete_member RPC
--    프론트에서 PIN으로 운영자 인증 → anon 키로 호출 → SECURITY DEFINER로 RLS 우회
--    ※ attendance/payments는 ON DELETE CASCADE라 같이 정리됨
-- =========================================
create or replace function delete_member(p_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $DELETE_MEMBER$
begin
  delete from members where id = p_id;
end;
$DELETE_MEMBER$;
grant execute on function delete_member(uuid) to anon, authenticated;
