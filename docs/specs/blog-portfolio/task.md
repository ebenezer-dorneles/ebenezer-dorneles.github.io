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
- [x] **Step 3 — Configuração do site** (Red/Green/Refactor em plan → Step 3)
  - [x] Red: `test/site_test.rb` lendo `_site/` gerado: `<html lang="pt-BR">`; `<meta name="robots" content="noindex, nofollow">` na home; `sitemap.xml` e `robots.txt` existem; links de GitHub, LinkedIn e e-mail na home (regra 12); página `/about/` existe; `_site/test`, `_site/draft`, `_site/docs` e `_site/compose.yaml` **não** existem
  - [x] Green: `_config.yml` com os campos do escopo do MVP (title, tagline, description, url, lang: pt-BR, github.username, social.*), mais `timezone: America/Sao_Paulo`, `noindex: true`, e `test`/`draft`/`compose.yaml` no `exclude:`
  - [x] Green: `_includes/metadata-hook.html` emitindo o `<meta robots>` quando `site.noindex` é verdadeiro (única sobrescrita de arquivo do gem — placeholder vazio, aprovado no spec → Feedback)
  - [x] Green: `_data/contact.yml` (LinkedIn ativado), `_data/share.yml` (sem mudança — já atendia), `_tabs/about.md` (texto provisório, marcado como tal)
  - [x] Green: `tools/check.sh` completo — acrescentado `tools/test.sh` e `test/site_test.rb` ao final (validador → testes unitários → build+htmlproofer → testes de integração do site)
  - [x] Refactor: `_config.yml` mantém ordem e comentários do starter; só os valores mudam (mais duas adições nossas sem equivalente no starter: chave `noindex` e dois itens no `exclude:`)
  - [x] Gate: `docker compose run --rm site bash tools/check.sh` verde; `auditoria-de-impacto`; commit
- [x] **Step 4 — Layout `project-post` e template de projeto** (Red/Green/Refactor em plan → Step 4)
  - [x] Red: fixture de post com `project: true` (exclusiva do teste, fora de `_posts/`); `site_test.rb` exige o link de `repo` no HTML do post e a ausência do bloco em post comum
  - [x] Green: `_layouts/project-post.html` com `layout: post`, bloco do repositório antes de `{{ content }}`
  - [x] Green: `_drafts/template-projeto.md` com as cinco seções da regra 13 e front matter que passa no validador (o validador do Step 2 cobra isso)
  - [x] Refactor: reusar strings de `_data/locales` quando houver; senão, texto em pt-BR no layout, registrado como dívida de i18n da fase 2
  - [x] Gate: `docker compose run --rm site bash tools/check.sh` verde; `auditoria-de-impacto`; commit
- [ ] **Step 5 — Três posts fictícios** (Red/Green/Refactor em plan → Step 5)
  - [ ] Red: `site_test.rb` exige, contra os posts reais que serão adicionados: home em ordem decrescente de data (regra 9); página de cada categoria e de cada tag usadas; categoria com **um** item renderiza sem árvore quebrada (Audit item 17); tempo de leitura visível no post (regra 4); entrada de cada post no índice de busca do tema; bloco `.highlight` (Rouge) e Mermaid no post técnico; imagem servida de `assets/img/posts/<slug>/`
  - [ ] Green: três posts em `_posts/` — um por categoria (Ciência de Dados, Desenvolvimento), o terceiro com bloco de código, diagrama Mermaid e imagem própria; todos com `title` prefixado `[RASCUNHO]` e `repo` placeholder sintaticamente válido (ver spec → Decisions, "Conteúdo do MVP é fictício"); imagem redimensionada antes de commitar
  - [ ] Green: pelo menos um dos três usa `project: true` + `layout: project-post` (exercita o Step 4 com conteúdo real, não só fixture)
  - [ ] Atenção: com posts reais em `_posts/`, as fixtures de `test/fixtures/site_posts/` (Step 4) continuam ok enquanto `noindex: true` — ver Watch out
  - [ ] Refactor: conferência visual com `bash tools/run.sh` (home, post, categoria, tag, busca digitada, "sobre")
  - [ ] Gate: `docker compose run --rm site bash tools/check.sh` verde; `auditoria-de-impacto`; commit
- [ ] Step 6 — README, remote e primeiro deploy

## State Handover

