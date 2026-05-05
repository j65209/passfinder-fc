# Claude Code 시작하기

이 폴더를 Claude Code로 작업하려면 다음 순서로 하세요.

## 1단계: Claude Code 설치 (이미 했으면 스킵)

Node.js 18 이상이 설치되어 있어야 함.

```bash
npm install -g @anthropic-ai/claude-code
```

## 2단계: 이 폴더로 이동

```bash
cd /path/to/passfinder-fc
```

## 3단계: Claude Code 실행

```bash
claude
```

## 4단계: 첫 메시지 복붙

Claude Code가 켜지면 아래 메시지를 그대로 복사해서 붙여넣으세요.

---

```
이 프로젝트는 풋살팀 운영용 웹앱입니다.
README.md와 NEXT_STEPS.md를 먼저 읽고 현재 상태를 파악해주세요.

그 다음 첫 작업으로:
1. Git 저장소 초기화
2. 첫 커밋 (메시지: "Initial commit: passfinder-fc demo")
3. 로컬에서 동작 테스트 (python3 -m http.server 8000 같은 거)

이걸 순서대로 진행해주세요.
```

---

## 5단계: 그 다음 작업들

순서대로 시키면 됩니다:

**GitHub 푸시**
```
GitHub에 새 저장소를 만들고 푸시하고 싶어요.
저장소 이름은 passfinder-fc로요.
gh CLI 도구를 쓸 수 있으면 그걸로, 없으면 수동 가이드 알려주세요.
```

**Netlify 배포**
```
Netlify에 자동 배포하고 싶어요. GitHub 저장소를 연동하는 방식으로요.
어떻게 하면 되는지 단계별로 알려주세요.
netlify.toml은 이미 만들어져 있어요.
```

**도메인 연결**
```
가비아에서 [도메인 이름]을 샀어요. Netlify 사이트에 연결하고 싶습니다.
DNS 설정을 어떻게 해야 하나요?
```

**Supabase 백엔드 추가**
```
지금은 데이터가 각자 브라우저에 저장되는데, 팀원끼리 공유되도록 Supabase를 붙이고 싶습니다.
NEXT_STEPS.md의 "우선순위 2" 부분을 참고해서 진행해주세요.
먼저 어떤 정보가 필요한지 알려주세요.
```

## 팁

- Claude Code는 파일을 직접 수정할 수 있고 터미널 명령도 실행 가능
- 중요한 변경 전에 항상 권한 묻는 옵션 켜두기 추천
- 매번 작업 후 git commit 습관 들이기 (실수해도 되돌릴 수 있게)
- 모르는 거 있으면 그냥 한국어로 물어봐도 됩니다
