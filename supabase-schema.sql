-- 패스파인더 FC Supabase 스키마
-- Supabase 대시보드 → SQL Editor → New query → 이 파일 통째로 복사 → RUN

-- =========================
-- 1. 테이블
-- =========================

create table if not exists members (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  phone_last4 text not null check (phone_last4 ~ '^[0-9]{4}$'),
  position text not null check (position in ('GK', 'DF', 'MF', 'FW')),
  joined date default current_date,
  created_at timestamptz default now()
);

create table if not exists matches (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  match_date date not null,
  match_time time,
  location text,
  created_at timestamptz default now()
);

create table if not exists attendance (
  match_id uuid references matches(id) on delete cascade,
  member_id uuid references members(id) on delete cascade,
  vote text check (vote in ('yes', 'no', 'maybe')),
  updated_at timestamptz default now(),
  primary key (match_id, member_id)
);

create table if not exists payments (
  id uuid primary key default gen_random_uuid(),
  member_id uuid references members(id) on delete cascade,
  month text not null,
  amount integer not null default 30000,
  method text check (method in ('toss', 'kakao', 'cash', 'transfer')),
  paid_at timestamptz,
  tx_id text,
  unique (member_id, month)
);

create table if not exists app_config (
  key text primary key,
  value text not null,
  updated_at timestamptz default now()
);

insert into app_config (key, value) values
  ('monthly_fee', '30000'),
  ('current_month', to_char(current_date, 'YYYY-MM'))
on conflict (key) do nothing;

-- =========================
-- 2. RLS 활성화
-- =========================

alter table members enable row level security;
alter table matches enable row level security;
alter table attendance enable row level security;
alter table payments enable row level security;
alter table app_config enable row level security;

-- =========================
-- 3. 공개 뷰 (전화번호 제외)
-- =========================

create or replace view members_public as
  select id, name, position, joined, created_at from members;

grant select on members_public to anon, authenticated;

-- =========================
-- 4. 멤버 로그인 RPC 함수
--    이름 + 전화 뒷4자리 → 일치하면 member_id 반환
--    SECURITY DEFINER → RLS 우회해서 검증 가능
-- =========================

create or replace function login_member(p_name text, p_phone text)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_id uuid;
begin
  select id into v_id
  from members
  where name = p_name and phone_last4 = p_phone;
  return v_id;
end;
$$;

grant execute on function login_member(text, text) to anon, authenticated;

-- =========================
-- 5. RLS 정책
-- =========================

-- members: anon은 직접 SELECT 불가 (뷰만 사용), authenticated(=운영자)는 모든 권한
create policy "Admin full access members" on members
  for all to authenticated using (true) with check (true);

-- matches: anon read, admin all
create policy "Public read matches" on matches for select using (true);
create policy "Admin write matches" on matches
  for all to authenticated using (true) with check (true);

-- attendance: anon read + write (프론트가 본인만 수정하도록 제어), admin all
create policy "Public read attendance" on attendance for select using (true);
create policy "Public upsert attendance" on attendance
  for insert to anon, authenticated with check (true);
create policy "Public update attendance" on attendance
  for update to anon, authenticated using (true);
create policy "Admin delete attendance" on attendance
  for delete to authenticated using (true);

-- payments: anon read, admin write
create policy "Public read payments" on payments for select using (true);
create policy "Admin write payments" on payments
  for all to authenticated using (true) with check (true);

-- app_config: anon read, admin write
create policy "Public read config" on app_config for select using (true);
create policy "Admin write config" on app_config
  for all to authenticated using (true) with check (true);