- **Done:** Steps 0–4. Step 4 (layout `project-post` e template de projeto)
  fechado: `_layouts/project-post.html` herda `layout: post` e injeta um bloco
  com o link de `page.repo` antes de `{{ content }}` — nenhum arquivo do tema
  sobrescrito. `_drafts/template-projeto.md` com as cinco seções da regra 13
  (contexto, stack técnica, processo, resultado, aprendizados) e front matter
  que passa no validador. `test/fixtures/site_posts/` (novo diretório) tem
  duas fixtures exclusivas de teste — uma com `project: true`, outra comum —
  usadas só durante o gate: `tools/check.sh` agora symlinka essas fixtures em
  `_posts/` antes de buildar e as remove com um `trap` no `EXIT`, mesmo se um
  passo anterior falhar. `test/site_test.rb` ganhou 2 casos: link do
  repositório presente no post de projeto, ausente no post comum. Texto do
  bloco do repositório é pt-BR fixo no layout (sem chave equivalente em
  `_data/locales`), registrado como dívida de i18n da fase 2. Nada foi
  enviado ao `origin`.
- **Next:** Step 5 — Três posts fictícios (ver plan.md → Stages e a Checklist
  já decomposta acima).
- **Blockers / open decisions:** nenhum para o Step 5. Antes do Step 6, o autor
  precisa confirmar Pages → Source = **GitHub Actions**.
- **Watch out:**
  - Todo comando Ruby/Jekyll roda **dentro** do container (`docker compose run --rm site …`).
    O Ruby 4.0.6 do host geraria um lock com `BUNDLED WITH` 4.x.
  - O workflow do starter **já** vem com `ruby-version: 3.4`: os três lugares com a
    versão (Dockerfile, `.ruby-version`, workflow) estão alinhados sem edição.
  - O workflow publica a cada push em `main`/`master`. Não fazer push de `main` antes do Step 6.
  - O bundler 2.6 grava 11 plataformas no lock por padrão (arm, darwin, musl…), não só
    `x86_64-linux`. É o comportamento dele e é inofensivo; não "limpar" à mão.
  - O validador **ainda não roda no workflow do Actions** — `check.sh` já cobre tudo
    localmente, mas o job do `.github/workflows/pages-deploy.yml` continua com os
    passos inline `Build site`/`Test site` do starter. Trocar pelo `check.sh` é
    trabalho do Step 6 (ou de quando o workflow for tocado), não decidido ainda em
    qual Step exato — registrar ao chegar lá.
  - `test/site_test.rb` faz `skip` se `_site/` não existir: sempre rodar via
    `tools/check.sh` (que builda antes) ou `tools/test.sh` manualmente antes do teste,
    senão a suíde "passa" sem verificar nada.
  - `twitter.username` no `_config.yml` continua com o placeholder do starter
    (`twitter_username`) — fora do escopo da regra 12, mas vai aparecer no meta
    `twitter:site` se o site for publicado assim. Não bloqueia o MVP; registrar se
    virar item de fase 2.
  - **Achado da auditoria de impacto do Step 4, ainda sem correção:** as fixtures
    de `test/fixtures/site_posts/` têm título `[RASCUNHO]…`, o que o validador só
    aceita com `noindex: true`. Quando o marco de saída do MVP remover o
    `noindex`, o gate (`tools/check.sh`) vai passar a reprovar essas fixtures.
    Tratar junto da remoção dos posts fictícios (Decisions → "marco de saída do
    MVP"): tirar o prefixo `[RASCUNHO]` das fixtures (elas não são posts reais,
    não precisam do marcador) antes ou junto dessa mudança.

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

### 2026-09-18 — Step 3: configuração do site

- Red: `test/site_test.rb` criado com 12 casos sobre `_site/` gerado (lang,
  meta robots, sitemap.xml, robots.txt, link GitHub, link LinkedIn, link
  e-mail, `/about/`, ausência de `test`/`draft`/`docs`/`compose.yaml`). Rodado
  contra o `_site/` do estado anterior ao Step 3 (`tools/test.sh` já verde
  desde o Step 2): 7 falhas, 0 erros — todas por asserção (lang `en` em vez de
  `pt-BR`, meta robots ausente, GitHub/LinkedIn/e-mail com placeholders do
  starter, `_site/draft` e `_site/compose.yaml` publicados por não estarem no
  `exclude:`). Confirma que o teste falha pelo motivo certo antes do Green.
