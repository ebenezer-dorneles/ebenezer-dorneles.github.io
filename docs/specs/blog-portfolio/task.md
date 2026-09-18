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
- [x] **Step 1 — Scaffold do starter**
  - [x] Clonar o starter (`--depth 1`) no scratchpad; copiar para o repositório **sem** `.git`, `.gitignore`, `.gitmodules`, `assets/lib` e `.devcontainer/`
  - [x] Conferir que `.gitignore` continua o nosso (sem `Gemfile.lock`)
  - [x] `.ruby-version` com `3.4`
  - [x] Red: `docker compose run --rm site bash tools/test.sh` falha antes do `bundle install`
  - [x] `docker compose run --rm site bundle install`, depois `bundle lock --add-platform x86_64-linux`; `BUNDLED WITH` = 2.6.x
  - [x] Green: `docker compose run --rm site bash tools/test.sh` verde com o site vazio do starter
  - [x] Preview sobe: `docker compose run --rm --service-ports site bash tools/run.sh -H 0.0.0.0` responde em `http://localhost:4000`
  - [x] Commit do scaffold puro, sem edições nos arquivos do starter
- [x] **Step 2 — Validador de front matter** (TDD; comandos em plan → Tooling)
  - [x] `minitest` no Gemfile (`group: :test`); `bundle install` no container; lock atualizado, `BUNDLED WITH` ainda 2.6.x
  - [x] Esqueleto: `tools/validate-front-matter.rb` com `FrontMatterValidator.validate(path:, source:, config:)` devolvendo `[]` e `CATEGORIES`; CLI só sob `if $PROGRAM_NAME == __FILE__`
  - [x] Red: `test/validate_front_matter_test.rb`, um caso por regra (lista do plan, Step 2), mais o caso válido; rodar e confirmar que **cada** caso falha pelo motivo certo (asserção, não `NameError`/`LoadError`)
  - [x] Red: fixtures `test/fixtures/front_matter/{valid,invalid}/` e teste de CLI via `Open3` (exit 0 / exit 1 com mensagem)
  - [x] Green: regras implementadas até a suíte passar; CLI sem argumentos varre `_posts/**/*.md` e `_drafts/**/*.md` e reporta todos os erros
  - [x] Refactor: uma função por regra, cada uma devolvendo lista; mensagens `caminho: campo: problema` em pt-BR; `YAML.safe_load(..., permitted_classes: [Date, Time])`
  - [x] `tools/check.sh` (validador + testes unitários); `bash -n` limpo; `ruby -wc` limpo nos `.rb`
  - [x] `test` no `exclude:` do `_config.yml` (primeira edição do starter; registrado no Log)
  - [x] Gate: `docker compose run --rm site bash tools/check.sh` verde; `auditoria-de-impacto`; commit
- [ ] **Step 3 — Configuração do site** (Red/Green/Refactor em plan → Step 3)
  - [ ] Red: `test/site_test.rb` lendo `_site/` gerado: `<html lang="pt-BR">`; `<meta name="robots" content="noindex, nofollow">` na home; `sitemap.xml` e `robots.txt` existem; links de GitHub, LinkedIn e e-mail na home (regra 12); página `/about/` existe; `_site/test`, `_site/draft`, `_site/docs` e `_site/compose.yaml` **não** existem
  - [ ] Green: `_config.yml` com os campos do escopo do MVP (title, tagline, description, url, lang: pt-BR, github.username, social.*), mais `timezone: America/Sao_Paulo`, `noindex: true`, e `test`/`draft`/`compose.yaml` no `exclude:`
  - [ ] Green: `_includes/metadata-hook.html` emitindo o `<meta robots>` quando `site.noindex` é verdadeiro (única sobrescrita de arquivo do gem — placeholder vazio, aprovado no spec → Feedback)
  - [ ] Green: `_data/contact.yml`, `_data/share.yml`, `_tabs/about.md` (texto provisório, marcado como tal)
  - [ ] Green: `tools/check.sh` completo — acrescentar `tools/test.sh` e `test/site_test.rb` ao final (validador → testes unitários → build+htmlproofer → testes de integração do site)
  - [ ] Refactor: `_config.yml` mantém ordem e comentários do starter; só os valores mudam
  - [ ] Gate: `docker compose run --rm site bash tools/check.sh` verde; `auditoria-de-impacto`; commit
- [ ] Step 4 — Layout `project-post` e template de projeto
- [ ] Step 5 — Três posts fictícios
- [ ] Step 6 — README, remote e primeiro deploy

## State Handover

