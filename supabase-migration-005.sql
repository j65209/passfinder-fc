-- 마이그레이션 005:
--   핸드폰 번호 편집거리(Levenshtein) ≤ 2면 같은 사람으로 처리 (오타 보정)
--   = "틀린 자릿수가 2자 이하면 동일인". 3자 이상 다르면 신규.
--   예) "01012345678" vs "01012345677" → 거리 1 → 동일인
--       "01012345678" vs "0112345678"  → 거리 1 → 동일인 (한 자리 누락)
--       "01012345678" vs "01012340000" → 거리 4 → 신규
--       "01012345678" vs "01098765432" → 거리 7 → 신규
-- Supabase 대시보드 → SQL Editor → New query → 이 파일 통째로 복사 → RUN
--
-- ※ 주의: 같은 국번/통신사라 한두 자리만 다른 다른 사람이 들어오면 같은 계정으로
--   합쳐질 수 있음. 잘못 합쳐진 경우 운영자 PIN으로 삭제 후 재가입 안내.

-- =========================================
-- 1. fuzzystrmatch 확장 활성화 (levenshtein 함수 제공)
-- =========================================
create extension if not exists fuzzystrmatch;

-- =========================================
-- 2. signup_member 갱신
--    1) phone 정확히 일치 → 그 ID 반환
--    2) levenshtein 거리가 가장 작은 회원의 거리가 2 이하 → 그 ID 반환 (이름 무시)
--    3) 둘 다 아니면 신규 INSERT
-- =========================================
create or replace function signup_member(p_name text, p_phone text)
returns uuid
language plpgsql
security definer
set search_path = public
as $SIGNUP$
declare
  v_id uuid;
  v_dist int;
begin
  -- 1. 정확히 일치
  select id into v_id from members where phone = p_phone;
  if v_id is not null then return v_id; end if;

  -- 2. 가장 비슷한 회원과의 편집거리 확인
  select id, levenshtein(phone, p_phone)
    into v_id, v_dist
  from members
  order by levenshtein(phone, p_phone) asc
  limit 1;

  if v_dist is not null and v_dist <= 2 then
    return v_id;
  end if;

  -- 3. 신규 가입
  insert into members (name, phone, joined) values (p_name, p_phone, current_date)
  returning id into v_id;
  return v_id;
end;
$SIGNUP$;
grant execute on function signup_member(text, text) to anon, authenticated;
