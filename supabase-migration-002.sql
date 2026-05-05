-- 마이그레이션 002: phone_last4 → phone, signup_member 함수 추가
-- Supabase 대시보드 → SQL Editor → New query → 이 파일 통째로 복사 → RUN

-- ⚠️ 주의: 기존 테스트 멤버 3명(김재호/유태형/권필승) 삭제됨

-- 0. 기존 테스트 데이터 삭제
delete from members;

-- 1. 뷰 삭제 (컬럼명 의존)
drop view if exists members_public;

-- 2. 컬럼명 변경
alter table members rename column phone_last4 to phone;

-- 3. 4자리 제약 → 4~15자리 (전체 전화번호 가능)
alter table members drop constraint if exists members_phone_last4_check;
alter table members add constraint members_phone_check check (phone ~ '^[0-9]{4,15}$');

-- 4. 뷰 재생성
create view members_public as
  select id, name, joined, created_at from members;
grant select on members_public to anon, authenticated;

-- 5. login_member 함수 업데이트
drop function if exists login_member(text, text);
create or replace function login_member(p_name text, p_phone text)
returns uuid
language plpgsql
security definer
set search_path = public
as $LOGIN$
declare v_id uuid;
begin
  select id into v_id from members where name = p_name and phone = p_phone;
  return v_id;
end;
$LOGIN$;
grant execute on function login_member(text, text) to anon, authenticated;

-- 6. signup_member 함수 추가 (회원가입 + 로그인 통합)
--    같은 이름+연락처면 기존 ID 반환, 없으면 새로 INSERT
create or replace function signup_member(p_name text, p_phone text)
returns uuid
language plpgsql
security definer
set search_path = public
as $SIGNUP$
declare v_id uuid;
begin
  select id into v_id from members where name = p_name and phone = p_phone;
  if v_id is not null then return v_id; end if;

  insert into members (name, phone, joined) values (p_name, p_phone, current_date)
  returning id into v_id;
  return v_id;
end;
$SIGNUP$;
grant execute on function signup_member(text, text) to anon, authenticated;
