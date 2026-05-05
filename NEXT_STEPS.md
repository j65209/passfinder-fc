# 다음 작업 단계

## 우선순위 1: 배포 (도메인 연결까지)

### 1-1. Git 초기화

```bash
git init
git add .
git commit -m "Initial commit: passfinder-fc demo"
```

### 1-2. GitHub 레포 생성 및 푸시

GitHub 웹에서 새 저장소 만들기 (이름: `passfinder-fc`, public 또는 private)

```bash
git branch -M main
git remote add origin https://github.com/USERNAME/passfinder-fc.git
git push -u origin main
```

### 1-3. Netlify 자동 배포

1. https://app.netlify.com 로그인 (GitHub 계정 연동)
2. "Add new site" → "Import an existing project" → GitHub → `passfinder-fc` 선택
3. Build settings 그대로 두고 "Deploy"
4. 자동 URL 발급됨 (예: `passfinder-fc-abc123.netlify.app`)
5. Site name 변경: Site settings → Change site name → `passfinder-fc`
6. 이후로는 git push만 하면 자동 배포됨

### 1-4. 도메인 연결

가비아/후이즈/Cloudflare에서 도메인 구매 후:

**A 방법 (DNS 레코드 추가) — 추천**
- Netlify에서 안내하는 A 레코드 IP 또는 CNAME을 도메인 등록업체 DNS 관리에 추가
- 24시간 이내 적용

**B 방법 (네임서버 변경)**
- 도메인 등록업체에서 네임서버를 Netlify 것으로 변경
- 자동화는 더 좋지만 처음엔 헷갈림

SSL은 Netlify가 Let's Encrypt로 자동 발급.

---

## 우선순위 2: 진짜 운영 가능하게 (Supabase 백엔드)

현재는 각자 브라우저에 데이터가 따로 저장됨 → 팀원끼리 공유 안 됨.
Supabase로 변환하면 모든 팀원이 같은 데이터 봄.

### 2-1. Supabase 프로젝트 생성

1. https://supabase.com 회원가입 (무료 플랜 충분)
2. New Project → 이름: passfinder-fc, 비밀번호 설정
3. 프로젝트 URL과 anon key 받기

### 2-2. 테이블 스키마

```sql
-- members 테이블
create table members (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  position text check (position in ('GK', 'DF', 'MF', 'FW')),
  joined date default current_date,
  created_at timestamp default now()
);

-- matches 테이블
create table matches (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  match_date date not null,
  match_time time,
  location text,
  created_at timestamp default now()
);

-- attendance 테이블
create table attendance (
  match_id uuid references matches(id) on delete cascade,
  member_id uuid references members(id) on delete cascade,
  vote text check (vote in ('yes', 'no', 'maybe')),
  updated_at timestamp default now(),
  primary key (match_id, member_id)
);

-- payments 테이블
create table payments (
  id uuid primary key default gen_random_uuid(),
  member_id uuid references members(id) on delete cascade,
  month text not null,  -- '2026-05' 형식
  amount integer not null,
  method text check (method in ('toss', 'kakao', 'cash', 'transfer')),
  paid_at timestamp,
  tx_id text,
  unique (member_id, month)
);
```

### 2-3. 인증 옵션

**Option A: 인증 없이 운영 (간단)**
- URL을 아는 사람만 접근
- RLS(Row Level Security) 끔
- 풋살팀 내부용으로는 충분

**Option B: 카카오 로그인 (제대로)**
- Supabase Auth + 카카오 OAuth
- 운영자만 수정 가능, 팀원은 조회와 자기 투표만
- 더 안전하지만 설정 복잡

처음엔 Option A로 시작 추천.

### 2-4. 코드 변경 포인트

`index.html`의 JavaScript 부분에서:
- `loadData()` / `saveData()` → Supabase 클라이언트로 교체
- 모든 state 변경 시 → Supabase에 즉시 동기화
- `supabase.from('members').on('*', callback).subscribe()` 로 실시간 동기화

코드 분리 권장:
```
passfinder-fc/
├── index.html        # 단일 파일 → 분리
├── src/
│   ├── app.js        # 메인 로직
│   ├── supabase.js   # 클라이언트 초기화
│   └── styles.css
└── .env              # Supabase URL/Key (Netlify env로 이동)
```

---

## 우선순위 3: UX 강화

### 3-1. 카카오톡 공유

- 카카오 JS SDK로 "단톡방에 공유하기" 버튼
- 미납자 명단을 자동으로 카톡 메시지로 만들어 보내기

### 3-2. 푸시 알림

- 경기 전날 자동 리마인드
- 회비 납부일 알림
- Web Push API 사용 (PWA)

### 3-3. 통계 페이지

- 월별 참석률 그래프 (Chart.js)
- 팀원별 출석 랭킹
- 회비 납부 누적 그래프

---

## 비용 추산 (1년)

| 항목 | 비용 |
|---|---|
| 도메인 (.com) | 14,000~18,000원 |
| Netlify 호스팅 | 무료 |
| Supabase | 무료 (DB 500MB, 사용자 50K MAU) |
| Cloudflare CDN | 무료 |
| **합계** | **연 1.5만원 정도** |

풋살팀 규모면 모든 무료 플랜 안에서 충분히 동작.
