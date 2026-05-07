-- 마이그레이션 006:
--   members_public 뷰에 phone 컬럼 노출
--   사용자 요청: "공개해도 상관없어"
-- Supabase 대시보드 → SQL Editor → New query → 이 파일 통째로 복사 → RUN

drop view if exists members_public;
create view members_public as
  select id, name, phone, joined, created_at from members;
grant select on members_public to anon, authenticated;
