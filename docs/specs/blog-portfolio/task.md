# Tasks — Blog de portfólio (Ciência de Dados & Dev)

<!--
No frontmatter — spec.md is the source of truth.
Execution tracking for the current implementation pass. See plan.md for the
step-by-step and spec.md for scope decisions.
-->

## Checklist

Passada: **BLOG-1** (MVP). Modo de decomposição: **só a próxima etapa aberta**. As
etapas seguintes ficam em nível de etapa até a anterior fechar, porque o plano ainda
vai se ajustar ao que o scaffold revelar.

- [x] **Step 0 — Ruby 3.4 via Docker Compose**
  - [x] `compose.yaml` na raiz (serviço `site`, bind mount `:z`, volume `bundle`, porta 4000)
  - [x] `tools/docker/Dockerfile` (`ruby:3.4` + usuário `dev` com UID/GID do host + `safe.directory`)
  - [x] `ruby -v` = 3.4.x no container; dono dos arquivos = 1000; `git log` funciona; volume gravável
- [ ] **Step 1 — Scaffold do starter**
  - [ ] Clonar o starter (`--depth 1`) no scratchpad; copiar para o repositório **sem** `.git`, `.gitignore`, `.gitmodules`, `assets/lib` e `.devcontainer/`
  - [ ] Conferir que `.gitignore` continua o nosso (sem `Gemfile.lock`)
  - [ ] `.ruby-version` com `3.4`
  - [ ] Red: `docker compose run --rm site bash tools/test.sh` falha antes do `bundle install`
  - [ ] `docker compose run --rm site bundle install`, depois `bundle lock --add-platform x86_64-linux`; `BUNDLED WITH` = 2.6.x
  - [ ] Green: `docker compose run --rm site bash tools/test.sh` verde com o site vazio do starter
  - [ ] Preview sobe: `docker compose run --rm --service-ports site bash tools/run.sh -H 0.0.0.0` responde em `http://localhost:4000`
  - [ ] Commit do scaffold puro, sem edições nos arquivos do starter
- [ ] Step 2 — Validador de front matter
- [ ] Step 3 — Configuração do site
- [ ] Step 4 — Layout `project-post` e template de projeto
- [ ] Step 5 — Três posts fictícios
- [ ] Step 6 — README, remote e primeiro deploy

## State Handover

- **Done:** Step 0. Runtime local Ruby 3.4.10 / bundler 2.6.9 via `docker compose`,
  verificado (ver Verification). Branch `blog-1-mvp` criado a partir de `main@2f9a536`.
  O `origin` aponta para `https://github.com/ebenezer-dorneles/ebenezer-dorneles.github.io.git`
  (repositório público, vazio). Nada foi enviado.
- **Next:** Step 1, primeiro item: clonar o `cotes2020/chirpy-starter` no scratchpad e
  copiar os arquivos com as exclusões da Checklist.
- **Blockers / open decisions:** nenhum para os Steps 1–5. Antes do Step 6, o autor
  precisa confirmar Pages → Source = **GitHub Actions** (a API de Pages exige
  autenticação, então não deu para verificar daqui).
- **Watch out:**
  - Todo comando Ruby/Jekyll roda **dentro** do container (`docker compose run --rm site …`).
    O Ruby 4.0.6 do host geraria um lock com `BUNDLED WITH` 4.x, que o CI instalaria.
  - `compose.yaml` fica na raiz e o Jekyll o copia para `_site/` até o Step 3 incluí-lo
    no `exclude:`. É inofensivo antes do deploy, mas o Step 3 tem teste para isso.
  - O Step 1 copia o `_config.yml` do starter **sem editar** (scaffold puro). `lang`,
    `timezone` e `noindex` só entram no Step 3. Não publicar antes disso.
  - Três lugares com a versão 3.4: `tools/docker/Dockerfile`, `.ruby-version` (Step 1) e
    o workflow (Step 1).

## Execution Log

### 2026-09-18 — Step 0: runtime local em container

- Criados `compose.yaml` e `tools/docker/Dockerfile`.
- **Fora do plano:** o plano previa só `compose.yaml` com a imagem `ruby:3.4` e
  `user: "${UID}:${GID}"`. Isso não basta: com um UID que não existe no `/etc/passwd`
  da imagem, o `HOME` do container vira `/`, e `git config --global` e o bundler não
  têm onde gravar. Solução: um Dockerfile mínimo que cria o usuário `dev` com UID/GID
  do host (build args, default 1000) e grava `safe.directory` no nível `--system`.
  O Dockerfile fica em `tools/docker/` porque `tools` já está no `exclude:` do starter e
  não vai para `_site/`, o que um `Dockerfile` na raiz faria.
- Confirmado na imagem: `/usr/local/bundle` (= `GEM_HOME`) tem modo 1777, então o volume
  nomeado herda a permissão e o usuário `dev` instala gems sem `chown`.
- Revisão do diff: checagem manual do raio de alcance (dois arquivos novos, nenhum lido
  pelo build do site, que ainda não existe). A skill `auditoria-de-impacto` **não** foi
  invocada nesta etapa. Fica para os Steps com código do site.

## Verification

### 2026-09-18 — Step 0

- [x] Config do compose válida — `docker compose config -q` — exit 0
- [x] Imagem constrói — `docker compose build -q site` — `Built`
- [x] Runtime — `docker compose run --rm site ruby -v` — `ruby 3.4.10 … [x86_64-linux]`; `bundle -v` — `2.6.9`
- [x] Usuário e HOME — `id` no container — `uid=1000(dev) gid=1000(dev)`; `HOME=/home/dev`
- [x] Dono dos arquivos no bind mount — `touch .owner-probe` no container → `ls -ln` no host — `1000 1000`
- [x] Git no container — `git log --oneline -1` — `2f9a536`, sem erro de `dubious ownership`
- [x] Volume de gems gravável — `test -w /usr/local/bundle` — ok
- [ ] Suíte de testes — n/a nesta etapa (não há código testável; a suíte nasce no Step 2)
- [ ] Análise estática / lint — n/a (Dockerfile e compose; não há hadolint no ambiente, e o plano não o adota)

## Wrap up

Autor único, sem PR (plan → Tooling → Git): a entrega é o merge de `blog-1-mvp` em `main`.

- [ ] Merge `blog-1-mvp` → `main` e push (é o deploy: Step 6)
- [ ] Spec linkado ao issue — n/a, `BLOG-1` é identificador local registrado no próprio `spec.md`
- [ ] Follow-up registrado: `BLOG-2` (marco de saída do MVP) como nova seção em `plan.md` quando começar
- [ ] `spec.md` `status:` → `implemented` quando a Verification do Step 6 fechar
