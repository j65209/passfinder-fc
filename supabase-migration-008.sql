-- 마이그레이션 008:
--   매경기 용병(guest) 도입
--   - match_guests 테이블 신설 (경기별 일회성 참가자)
--   - RLS는 attendance와 동일 패턴: anon read/insert/update/delete 모두 허용
--     (프론트는 로그인된 모든 사용자가 추가/수정/삭제 가능)
--   - 팀짜기 풀에는 g:<guest_id> 문자열로 합류 → renderChip에서 분기 처리
-- Supabase 대시보드 → SQL Editor → New query → 이 파일 통째로 복사 → RUN

-- =========================================
-- 1. 테이블
-- =========================================
create table if not exists match_guests (
  id uuid primary key default gen_random_uuid(),
  match_id uuid not null references matches(id) on delete cascade,
  name text not null,
  added_by_member_id uuid references members(id) on delete set null,
  added_by_name text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create index if not exists match_guests_match_id_idx on match_guests(match_id);

-- =========================================
-- 2. RLS
-- =========================================
alter table match_guests enable row level security;

drop policy if exists "Public read match_guests" on match_guests;
create policy "Public read match_guests" on match_guests
  for select using (true);

drop policy if exists "Public insert match_guests" on match_guests;
create policy "Public insert match_guests" on match_guests
  for insert to anon, authenticated with check (true);

drop policy if exists "Public update match_guests" on match_guests;
create policy "Public update match_guests" on match_guests
  for update to anon, authenticated using (true) with check (true);

drop policy if exists "Public delete match_guests" on match_guests;
create policy "Public delete match_guests" on match_guests
  for delete to anon, authenticated using (true);