- **Bloqueio de decisão do autor, não fui capaz de inferir:** a regra 12 exige
  link de LinkedIn real, e não havia URL registrada em nenhum artefato do
  projeto (spec, plan, draft). Perguntado ao autor via `AskUserQuestion`: e-mail
  de contato confirmado como `ebenezerdorneles@gmail.com` (o mesmo desta conta);
  LinkedIn confirmado como `https://www.linkedin.com/in/ebedorneles/`. Isso não
  estava no plan como um passo explícito — o plan assumia os três links "prontos"
  sem registrar que dois dependiam de dado do autor.
- Green: `_config.yml` preenchido (ver State Handover); `noindex: true` e
  `exclude: [draft, compose.yaml]` adicionados — **fora do texto literal do
  plan**, que dizia "só os valores mudam" no Refactor, mas `noindex` e as duas
  entradas de `exclude` não têm equivalente prévio no starter para "mudar
  valor": são chaves novas, documentadas com comentário no próprio
  `_config.yml` explicando a origem. `_includes/metadata-hook.html` criado com
  o `{% if site.noindex %}`. LinkedIn descomentado e preenchido em
  `_data/contact.yml` (Twitter permanece removido do `social.links`, decisão
  do Step, já que a regra 12 não cobra Twitter). `_tabs/about.md` com bio
  provisória (`{: .prompt-warning }` marcando o texto como não-final).
  `_data/share.yml` inspecionado: já atendia (botões de compartilhamento não
  fazem parte da regra 12), nenhuma mudança necessária.
- Green confirmado: `docker compose run --rm site bash tools/check.sh` —
  validador (26 runs) → build+htmlproofer (6 arquivos, 12 links internos, 0
  falhas) → `site_test.rb` (12 runs, 0 falhas, 0 erros).
- Refactor: `_config.yml` conferido linha a linha contra o starter — só valores
  mudaram nas chaves preexistentes; a ordem e os comentários originais foram
  preservados; as duas adições (`noindex`, `exclude` +2) ficam registradas
  acima. `bash -n tools/check.sh` e `ruby -wc tools/validate-front-matter.rb`
  limpos (arquivo não tocado nesta etapa, conferido por precaução).
- `auditoria-de-impacto` rodada sobre o diff antes do commit: sem achados.
  Raio de alcance é só configuração/dados lidos pelo tema no build; nenhuma
  escrita externa, nenhum efeito irreversível alcançável (branch não mergeada,
  sem push). Único ponto fora de escopo, registrado (não corrigido):
  `twitter.username` continua com o placeholder do starter — ver State
  Handover → Watch out.
- Commit `a6ba685`. Step 4 decomposto na Checklist.

### 2026-09-18 — Step 4: layout `project-post` e template de projeto

- **Decisão fora do texto literal do plan:** o plan pedia uma "fixture de post
  com `project: true` (exclusiva do teste, fora de `_posts/`)", sem dizer como
  ela chega a ser renderizada — `site_test.rb` só lê `_site/` já buildado, e
  Jekyll não builda nada fora de `_posts/`/`_drafts/` como post. Resolvido com
  `test/fixtures/site_posts/` (duas fixtures, uma `project: true` e outra
  comum) symlinkadas em `_posts/` só durante `tools/check.sh`, via `trap` no
  `EXIT` que desfaz o link mesmo se um passo anterior falhar. Sem isso, as
  fixtures teriam que morar em `_posts/` de verdade (poluindo o histórico
  antes do Step 5) ou o teste teria que buildar o site sozinho (duplicando o
  que `tools/test.sh` já faz).
- Red: `docker compose run --rm site bash tools/check.sh` com as fixtures
  symlinkadas, `_layouts/project-post.html` ainda inexistente — build
  completou com aviso do Jekyll ("Layout 'project-post' … does not exist"),
  sem quebrar o gate; `site_test.rb`: 14 runs, 1 falha (por asserção: link do
  repositório ausente no HTML), 0 erros. Confirma que o teste falha pelo
  motivo certo, não por build quebrado.
- Green: `_layouts/project-post.html` com `layout: post` no próprio front
  matter e o bloco do repositório antes de `{{ content }}` — herança de
  layout, nenhum arquivo do tema sobrescrito (Decisions/Audit item 3).
  `_drafts/template-projeto.md` com as cinco seções da regra 13 em headings
  `##`, comentários HTML de orientação (sem efeito em produção), front matter
  válido (`project: true`, `layout: project-post`, `repo` placeholder) —
  conferido junto do validador no gate.
