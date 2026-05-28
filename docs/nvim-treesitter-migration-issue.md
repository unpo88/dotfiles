# nvim-treesitter 마이그레이션 — 문제 정황 정리

> 본 문서는 nvim-treesitter master(archive) → main 마이그레이션 작업 중 반복 재현되는
> 문제를 정확히 기록하고, 해결 방향을 사용자가 선택할 수 있도록 정리한 문서입니다.
> 이전까지의 시도는 모두 부분적 해결에 그쳤습니다. 이 문서를 기준으로 한 번에 결정합니다.

## 환경

- **OS**: macOS (Darwin 25.5.0)
- **Neovim**: v0.12.2
- **Plugin manager**: lazy.nvim
- **Distribution**: AstroNvim v5 (`version = "^5"`)
- **tree-sitter-cli**: 0.26.9 (Mason 설치, main 요구사항 ≥0.26.1 충족)
- **dotfiles**: `~/Desktop/dotfiles` (stow로 `~/.config/nvim` 심볼릭 링크)

## 우리가 원하는 것 (사용자 명시 요구사항)

1. **`:Lazy sync` (및 `:Lazy update` 등) 실행해도 문제가 발생하지 않아야 함**
2. **무시(silent fail / try-catch)가 아닌 근본 해결**
3. **재발하지 않아야 함** — 한 번 해결되면 같은 류 문제 안 나옴

## 관찰된 증상

### 증상 1 — markdown 파일 열기만 해도 에러

```
treesitter.lua:196: attempt to call method 'range' (a nil value)
stack:
  snacks/scope.lua:404 init
  snacks/util/init.lua:464 parse
  vim/treesitter/languagetree.lua:596 parse
  vim/treesitter.lua:196 (node:range() on nil)
```

- **트리거**: snacks.scope이 buffer 열릴 때 자동으로 treesitter 파싱 시도
- **근본 원인 추정**: archived master 시대의 query/parser와 Neovim 0.12의 treesitter API 사이 비호환

### 증상 2 — `:Lazy sync` 후 모든 변경이 원상복구

- nvim-treesitter, nvim-treesitter-textobjects 디스크가 옛 master HEAD commit으로 reset
  - `nvim-treesitter`: `42fc28ba` ("docs(readme)!: announce archiving of master branch")
  - `nvim-treesitter-textobjects`: `5ca4aaa` ("docs: master is frozen")
- `lazy-lock.json`의 commit도 그 옛 값으로 덮어쓰임
- **원인**: AstroNvim v5의 `lazy_snapshot.lua`가 두 플러그인을 그 commit으로 **hard pin**

```lua
{ "nvim-treesitter/nvim-treesitter", commit = "42fc28ba...", optional = true },
{ "nvim-treesitter/nvim-treesitter-textobjects", commit = "5ca4aaa...", optional = true },
```

### 증상 3 — (가장 최근) decoration provider 에러 + tree-sitter-lua install 실패

```
Decoration provider "conceal_line" (ns=nvim.treesitter.highlighter):
treesitter.lua:196: attempt to call method 'range' (a nil value)
stack:
  treesitter.lua:196 get_range
  treesitter.lua:231 get_node_text
  nvim-treesitter/query_predicates.lua:141 handler   ← nvim-treesitter 자체 코드
  treesitter/query.lua:868 _apply_directives
  treesitter/languagetree.lua:1123 _get_injections   ← injection (markdown→python 등) 파싱
  treesitter/highlighter.lua:529                      ← highlighter 동작 중

[nvim-treesitter] [0/22] Creating temporary directory
mv: rename tree-sitter-lua-tmp/tree-sitter-lua-master to tree-sitter-lua: No such file or directory
```

- **첫 번째**: nvim-treesitter `query_predicates.lua:141`이 `get_node_text`를 호출하다 nil node 만남.
  injection 파싱 (markdown 안에 lua/python 코드블록 같은 거) 시점에 발생.
- **두 번째**: master 시대 install 스크립트가 동작 중 (`Creating temporary directory`, `mv tree-sitter-lua-master`).
  main 브랜치 install API와 다른 경로. → 디스크는 main인데 일부 install 로직은 master를 기대?

## 시도한 해결책과 결과 (시간순)

### 시도 1 — spec에 `branch = "main"`만 override
- **변경**: `treesitter.lua`에 `branch = "main"`, 우리 자체 setup
- **결과**: AstroNvim spec의 `commit = "42fc28ba..."`가 lazy 머지에서 win → 디스크 변경 없음.
  사용자 보고: `:Lazy sync` 후 원상복구

### 시도 2 — 디스크 직접 main으로 checkout + `lazy-lock.json` 갱신 + dotfiles commit
- **변경**: 플러그인 dir에서 직접 `git checkout main`, lock json의 commit 수동 갱신
- **결과**: `:Lazy sync` 시점에 AstroNvim의 commit pin이 다시 win → 모두 옛 commit으로 복원

