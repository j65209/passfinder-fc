# 패스파인더 FC (PASSFINDER FC)

풋살팀 운영을 위한 모바일 친화적 웹 애플리케이션. 참석 투표, 회비 관리, 팀원 명단을 한 곳에서 관리할 수 있습니다.

## 현재 상태

**완성된 것**
- 단일 HTML 파일로 동작하는 데모 (서버 불필요)
- 다크 테마 + 한글 고딕 폰트 (Black Han Sans, Noto Sans KR)
- 모바일 최적화 (하단 탭바, 스와이프 제스처, 햅틱 피드백, 큰 터치영역)
- iOS/Android 홈 화면 추가 가능 (PWA 메타 태그)
- 데이터는 브라우저 localStorage에 저장 (개인 디바이스 단위)

**기능**
- 대시보드: 다음 경기, 참석 현황, 회비 수금률 한눈에 보기
- 참석 투표: 팀원별 참석/미정/불참 토글
- 회비 관리: 토스/카카오페이 결제 시뮬레이션, 거래 ID 생성, 미납자 표시
- 팀원 명단: 추가/삭제, 포지션별 색상 분류 (GK/DF/MF/FW)

**아직 안 한 것 (다음 단계)**
- [ ] Git 초기화 + GitHub 연결
- [ ] Netlify 또는 Cloudflare Pages 자동 배포
- [ ] 커스텀 도메인 연결
- [ ] Supabase 백엔드 연동 (팀원끼리 데이터 공유)
- [ ] 카카오톡 알림 연동 (경기 리마인드, 미납자 안내)
- [ ] 경기 일정 다중 관리
- [ ] 출석률 통계/그래프

## 기술 스택

- 순수 HTML / CSS / Vanilla JavaScript
- 외부 의존성 없음 (Google Fonts만 CDN)
- 데이터: localStorage (key: `passfinder_fc_v4`)

## 로컬에서 실행

브라우저에서 `index.html` 파일을 열면 끝. 또는 간단한 로컬 서버 띄우려면:

```bash
# Python 3
python3 -m http.server 8000

# Node.js
npx serve

# 폰에서 같은 와이파이로 접속하려면 PC IP 확인
ifconfig | grep inet  # macOS/Linux
ipconfig              # Windows
```

그 다음 폰에서 `http://(PC IP):8000` 접속.

## 사용자 정보

- 운영자: 풋살팀 운영 중
- 팀명: 패스파인더 FC (PASSFINDER FC)
- 창립: 2023년
- 회비: 월 30,000원
- 결제 방식 선호: 토스 / 카카오페이 간편결제

## 디자인 결정 이력

- 처음 다크 테마로 만듦 → 화사한 라이트 테마 시도 → 다크 테마로 복귀 (사용자 선호)
- 폰트는 한글 고딕체 위주 (Black Han Sans 디스플레이용 + Noto Sans KR 본문용)
- 액센트 컬러는 형광 그린 (#00FF88) — 풋살장 야간 조명 느낌

## 다음 작업 가이드 (Claude Code)

처음 진입하면 이 README를 먼저 읽고 다음 작업 중 하나를 시작:

1. **Git 초기화 + GitHub 푸시**
   ```bash
   git init
   git add .
   git commit -m "Initial commit: passfinder-fc demo"
   # GitHub에 새 레포 만들고
   git remote add origin <repo-url>
   git push -u origin main
   ```

2. **Netlify 배포** — GitHub 연결 후 자동 배포 설정

3. **도메인 연결** — DNS 레코드 설정 가이드

4. **Supabase 백엔드 추가** — 팀원 간 데이터 공유 기능

상세한 우선순위와 작업 내용은 `NEXT_STEPS.md` 참고.
