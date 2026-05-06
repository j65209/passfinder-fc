-- 마이그레이션 003: 팀 자동 분할 (경기 시작 20분 전 자동 공개)
-- Supabase 대시보드 → SQL Editor → New query → 이 파일 통째로 복사 → RUN

-- 1. matches 테이블에 teams 컬럼 추가
alter table matches add column if not exists teams jsonb;

-- teams 구조 (jsonb):
-- null = 아직 생성 안 됨
-- {
--   "teams": [["member_id", ...], ["member_id", ...], ...],  -- 6명씩 분할된 팀들
--   "bench": ["member_id", ...],                              -- 1~3명일 때 교체 대기
--   "shuffled_at": "2026-05-06T19:40:00.000Z",
--   "shuffle_count": 1
-- }

-- 2. RLS 정책 — 누구나 update 가능 (PIN 게이트는 프론트엔드에서 처리)
--    기존 패턴(attendance와 동일): public read + public write, admin은 PIN 인증으로 프론트에서 분기
drop policy if exists "Public update matches" on matches;
create policy "Public update matches" on matches
  for update to anon, authenticated using (true) with check (true);