### 시도 3 — `pin_plugins = false` + spec 모든 옛 옵션 명시 override
- **변경**:
  - `lazy_setup.lua`: `pin_plugins = false` (AstroNvim lazy_snapshot의 hard commit pin 무력화)
  - `treesitter.lua`: `branch = "main"`, `lazy = false`, `main = "nvim-treesitter"`,
    `dependencies = { textobjects branch=main }`, `init = function() end`,
    `opts = function() return {} end`, `config = function() ... 우리 새 setup ... end`
  - `nvim-treesitter-textobjects.lua`: 동일한 패턴
- **결과**: 사용자가 새로 증상 3 보고 — 디스크 변경은 유지된 것으로 보이나, `query_predicates.lua:141` 경로의 에러와 master 시대 install 실패가 출력됨

## 현재 미확인 사항

1. 증상 3 시점에 nvim-treesitter / textobjects 디스크가 main 브랜치에 있었는지 (재진단 필요)
2. `nvim-treesitter/query_predicates.lua`가 main에서도 존재하는데 0.12 API와 호환되는지
3. `tree-sitter-lua-master` 받으려고 한 주체가 누구인지 (lazy? nvim-treesitter? 다른 plugin?)
4. AstroNvim `plugins/treesitter.lua`의 `init = function(plugin) ... add_to_rtp + query_predicates require ... end`
   가 우리 override(`init = function() end`)로 정말 무력화 됐는지 (lazy spec merge의 init 처리 방식 확인 필요)
5. snacks.scope이 markdown injection을 강제로 깊이 파싱하면서 에러를 노출시키는데,
   markdown injection을 끄거나 snacks scope에서 markdown 제외할 수 있는지

## 가능한 해결 방향 (사용자 선택 필요)

각 옵션의 trade-off를 명시합니다. **무엇이 우선인지 결정해 주세요.**

### 옵션 A — AstroNvim 업그레이드 (v5 → v6 이상)
- **장점**: AstroNvim v6 이상이 Neovim 0.12 + nvim-treesitter main을 공식 지원할 가능성. 가장 정공법.
- **단점**: AstroNvim 업그레이드 자체가 큰 변화. `astrocore.lua`, `astrolsp.lua`, `astroui.lua` 등 config 마이그레이션 작업 별도로 필요. lazy-lock.json 전체 변경.
- **확인 필요**: AstroNvim v6 릴리스 노트의 Neovim 0.12 지원 명시 여부

### 옵션 B — AstroNvim 의존 제거, 베어 lazy.nvim 셋업으로 전환
- **장점**: AstroNvim의 모든 master 시대 가정 완전 제거. 무엇이 어디서 오는지 명확해짐.
- **단점**: AstroNvim이 제공하던 LSP/keymap/plugin 통합을 사용자가 직접 구성 필요. 며칠~몇 주 작업.

### 옵션 C — nvim-treesitter main 포기, Neovim 내장 treesitter만 사용
- **장점**: nvim-treesitter 플러그인 자체를 제거 (의존성 한 묶음 사라짐). Neovim 0.12 내장 `vim.treesitter` API만 사용.
- **단점**: 파서 설치/관리를 다른 방법으로 (수동 `:TSInstall` 안 됨). 일부 plugin이 nvim-treesitter API에 의존하면 동작 멈춤 (예: aerial, snacks 일부).

### 옵션 D — Neovim 0.11 LTS로 다운그레이드
- **장점**: master 브랜치가 공식 backward-compat 보장. 모든 시도가 무효화되고 안정.
- **단점**: 최신 Neovim 기능 손실. 다른 plugin이 0.12 의존하면 그게 깨짐.

### 옵션 E — snacks.scope에서 markdown 제외 + nvim-treesitter는 master 유지
- **장점**: 최소 변경. 증상 1만 차단하면 일상 사용은 동작했음 (현재까지).
- **단점**: 증상 2 (sync 원상복구)는 사실 우리가 잘못 건드려서 만든 거고, master로 돌아가면 사라짐.
  단 master는 archived라 미래에 또 깨질 가능성. **"임시봉합" 성격**.

### 옵션 F — AstroNvim v5 유지하면서 specific plugin만 우회
- 진행 중이던 옵션. 시도 3까지 했지만 미해결.
- 추가 시도 가능 영역:
  - AstroNvim의 `plugins/treesitter.lua` 자체를 lazy spec에서 명시적 disable (`enabled = false`)
  - 우리만의 새 spec으로 nvim-treesitter main을 처음부터 등록
  - 다만 어떤 다른 plugin이 nvim-treesitter API를 require하는지 의존 그래프 조사 필수

## 추천 우선순위 (작성자 의견)

1. **사용자 의도 확인 우선**: AstroNvim을 유지할 의향이 있는지? 업그레이드 가능 시간이 있는지?
2. 시간 여유 있으면 → **옵션 A** (AstroNvim v6+ 업그레이드, 정공법)
3. 시간 없고 일단 마침표 → **옵션 E** (master 유지 + snacks.scope에서 markdown 제외)
4. AstroNvim 의존을 진지하게 재검토하고 싶다면 → **옵션 B**

## 결정 요청

위 옵션 중 어떤 방향으로 갈지 알려주세요.
선택에 따라 별도 작업 계획(plan)을 짜고, 그것대로만 실행하겠습니다.
**다시는 "한 번 더 시도"하다가 새 에러가 생기는 패턴은 피하겠습니다.**
