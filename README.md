# 패스파인더 FC (PASSFINDER FC)

풋살팀 운영용 모바일 친화적 웹앱. 참석 투표, 회비 관리, 팀원 명단을 Supabase 백엔드로 실시간 공유.

🌐 **라이브**: https://j65209.github.io/passfinder-fc
📦 **레포**: https://github.com/j65209/passfinder-fc (public)
🚀 **호스팅**: GitHub Pages (auto-deploy from main branch)

---

## 현재 상태 (v1.0 — 2026-05-05)

### 구현된 기능

**인증**
- 회원: 이름 + 연락처(전체, - 없이)로 자동 가입 + 로그인 (signup_member RPC)
- 운영자: 4~8자리 PIN (DB의 app_config에 저장, 첫 접속 시 설정)
- 운영자 모드는 로그인 화면 우측 상단 ⚙️ 아이콘으로 진입

**참석 관리**
- 가장 가까운 경기 자동 표시 (D-day 계산)
- 참석/미정/불참 3단 토글
- 회원은 본인 참석만, 운영자는 누구나 변경 가능
- 경기 반복 생성: 매주 / 2주마다 (최대 52회 일괄)
- 예정된 경기 목록 (운영자 전용, 최대 10개 표시)

**회비 관리**
- 미납자/완납자 분리 표시 + 수금률 진행 바
- 운영자 빠른가기 (회비 탭 상단):
  - 📋 미납자 카톡 공유 (Web Share API + 클립보드 폴백)
  - 🏦 모임통장 열기 (계좌번호 클립보드 + 카뱅 딥링크)
- 회원별 "✓ 납부 완료" 단일 버튼 (운영자 전용)
- 모임통장 계좌 정보 설정 (은행/계좌번호/예금주 → app_config)

**팀원 명단**
- 모든 회원 조회 가능
- 운영자만 삭제 가능 (회원 직접 가입이 기본)

### 기술 스택
- Frontend: 단일 HTML 파일 (CSS + Vanilla JS)
- Backend: Supabase (PostgreSQL + Auth + RLS)
- 호스팅: GitHub Pages (auto deploy from main branch)
- 외부 의존성: `@supabase/supabase-js@2` (CDN), Google Fonts

### 데이터 구조 (Supabase)
- `members(id, name, phone, joined, created_at)` — anon SELECT 차단, RPC만 허용
- `members_public` — phone 제외한 공개 뷰
- `matches(id, title, match_date, match_time, location, created_at)`
- `attendance(match_id, member_id, vote)` — 복합키
- `payments(id, member_id, month, amount, method, paid_at, tx_id)`
- `app_config(key, value)` — admin_pin, monthly_fee, bank_*

### RLS 정책 (간편 모드)
- 모든 anon이 읽고 쓰기 가능 (members 직접 SELECT만 차단)
- 권한 분기는 프론트엔드 PIN 게이트 + 자기 참석만 수정 검증
- 풋살팀 규모 적합 — 진짜 보안 필요하면 Edge Function으로 강화 가능

---

## 자주 하는 수정

### 새 기능 추가
1. `index.html` 수정
2. `git add . && git commit -m "메시지" && git push`
3. GitHub Pages가 자동 배포 (~1~2분)

### DB 스키마 변경
1. Supabase 대시보드 → SQL Editor → 변경 SQL 실행
2. `index.html`의 관련 코드 수정
3. 푸시

### 운영자 PIN 잊어버림
- Supabase 대시보드 → Table Editor → `app_config` 테이블 → `admin_pin` 행의 value 수정
- 또는 SQL: `update app_config set value = '새PIN' where key = 'admin_pin';`

### 모임통장 계좌 등록
- 운영자 모드 → 회비 탭 → "⚙️ 모임통장 계좌 설정" 버튼

### 회원 탈퇴/수정
- 운영자 모드 → 팀원 탭 → 해당 회원 옆 "삭제"
- 데이터는 cascade로 삭제됨 (참석 기록, 회비 기록 포함)

---

## 마이그레이션 히스토리

- `supabase-schema.sql` — 초기 스키마 (members, matches, attendance, payments, RLS)
- `supabase-migration-002.sql` — phone_last4 → phone, signup_member 함수 추가

---

## 환경 정보

- **Supabase Project URL**: `https://dedjxhuhxqzcigisnmvf.supabase.co`
- **Anon Key (sb_publishable)**: 코드에 하드코딩됨 (공개해도 안전)
- **GitHub**: `j65209/passfinder-fc` (public)
- **GitHub Pages**: `j65209.github.io/passfinder-fc` (Settings → Pages)

⚠️ Supabase `service_role` 키는 절대 코드/저장소에 넣지 말 것 (전체 권한 마스터 키)

---

## 로컬 개발

```bash
# 그냥 브라우저에서 index.html 열거나
open index.html

# 로컬 서버 (폰에서 같은 와이파이 접속용)
python3 -m http.server 8000
```

수정 후 푸시하면 자동 배포되니까 로컬 개발 안 해도 됨. 작은 변경은 GitHub 웹 에디터에서 바로 편집해도 OK.

---

## 다음에 추가 가능한 기능

진짜 필요해지면 추가 검토:

- [ ] 출석률 통계/그래프 (Chart.js)
- [ ] 푸시 알림 (PWA Web Push) — 경기 전날 리마인드
- [ ] 카카오톡 챗봇 연동 (단톡방 자동 알림)
- [ ] 카카오뱅크 모임통장 자동 입금 동기화 (Android SMS Forwarder + Edge Function)
- [ ] 회비 미납 자동 푸시
- [ ] 경기 결과/MOM 기록
- [ ] 사업자 등록 후 PG 가상계좌 연동

---

## 비용

| 항목 | 비용 |
|---|---|
| 도메인 (.com, 추후) | 연 14,000~18,000원 |
| GitHub Pages | 무료 (public repo) |
| Supabase | 무료 (DB 500MB, MAU 5만) |
| **현재** | **0원** |