- **Done:** Steps 0, 1 e 2. Step 2 (validador de front matter, TDD) fechado:
  `tools/validate-front-matter.rb` com uma função por regra (`title`, `date`,
  prefixo de arquivo em `_posts/`, `categories`, `tags`, `project`/`repo`/`layout`,
  `last_modified_at`, guarda do `[RASCUNHO]` × `noindex`), CLI sob
  `if $PROGRAM_NAME == __FILE__` com flag `--root` (default `.`), `tools/check.sh`
  (validador + `test/validate_front_matter_test.rb`), `test` no `exclude:` do
  `_config.yml`. `minitest` 6.0.6 no Gemfile (`group: :test`); `BUNDLED WITH`
  continua `2.6.9`. `auditoria-de-impacto` rodada antes do commit: achou dois
  buracos de tipo (`repo`/`tag` não-string derrubavam o script em vez de reportar
  erro), corrigidos com guarda de tipo e teste de regressão. Nada foi enviado ao
  `origin`.
- **Next:** Step 3 — Configuração do site (ver plan.md → Stages). Decompor a
  Checklist antes de começar (modo: só a próxima etapa aberta).
- **Blockers / open decisions:** nenhum para os Steps 3–5. Antes do Step 6, o autor
  precisa confirmar Pages → Source = **GitHub Actions**.
- **Watch out:**
  - Todo comando Ruby/Jekyll roda **dentro** do container (`docker compose run --rm site …`).
    O Ruby 4.0.6 do host geraria um lock com `BUNDLED WITH` 4.x.
  - O workflow do starter **já** vem com `ruby-version: 3.4`: os três lugares com a
    versão (Dockerfile, `.ruby-version`, workflow) estão alinhados sem edição.
  - O workflow publica a cada push em `main`/`master`. Não fazer push de `main` antes do Step 6.
  - `compose.yaml` ainda vai para `_site/` até o Step 3. Não publicar antes disso.
  - O bundler 2.6 grava 11 plataformas no lock por padrão (arm, darwin, musl…), não só
    `x86_64-linux`. É o comportamento dele e é inofensivo; não "limpar" à mão.
  - O validador ainda não roda no workflow (isso é Step 3, quando `check.sh` ganha
    `test.sh` + `site_test.rb` no fim e o job troca os passos inline pelo `check.sh`).
  - `_config.yml` ainda não tem `noindex: true` (chega no Step 3). Até lá, um post
    real com título `[RASCUNHO]` reprovaria o validador — não é o caso, ainda não há
    posts em `_posts/`/`_drafts/`.

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

### 2026-09-18 — Step 1: scaffold do starter

- `cotes2020/chirpy-starter` clonado com `--depth 1` no scratchpad (HEAD `beffc88`,
  "Update critical file(s) according to Chirpy v7.6.0"). Copiado com
  `tar --exclude` (`.git`, `.gitignore`, `.gitmodules`, `assets/lib`, `.devcontainer`).
  O diretório `assets/` vazio que sobrou do gitlink foi removido.
- `diff -rq` clone × repositório: única diferença é o `assets/` excluído. O scaffold é puro.
- **Constatação:** o workflow do starter já usa `ruby-version: 3.4`. O Handover anterior
  previa editar o workflow no Step 1; não foi preciso, e o commit ficou sem nenhuma edição.
- O `bundle lock --add-platform x86_64-linux` não mudou nada: o bundler 2.6.9 já grava
  `x86_64-linux` entre as 11 plataformas padrão. O comando fica no procedimento, porque
  é idempotente.
- `auditoria-de-impacto` rodada antes do commit. 24 arquivos novos, nenhum versionado
  alterado (o `.gitattributes` com `* text=auto` não renormalizou nada) e nenhuma
  invariante nova. Efeito irreversível alcançável: só o `pages-deploy.yml` num push em
  `main`, que não acontece antes do Step 6. Fora do escopo, só registrado: o
  `_plugins/posts-lastmod-hook.rb` do starter interpola `post.path` no shell sem
  escapar. O risco é baixo (caminhos do próprio repositório) e o arquivo fica intocado.
- Commit `d350906`. Step 2 decomposto na Checklist.

### 2026-09-18 — Step 2: validador de front matter (TDD)

- `minitest` (6.0.6) adicionado ao Gemfile em `group: :test`; `bundle install` no
  container; `BUNDLED WITH` continua `2.6.9`.
- Esqueleto de `tools/validate-front-matter.rb` com `CATEGORIES` já preenchida
  (`Ciência de Dados`, `Desenvolvimento` — regra 11, confirmada no spec) em vez de
  vazia: o plano previa `[]` no esqueleto, mas o valor real já estava decidido e
  registrado no spec, então preencher de uma vez evitou um passo extra sem
  ambiguidade.
- Red: `test/validate_front_matter_test.rb` com 22 casos (um por regra do plan +
  válido + guarda do `[RASCUNHO]`) mais 2 testes de CLI via `Open3`. Rodado antes
  da implementação: 20 falhas, 0 erros — todas por asserção (`assert`/`refute`),
  confirmando que o esqueleto (`validate` sempre devolvendo `[]`) é a causa, não
  um erro de carregamento.
- Fixtures em `test/fixtures/front_matter/{valid,invalid}/`, cada uma com
  subdiretórios `_posts/`/`_drafts/` reais, porque o CLI varre por essas pastas.
  A CLI ganhou uma flag `--root <dir>` (não prevista no plan) para o teste de
  integração apontar pra fixture sem tocar `_posts/`/`_drafts/` do repositório —
  sem isso, o teste de CLI só poderia rodar depois de existirem posts reais
  (Step 5), quebrando a ordem do plano.
