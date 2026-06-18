-- 마이그레이션 011:
--   운영자가 팀원명을 수정할 수 있도록 update_member_name RPC 추가
--   - 프론트엔드 PIN 게이트로 운영자만 사용 (다른 RPC와 동일한 방식)
-- Supabase 대시보드 → SQL Editor → New query → 이 파일 통째로 복사 → RUN

create or replace function update_member_name(p_id uuid, p_name text)
returns void
language plpgsql
security definer
set search_path = public
as $UMN$
declare
  v_name text := trim(coalesce(p_name, ''));
begin
  if length(v_name) = 0 then
    raise exception '이름이 비어있어요';
  end if;
  if length(v_name) > 30 then
    raise exception '이름은 30자 이내로 입력하세요';
  end if;
  update members set name = v_name where id = p_id;
end;
$UMN$;
grant execute on function update_member_name(uuid, text) to anon, authenticated;
