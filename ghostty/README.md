# Ghostty

`config`는 [공식 옵션 문서](https://ghostty.org/docs/config) 문법을 그대로 따릅니다.

## 디렉토리 레이아웃

```
ghostty/Library/Application Support/com.mitchellh.ghostty/
├── config                    # 메인 설정
└── shaders/                  # 배경/풀스크린 효과 GLSL
```

> 커서 트레일 효과는 Ghostty 셰이더가 아니라 nvim 의 `smear-cursor.nvim` 플러그인에서 처리합니다.

stow로 symlink되면 Ghostty는 `~/Library/Application Support/com.mitchellh.ghostty/` 에서 읽습니다.

## 셰이더 카탈로그

`custom-shader = <path>` 옵션이 GLSL fragment 셰이더를 GPU에 올립니다. 여러 줄을 동시에 적으면 순차 layering됩니다.

### shaders/ — 배경/풀스크린 효과

| 파일 | 효과 |
|------|------|
| `crt.glsl` | 레트로 CRT 모니터 (스캔라인 + 색수차) |
| `snow.glsl` | 화면 위로 떨어지는 눈 입자 |

## 셰이더 교체 방법

`config`의 `# ===== Shaders =====` 블록에서 활성 라인의 주석 처리만 바꾸면 됩니다. 적용은 Ghostty 창에서 `Cmd+Shift+,` 한 번이면 끝(앱 재시작 불필요).

```ini
# 활성 (한 줄만 주석 해제)
# custom-shader = shaders/snow.glsl
# custom-shader = shaders/crt.glsl
```

## 새 셰이더 추가

1. `.glsl` 파일을 `shaders/`에 저장
2. `config`에 `custom-shader = ...` 라인 추가
3. `Cmd+Shift+,` 로 reload

**보안 주의**: GLSL 셰이더는 GPU sandbox 안에서만 실행되어 파일/네트워크 접근은 못 합니다. 하지만 신뢰 가능한 출처(공식 collection·고스타 repo)에서 받고, 다운로드한 파일이 GLSL 외 내용을 포함하는지 확인하세요.

## 출처

셰이더는 [`mizisu/dotfiles`](https://github.com/mizisu/dotfiles) 컬렉션 구조를 미러링했습니다. 원작자별 라이선스는 각 파일 상단 주석 참고.