- Green: uma função privada por regra (`check_title`, `check_date`,
  `check_filename`, `check_categories`, `check_tags`, `check_project`,
  `check_last_modified_at`, `check_draft_guard`), todas devolvendo lista de erros
  no formato `caminho: campo: problema`; front matter extraído por regex de
  cercas `---`, YAML lido com `YAML.safe_load(..., permitted_classes: [Date, Time])`.
  Mensagens de erro impressas em `stdout` (não `stderr`), porque o teste de CLI
  cobra mensagem visível na saída padrão e é isso que o CI vai logar.
- `auditoria-de-impacto` rodada sobre o diff antes do commit. Achado: `repo` ou
  item de `tags` não-string (ex. `repo: 12345`, `tags: [42]`) faziam
  `Regexp#match?`/`String#downcase` levantar exceção em vez de reportar erro de
  validação — o script ainda falharia (exit não-zero por exceção não tratada),
  mas com stack trace em vez de mensagem útil. Corrigido com guarda de tipo em
  `check_project` e `check_tags`, com teste de regressão para os dois casos.
  Nenhum efeito irreversível alcançável pelo diff (script só lê arquivos e
  imprime). Veredito: pronto para commit.
- `test` adicionado ao `exclude:` do `_config.yml` — primeira edição de um arquivo
  do starter. `tools/test.sh` continua verde (6 arquivos, 13 links, 0 falhas):
  `test/` nunca apareceu no `_site` antes (não existia), e passa a ficar de fora
  quando existir código real.
- `tools/check.sh` criado (só validador + testes unitários, como o plan pede para
  este Step; `test.sh` e `site_test.rb` entram no fim no Step 3). `bash -n` e
  `ruby -wc` limpos.
- Gate: `docker compose run --rm site bash tools/check.sh` — 26 testes (22 + 2 de
  regressão da auditoria + 2 de CLI), 0 falhas, 0 erros.

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

### 2026-09-18 — Step 1

- [x] Red — `docker compose run --rm site bash tools/test.sh` antes do `bundle install` — exit 127, `bundler: command not found: jekyll`
- [x] Dependências — `docker compose run --rm site bundle install` — 62 gems, 5 dependências do Gemfile; `bundle lock --add-platform x86_64-linux` — lock gravado
- [x] Lock — `grep BUNDLED -A1 Gemfile.lock` — `2.6.9`; `x86_64-linux` em PLATFORMS; dono `1000:1000`
- [x] Green — `docker compose run --rm site bash tools/test.sh` — exit 0; build em 1.5 s; html-proofer: 6 arquivos, 13 links internos, 0 falhas; 0 linhas com `warn`/`error`/`deprecat` no log
- [x] Preview — `docker compose run -d --rm --service-ports site bash tools/run.sh -H 0.0.0.0` + `curl http://localhost:4000/` — HTTP 200, `<title>Chirpy</title>`; container parado depois
- [x] Scaffold puro — `diff -rq` clone × repositório — só `assets/` (excluído de propósito)
- [ ] Suíte de testes — n/a (a suíte nasce no Step 2)
- [ ] Análise estática / lint — n/a (nenhum código nosso; arquivos do starter não são alterados)

### 2026-09-18 — Step 2

- [x] Red — `docker compose run --rm site bundle exec ruby -Itest test/validate_front_matter_test.rb` (esqueleto) — 24 runs, 20 failures, 0 errors
- [x] Green — mesmo comando, após implementar as regras — 24 runs, 0 failures, 0 errors
- [x] Auditoria de impacto — achou 2 buracos de tipo (`repo`/`tag` não-string); corrigidos com guarda de tipo + 2 testes de regressão
- [x] Suíte de testes (final) — `docker compose run --rm site bash tools/check.sh` — 26 runs, 29 assertions, 0 failures, 0 errors
- [x] Análise estática / lint — `docker compose run --rm site ruby -wc tools/validate-front-matter.rb` — `Syntax OK`; `bash -n tools/check.sh` — sem saída (ok)
- [x] `tools/test.sh` (regressão do Step 1, após editar `_config.yml`) — exit 0; html-proofer: 6 arquivos, 13 links, 0 falhas (igual ao Step 1)

## Wrap up

Autor único, sem PR (plan → Tooling → Git): a entrega é o merge de `blog-1-mvp` em `main`.

- [ ] Merge `blog-1-mvp` → `main` e push (é o deploy: Step 6)
- [ ] Spec linkado ao issue — n/a, `BLOG-1` é identificador local registrado no próprio `spec.md`
- [ ] Follow-up registrado: `BLOG-2` (marco de saída do MVP) como nova seção em `plan.md` quando começar
- [ ] `spec.md` `status:` → `implemented` quando a Verification do Step 6 fechar