- `auditoria-de-impacto` rodada sobre o diff antes do commit: sem efeitos
  irreversíveis (o symlink é local e desfeito pelo trap; testado que uma
  falha de `ln -s` por colisão de nome não apaga nada, porque só entra no
  array de limpeza depois de criado com sucesso). Achado registrado, não
  bloqueante: as fixtures usam título `[RASCUNHO]`, que exige `noindex: true`
  no validador — vai quebrar o gate quando o `noindex` for removido no marco
  de saída do MVP, se as fixtures não forem ajustadas junto. Ver State
  Handover → Watch out.
- Refactor: texto do bloco do repositório é pt-BR fixo (`_data/locales/pt-BR.yml`
  não tem chave equivalente a "repositório do projeto"), comentado no próprio
  layout como dívida de i18n da fase 2. Classes CSS reusam utilitários já
  presentes no tema (Bootstrap), sem `style` inline e sem copiar markup de
  `post.html`.
- Gate: `docker compose run --rm site bash tools/check.sh` — validador 26
  runs/0 falhas; build produção + htmlproofer 10 arquivos/16 links internos/0
  falhas; `site_test.rb` 14 runs/0 falhas/0 erros. `_posts/` conferido depois:
  só o `.placeholder` pré-existente, sem symlink residual.
- Commit `c971568`. Step 5 decomposto na Checklist.

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

### 2026-09-18 — Step 3

- [x] Red — `docker compose run --rm site bundle exec ruby -Itest test/site_test.rb` (antes do Green) — 12 runs, 19 assertions, 7 failures, 0 errors
- [x] Green — mesmo comando, após `_config.yml`/`metadata-hook.html`/`contact.yml`/`about.md` — 12 runs, 19 assertions, 0 failures, 0 errors
- [x] Auditoria de impacto — sem achados; nenhum efeito irreversível alcançável (sem push)
- [x] Suíte de testes (gate completo) — `docker compose run --rm site bash tools/check.sh` — validador 26 runs/0 falhas; build produção + htmlproofer 6 arquivos/12 links internos/0 falhas; `site_test.rb` 12 runs/0 falhas
- [x] Análise estática / lint — `bash -n tools/check.sh` — sem saída (ok); `ruby -wc tools/validate-front-matter.rb` — `Syntax OK` (arquivo não tocado nesta etapa, conferido por precaução)
- [x] Artefato visível — `_site/index.html`, `_site/about/index.html` gerados pelo `tools/test.sh`; conferência de conteúdo feita por leitura do HTML nos testes (lang, meta robots, links), não por inspeção visual nesta etapa — a inspeção com `tools/run.sh` fica para o Step 5, quando houver posts reais a navegar

### 2026-09-18 — Step 4

- [x] Red — `docker compose run --rm site bash tools/check.sh` (fixtures symlinkadas, layout ainda inexistente) — validador 26 runs/0 falhas; build com aviso de layout ausente, sem falhar; `site_test.rb` 14 runs/1 falha/0 erros, falha por asserção (link ausente)
- [x] Green — mesmo comando, após `_layouts/project-post.html` e `_drafts/template-projeto.md` — validador 26 runs/0 falhas; build produção + htmlproofer 10 arquivos/16 links internos/0 falhas; `site_test.rb` 14 runs/0 falhas/0 erros
- [x] Auditoria de impacto — sem efeitos irreversíveis; achado não bloqueante sobre `[RASCUNHO]` das fixtures vs. `noindex`, registrado no State Handover
- [x] Suíte de testes (gate completo) — `docker compose run --rm site bash tools/check.sh` — mesmos números do Green acima
- [x] Análise estática / lint — `bash -n tools/check.sh` — sem saída (ok); nenhum `.rb` alterado nesta etapa
- [x] Artefato visível — `_site/posts/fixture-post-projeto/index.html` e `_site/posts/fixture-post-comum/index.html` gerados durante o gate (symlinks efêmeros); conferência de conteúdo por leitura do HTML nos testes, igual ao Step 3 — inspeção visual com posts reais fica para o Step 5
- [x] Limpeza pós-gate — `ls _posts/` após `check.sh` — só `.placeholder` pré-existente, nenhum symlink de fixture residual

## Wrap up

Autor único, sem PR (plan → Tooling → Git): a entrega é o merge de `blog-1-mvp` em `main`.

- [ ] Merge `blog-1-mvp` → `main` e push (é o deploy: Step 6)
- [ ] Spec linkado ao issue — n/a, `BLOG-1` é identificador local registrado no próprio `spec.md`
- [ ] Follow-up registrado: `BLOG-2` (marco de saída do MVP) como nova seção em `plan.md` quando começar
- [ ] `spec.md` `status:` → `implemented` quando a Verification do Step 6 fechar
