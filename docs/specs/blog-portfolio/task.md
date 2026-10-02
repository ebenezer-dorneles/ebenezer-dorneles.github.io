# Tasks — Blog de portfólio (Ciência de Dados & Dev)

<!--
No frontmatter — spec.md is the source of truth.
Execution tracking for the current implementation pass. See plan.md for the
step-by-step and spec.md for scope decisions.
-->

## Checklist

Passada: **BLOG-2 Fase técnica** (D-2, D-3, D-5, D-10 — reescrita de `test/site_test.rb` para invariantes estruturais, rename das fixtures sem `[RASCUNHO]`, Verification externa pré-flip e supersede do Step 6 do BLOG-1).
Modo de decomposição: **tier M — só a próxima fase aberta**. Fases 2/3/4 ficam em nível
de fase até Phase 1 fechar. Histórico completo das passadas anteriores (BLOG-1 Steps 0–5 e
BLOG-3 Fases 1–3 + verify) no Execution Log abaixo.

> **BLOG-1 Step 6 — desbloqueio parcial em 2026-09-29:** D-6 (`etl-prf-data` público) e
> D-7 (Pages Source = GitHub Actions) concluídos pelo autor. Falta o primeiro
> `git push origin main` (ou merge de `blog-1-mvp` em `main`) para disparar
> `.github/workflows/pages-deploy.yml` e ativar o environment `github-pages`. **Esse
> push é precondição operacional da Phase 3 deste plan (D-5 Verification externa)** —
> continua pendente da decisão do autor, fora do SSD. Subitens do Step 6 permanecem
> desmarcados até Phase 4 (D-10) aplicar o supersede formal.

- [x] **BLOG-2 Fase técnica Baseline** — HEAD `750a3d4`, `tools/check.sh` → validador `26/29/0/0`, htmlproofer `16 arquivos/0 falhas`, `site_test.rb` `22/37/6/0` (6 falhas pré-existentes de `686c5c0` confirmadas pelos mesmos nomes de teste). Ver Verification.
- [ ] **Phase 1 — Reescrever `test/site_test.rb` para invariantes estruturais (D-2)**
  - [ ] Red: para cada um dos 6 testes falhando no baseline, substituir asserção por slug fictício por invariante estrutural e confirmar que a nova asserção falha pelo motivo certo (não pela mesma mensagem "post não foi gerado" / "não foi gerado" / `nil to not be nil` do baseline)
  - [ ] Green: aplicar as 6 reescritas conforme Strategy (a–d) e Coverage da Phase 1 — home via `<time datetime>` + ordem decrescente; tags via iteração sobre posts publicados; `search.json.size == publicados.size`; capacidades (Rouge/Mermaid/image) descobertas dinamicamente no primeiro post que as declara
  - [ ] Refactor: extrair helper `published_posts` em `SiteTest` se ≥ 3 métodos usarem; preservar tags `# @spec` existentes (BLOG-3) sobre os métodos reescritos — se cobertura crescer, somar à tag em vez de substituir
  - [ ] Done when: `tools/check.sh` → `site_test.rb` `22/≥37/0/0` (todas verdes); `grep -c "# @spec" test/site_test.rb` continua 22; `grep -nE "RASCUNHO|analise-exploratoria|api-tarefas-ruby|visualizando-pipelines" test/site_test.rb` sem saída; `ruby -wc` limpo
  - [ ] Auditoria de impacto formal via skill (foco: "6 asserções reescritas sem perder cobertura de AC")
- [ ] **Phase 2 — Renomear fixtures sem `[RASCUNHO]` (D-3)** · pendente até Phase 1 fechar
- [ ] **Phase 3 — Verification externa pré-flip (D-5)** · pendente até Phase 2 fechar + autor executar `git push origin main`
- [ ] **Phase 4 — Supersede subitens do Step 6 do BLOG-1 em `task.md` (D-10)** · pendente até Phase 3 fechar

## State Handover

- **Done nesta sessão (2026-10-02):**
  - `ssd-plan` escreveu `## Plan — BLOG-2 Fase técnica` em `plan.md`
    (4 fases cobrindo D-2/D-3/D-5/D-10, Coverage com 13 ACs testados
    + 7 diferidos explicitamente). Commit `750a3d4`
    (`docs(plan): abre BLOG-2 Fase técnica (D-2, D-3, D-5, D-10)`).
    spec.md `phase: validating → planning`.
  - `ssd-task` decompôs **só a Phase 1** (tier M). Baseline em HEAD
    `750a3d4` capturada: validador `26/29/0/0`, htmlproofer `16 arquivos
    / 0 falhas`, `site_test.rb` `22/37/6/0`. As 6 falhas são as mesmas
    do baseline BLOG-3 (herdadas de `686c5c0`), pelos mesmos nomes de
    teste. Ver Verification → BLOG-2 Fase técnica Baseline.
  - spec.md `phase: planning → implementing`.
- **Next (Phase 1 — D-2):**
  - Red para cada um dos 6 testes: substituir asserção por slug e rodar
    `docker compose run --rm site bundle exec ruby -Itest test/site_test.rb`
    para confirmar a nova mensagem de falha (não a legada).
  - Green: aplicar reescritas (a) home via `<time datetime>` ordenada;
    (b) tags via iteração sobre `_site/posts/*/index.html`; (c)
    `search.json.size == publicados.size`; (d) capacidades (Rouge,
    Mermaid, image) via primeiro post que declara cada uma.
  - Refactor: avaliar extração de helper `published_posts`; preservar
    tags `# @spec` existentes.
  - Done when gate: `tools/check.sh` → `site_test.rb` `22/≥37/0/0`;
    `grep -nE "RASCUNHO|analise-exploratoria|api-tarefas-ruby|visualizando-pipelines" test/site_test.rb` sem saída.
  - Pré-commit: `auditoria-de-impacto` com foco em "regressão de AC".
- **Blockers / open decisions:**
  1. **Fase 3 bloqueada** até autor executar `git push origin main` (ou
     merge de `blog-1-mvp` em `main`). Esta sessão **não** empurra sem
     confirmação explícita do autor — a Phase 1 e a Phase 2 podem ser
     feitas inteiras localmente antes do push.
- **Watch out:**
  - Todo comando Ruby/Jekyll roda **dentro** do container
    (`docker compose run --rm site …`); Ruby 4.0.6 do host geraria lock
    com `BUNDLED WITH` 4.x.
  - `test/site_test.rb` faz `skip` se `_site/` não existir: rodar via
    `tools/check.sh` (que builda antes), senão a suíte "passa" sem verificar.
    Para iteração rápida da Phase 1, pode-se usar `bundle exec ruby -Itest
    test/site_test.rb` depois de 1 `tools/check.sh` inicial, aproveitando
    o `_site/` gerado.
  - Nome do método `test_indice_de_busca_lista_os_tres_posts_ficticios`
    contradiz a invariante estrutural pós-D-2 (não cita mais "três posts
    fictícios"). **Rename está fora do escopo da Phase 1** (plan Review
    & code standards). Fica em Deferred do plan.
  - Fixtures `test/fixtures/site_posts/*.md` continuam com `[RASCUNHO]`
    no título até Phase 2 (D-3). Hoje inofensivo (`noindex: true`);
    `check_draft_guard` só reprova quando `noindex` ≠ true.
  - Diff da Phase 1 é código real (não comentário como no BLOG-3) —
    `auditoria-de-impacto` tem material concreto a avaliar.
  - Push `blog-1-mvp` → `main` continua pendente da decisão do autor.
    Dois commits locais à frente de `origin/blog-1-mvp`
    (`94ba825`, `750a3d4`).

## Deviations

- 2026-09-29 — 5 testes de `test/site_test.rb` receberam tags não-conformes
  ao formato estrito da Strategy (`FR-N`/`AC-N.M`/`D-N`/`AU-N`), porque a
  matriz Coverage do próprio plan registra essas linhas com títulos
  informais ("Config pt-BR", "Exclude do `_config.yml`") sem FR/AC/D
  associado: (a) `test_home_declara_lang_pt_br` → `# @spec (decisão pt-BR)`;
  (b) `test_diretorio_test_nao_publicado`, `test_diretorio_docs_nao_publicado`,
  `test_compose_yaml_nao_publicado` → `# @spec (exclude _config.yml)`;
  (c) `test_diretorio_draft_nao_publicado` → `# @spec AC-2.1 (exclude _config.yml)`
  (tem AC-2.1 formal + marker). Intent do plan (rastreabilidade
  test→coverage) preservado porque as strings dos markers batem com os
  títulos das rows Coverage.
  · class: local
  · action: continued
- 2026-09-29 — Plan de BLOG-3 § Context registra "26 métodos (25 unit + 2
  CLI)" e § Phases Fase 1 Done-when registra `grep -c "# @spec"
  test/validate_front_matter_test.rb → 25`. O arquivo tem 24 unit + 2 CLI =
  26 métodos. Interpretado como off-by-one de contagem (não decisão de
  design): aplicadas 26 tags, uma por método, e o cross-check da Fase 3
  passa a exigir igualdade `grep tags = grep defs` em vez do literal `25`.
  Nenhum comportamento nem escopo muda; a intenção do plan ("tag em cada
  `def test_*`") é preservada.
  · class: local
  · action: continued
- 2026-09-29 — Plan de BLOG-3 § Context afirma "check.sh verde no último
  commit (`b1e1bfe`)". A baseline coletada em HEAD `e1cb549` mostra 6 falhas
  em `test/site_test.rb`, todas resíduo do commit `686c5c0`
  ("chore(content): remove posts fictícios de prototipagem"), que precede
  `b1e1bfe`. Testes afetados (todos citando slugs removidos ou tag `ruby`
  daí derivada): `test_post_tecnico_tem_highlight_e_mermaid`,
  `test_indice_de_busca_lista_os_tres_posts_ficticios`,
  `test_imagem_do_post_e_servida_e_referenciada`,
  `test_home_lista_posts_em_ordem_cronologica_decrescente`,
  `test_tempo_de_leitura_visivel_no_post`,
  `test_tags_tem_pagina_por_tag_usada`. A condição "Done when: `check.sh`
  verde" da Fase 2 do BLOG-3, e a ordem "BLOG-3 antes de BLOG-2 Fase técnica"
  registrada em `### Deferred` do plan, ficam ambas em conflito com a
  realidade do gate.
  · class: plan-affecting
  · action: handed to plan

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

### 2026-09-18 — Step 5: três posts fictícios

- **Spike antes do Red:** para não escrever asserções sobre caminhos
  adivinhados, os três posts e a imagem foram criados primeiro, e
  `tools/test.sh` (só build, sem o gate completo) rodou isolado para
  inspecionar `_site/` gerado antes de fixar os testes. Confirmado por
  build real: `Jekyll::Utils.slugify("Ciência de Dados")` →
  `"ciência-de-dados"` (acentuado, minúsculo, espaço trocado por hífen — o
  gem preserva caracteres acentuados como alfanuméricos); o diretório em
  disco usa esse valor sem percent-encoding (`_site/categories/ciência-de-
  dados/`), só a URL no `href` é que sai percent-encoded. Índice de busca
  em `assets/js/data/search.json`, um JSON por post com `title`/`url`/
  `categories`/`tags`/`content`.
- **Achado corrigido antes do commit, fora do plan:** `image.path` no front
  matter do post com Mermaid apontava para o caminho completo
  (`/assets/img/posts/visualizando-pipelines/diagrama.png`), igual ao
  `media_subpath`. O include `media-url.html` do tema **sempre** prefixa
  `media_subpath` a `page.image.path`, então os dois juntos duplicavam o
  caminho (`.../visualizando-pipelines/assets/img/posts/visualizando-
  pipelines/diagrama.png`), e o `htmlproofer` reprovou a imagem inexistente.
  Corrigido: `image.path` passou a ser só `diagrama.png` (o nome do
  arquivo), com `media_subpath` provendo o diretório — é assim que o tema
  espera receber os dois campos juntos, confirmado lendo
  `_includes/media-url.html` do gem.
- Red: com os três posts temporariamente movidos para fora de `_posts/`
  (`mv` para fora do repositório, não `git rm`), `docker compose run --rm
  site bash tools/check.sh` — os 7 casos novos falharam por asserção (post
  ausente, categoria/tag ausente, índice de busca sem as URLs), 0 erros.
  Os testes que chamam `read(...)` direto foram escritos com um
  `assert exists?(...)` antes, para a ausência de arquivo dar falha de
  asserção e não `Errno::ENOENT` (erro, não falha) — decisão de design dos
  testes, não do plan.
- Green: posts restaurados (`mv` de volta); mesmo comando — 22 runs, 55
  assertions, 0 failures, 0 errors. `test_categoria_de_um_nivel_...` já
  passava mesmo no Red, porque as fixtures da Etapa 4 (`project: true` com
  `categories: [Desenvolvimento]`) já bastam para exercitar o trigger
  desabilitado — o teste cobre comportamento geral do tema, não é exclusivo
  destes 3 posts; registrado, não é um problema.
- Refactor: conferência visual com `docker compose run -d --rm --service-
  ports site bash tools/run.sh -H 0.0.0.0` + `curl` em home, `/posts/api-
  tarefas-ruby/`, `/categories/ci%C3%AAncia-de-dados/`, `/tags/ruby/`,
  `/about/` e `/assets/js/data/search.json` — todos HTTP 200 com o conteúdo
  esperado (link do repositório, posts listados, índice de busca com o
  post técnico).
- `auditoria-de-impacto` rodada sobre o diff antes do commit: sem efeitos
  irreversíveis (`noindex: true` continua ativo, sem push); sem achados
  bloqueantes. Confirmado: nenhuma colisão de nome entre os posts reais
  (`2026-01-05`/`10`/`15`) e as fixtures da Etapa 4 (`2026-01-01`/`02`).
- Gate: `docker compose run --rm site bash tools/check.sh` — validador 26
  runs/0 falhas; build produção + htmlproofer 19 arquivos/26 links
  internos/0 falhas; `site_test.rb` 22 runs/55 assertions/0 falhas/0 erros.
- Commit `3298eae`. Step 6 decomposto na Checklist.

### 2026-09-29 — BLOG-2 D-6: repositório `etl-prf-data` público

- **Ação (fora do repo do blog, painel do GitHub):** autor liberou o
  repositório `github.com/ebenezer-dorneles/etl-prf-data` como público.
- **Referência afetada no blog:** `_posts/2026-09-29-etl-dados-prf.md:8`
  (`repo: https://github.com/ebenezer-dorneles/etl-prf-data`) e link no
  corpo do post (linha 365, "O código completo do projeto está disponível
  no [GitHub](https://github.com/ebenezer-dorneles/etl-prf-data)").
- **Efeito no gate hoje:** nenhum. `htmlproofer` roda com
  `--disable-external` (por design — internet-off no CI), então o link
  externo não é checado no `check.sh`. AC-3.4 pelo teste automatizado
  continua verde através do HTML gerado.
- **Efeito no futuro:** desbloqueia D-5 do BLOG-2 (Verification externa
  pré-flip) — o passo manual "todo post `project: true` tem `repo` que
  responde HTTP 200 para leitor deslogado" (AC-18.3) agora passa para
  este post. Antes, esse item estaria travado.
- **Consequência para o pipeline:** D-6 sai da lista de itens abertos
  do BLOG-2 Fase técnica quando plan for reescrito para BLOG-2.

### 2026-09-29 — BLOG-2 D-7: Pages Source trocado para GitHub Actions

- **Ação (fora do repo, painel do GitHub):** autor trocou, em Settings →
  Pages do repositório `ebenezer-dorneles/ebenezer-dorneles.github.io`,
  o campo **Build and deployment → Source** de `Deploy from a branch`
  para `GitHub Actions`.
- **Estado do repo:** nenhuma edição de arquivo. O workflow
  `.github/workflows/pages-deploy.yml` (do Chirpy starter) já existia
  desde o Step 1 do BLOG-1 e agora é o job que o GitHub Pages usa para
  publicar.
- **Efeito imediato:** nenhum — o site ainda não foi publicado. Só o
  próximo `git push origin main` (ou merge de `blog-1-mvp` em `main`)
  vai disparar o workflow e ativar o environment `github-pages`.
- **Consequência para o pipeline:** desbloqueia o restante do BLOG-1
  Step 6 (Merge/push + smoke) e retira D-7 da lista de itens abertos
  do BLOG-2 Fase técnica quando plan for reescrito para BLOG-2.
- **Watch out mantido:** o workflow ainda não invoca `tools/check.sh`
  como gate — continua com os passos inline `Build site`/`Test site`
  do starter. Dívida separada, endereçada quando o workflow for tocado
  (BLOG-2 Fase técnica ou uma issue própria de infra de CI).

### 2026-09-29 — BLOG-3 Phases 2 e 3: tag de `test/site_test.rb` + cross-check

- **Phase 2 (Green — aplicação):** inseridos 22 `# @spec …` em
  `test/site_test.rb`, um por método `def test_*`, indent-2, sem linha
  em branco entre tag e def (Strategy). Mapeamento AC→teste segue a
  matriz Coverage do plan.
- **Tags não-formais registradas** (local deviation abaixo):
  - `test_home_declara_lang_pt_br` → `# @spec (decisão pt-BR)` (a
    decisão pt-BR do BLOG-1 não tem D-N formal no spec Decisions, que
    usa bullets; plan Phase 2 covers registra literalmente como
    "decisão pt-BR (D do BLOG-1)").
  - `test_diretorio_test_nao_publicado`, `test_diretorio_docs_nao_publicado`,
    `test_compose_yaml_nao_publicado` → `# @spec (exclude _config.yml)`
    (Coverage lista essas linhas como "Exclude do _config.yml", sem FR/AC
    correspondente — são invariantes de config, não requisitos numerados).
  - `test_diretorio_draft_nao_publicado` → `# @spec AC-2.1 (exclude _config.yml)`
    (esse tem AC-2.1 formal — indireto — em Coverage; o marker preserva a
    origem da linha em `exclude:`).
- **Gate full** `docker compose run --rm site bash tools/check.sh` —
  validador `26/29/0/0` (idem baseline), htmlproofer `16 arquivos / 0
  falhas`, `site_test.rb` **22 runs / 37 assertions / 6 failures / 0
  errors / 0 skips** (idem baseline `22/37/6/0`). As 6 falhas são
  exatamente as mesmas do baseline, com os mesmos nomes de teste:
  `test_tags_tem_pagina_por_tag_usada`, `test_tempo_de_leitura_visivel_no_post`,
  `test_post_tecnico_tem_highlight_e_mermaid`,
  `test_home_lista_posts_em_ordem_cronologica_decrescente`,
  `test_imagem_do_post_e_servida_e_referenciada`,
  `test_indice_de_busca_lista_os_tres_posts_ficticios`. Invariante estrita
  do Amendment 2026-09-29 satisfeita — resolve implicitamente a Deviation
  plan-affecting daquela data (BLOG-2 D-2 continua responsável por curar
  as 6 falhas depois de BLOG-3 fechar).
- **Sintaxe:** `ruby -wc test/site_test.rb` → `Syntax OK`.
- **Phase 3 (cross-check):**
  - `grep -c "# @spec" test/*.rb` → 22 + 26 = 48
  - `grep -c "def test_" test/*.rb` → 22 + 26 = 48
  - Igualdade: 48 = 48 (invariante "diff só de comentários" preservada).
  - Walkthrough manual da matriz Coverage do plan × grep `# @spec` — cada
    AC listado como "testado" aparece em ao menos uma linha; casos
    combinados (AC-11.1 na vfm:23, AC-19.1+19.2 na site:147) preservados.
    Nenhum AC "testado" ficou órfão. Nota: Coverage referencia números
    de linha pré-tag (originais); pós-tag as linhas mudam, mas o
    mapeamento (arquivo:def_name → AC) permanece — o Amendment 2026-09-29
    já explicitou que a Coverage não é reescrita nesta issue.
- **Diff acumulado (BLOG-3):** `git diff --stat test/` → 48 insertions,
  0 deletions, 2 arquivos. Filtragem `git diff | grep -E "^[+-]" | grep
  -vE "^[+-]{3} |^[+-]\s*$|^[+-]\s*#"` → saída vazia (zero linhas
  não-comentário alteradas).
- **Não feito nesta sessão** (pendente do autor):
  - Invocação formal da skill `auditoria-de-impacto` sobre o diff.
  - Commit único de BLOG-3 (as três fases num commit só, conforme
    plan Phase 1 "commit único da Fase" — o Amendment não repartiu).

### 2026-09-29 — BLOG-3 Phase 1: tag de `test/validate_front_matter_test.rb`

- **Gate reentrada:** Amendment 2026-09-29 no plan.md desbloqueou BLOG-3
  (opção (b) do autor). Precondição formal satisfeita, sem CR aberto.
- **Contagem real do arquivo:** 26 métodos `test_*` (24 unit + 2 CLI). Plan
  Context registra "26 métodos (25 unit + 2 CLI)" e Phase 1 Done-when
  registra `grep -c "# @spec" = 25`. Ambas são off-by-one em relação ao
  arquivo. Tratado como **local** (não plan-affecting): intent inequívoco
  ("tag em cada `def test_*`"); aplicadas 26 tags (uma por método), e o
  cross-check da Fase 3 usa igualdade `grep tags = grep defs` (26 = 26) em
  vez do literal `= 25` do plan. Registrado abaixo em Deviations.
- **Green (aplicação):** inserido `# @spec …` na linha imediatamente antes
  de cada `def test_*`, indent-2, sem linha em branco entre a tag e o `def`
  (Strategy). CLI usa marcador `(CLI)`; tests de regressão da auditoria
  usam marcador `(auditoria-de-impacto)` (sem FR prefixo, conforme
  Strategy). Mapeamento AC→teste segue a matriz Coverage do plan.
- **Gate targeted:** `docker compose run --rm site bundle exec ruby -Itest
  test/validate_front_matter_test.rb` — **26 runs, 29 assertions, 0 failures,
  0 errors, 0 skips** (idêntico à baseline).
- **Diff:** `git diff --stat test/validate_front_matter_test.rb` — 26
  insertions, 0 deletions. Regex `^[+-]` filtrado por `^[+-]\s*#` +
  cabeçalho vazio → **zero linhas não-comentário alteradas**. Nenhum `def`,
  `assert*`, `refute*`, `require`, `class` ou constante mudou.
- **Sintaxe:** `docker compose run --rm site ruby -wc
  test/validate_front_matter_test.rb` — `Syntax OK`.
- **Auditoria de impacto** e commit pendentes — ver Blockers/Next.

### 2026-09-29 — BLOG-3: transição de pass, baseline e handoff a plan

- **Gate para ssd-task (BLOG-3):** `## Plan — BLOG-3` presente em plan.md;
  `Spec revision: 4` bate com `spec-revision: 4` do spec; rev 4 aprovada em
  `## Approvals` (autor, 2026-09-29); nenhum CR aberto. Precondição formal
  satisfeita.
- **Estado do BLOG-1:** Steps 0–5 fechados; Step 6 continua aberto e bloqueado
  pela decisão do autor sobre Pages → Source. Não é regredido nem re-executado
  aqui — apenas movido para nota no topo da Checklist enquanto o pass ativo é
  BLOG-3.
- **Reset de Checklist e State Handover** para o novo pass, mantendo Execution
  Log e agora também `## Deviations` (nova seção, criada nesta sessão pela
  primeira vez — a estrutura da task.md do BLOG-1 antecede o contrato atual
  do ssd-task e não a incluía).
- **Baseline** rodada com `docker compose run --rm site bash tools/check.sh`
  em HEAD `e1cb549`. Números exatos em `## Verification → 2026-09-29 —
  BLOG-3 Baseline`. As 6 falhas do `site_test.rb` são pré-existentes desde
  `686c5c0` — confirmação por `git log --oneline` e leitura das mensagens
  de erro (asserções sobre slugs de posts fictícios já removidos).
- **Deviation registrada** (acima). Nenhuma edição de código nem de spec
  nesta sessão. Handoff a `ssd-plan` para amendment de plan de BLOG-3 ou
  para escrever `## Plan — BLOG-2 Fase técnica` primeiro (ver Blockers).

### 2026-10-02 — BLOG-2 Fase técnica: transição de pass, plan escrito, baseline

- **Gate para ssd-task (BLOG-2 Fase técnica):** `## Plan — BLOG-2 Fase técnica`
  presente em `plan.md` (commit `750a3d4`); `Spec revision: 4` bate com
  `spec-revision: 4` do spec; rev 4 aprovada em `## Approvals` (autor,
  2026-09-29); nenhum CR aberto. Precondição formal satisfeita.
- **Estado anterior preservado:** BLOG-3 permanece verified (`e87db58`);
  Steps 0–5 do BLOG-1 fechados; Step 6 do BLOG-1 aguarda push/merge
  (externo ao SSD) + Phase 4 deste plan (D-10 supersede).
- **Reset de Checklist e State Handover** para a nova pass (BLOG-2 Fase
  técnica), mantendo `## Deviations` e `## Execution Log` como append-only.
  `spec.md` frontmatter atualizado: `phase: validating → planning` (pelo
  `ssd-plan`) e logo depois `planning → implementing` (por este `ssd-task`,
  primeira execução da issue).
- **Decomposição tier M:** só a Phase 1 (D-2) decomposta em sub-itens.
  Fases 2/3/4 ficam em nível de fase até Phase 1 fechar.
- **Baseline** rodada com `docker compose run --rm site bash tools/check.sh`
  em HEAD `750a3d4`. Resultado abaixo em Verification → BLOG-2 Fase técnica
  Baseline. **Confirmado:** `22/37/6/0` em `site_test.rb` com os 6 nomes
  esperados pelo plan (sem drift desde o baseline do BLOG-3 em `e1cb549`).
- **Sem edit de código nesta sessão.** Nenhum arquivo em `test/`, `_posts/`,
  `_config.yml`, `tools/`, `_layouts/`, `_includes/`, `.github/` ou
  `_data/` tocado. Handoff aberto para a próxima sessão iniciar o Red da
  Phase 1.

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

### 2026-09-18 — Step 5

- [x] Red — `docker compose run --rm site bash tools/check.sh` (posts reais fora de `_posts/`) — validador 26 runs/0 falhas; build 10 arquivos/16 links/0 falhas; `site_test.rb` 22 runs/35 assertions/7 falhas/0 erros, todas as 7 falhas novas por asserção
- [x] Green — mesmo comando, com os três posts restaurados — validador 26 runs/0 falhas; build produção + htmlproofer 19 arquivos/26 links internos/0 falhas; `site_test.rb` 22 runs/55 assertions/0 falhas/0 erros
- [x] Auditoria de impacto — sem efeitos irreversíveis; sem achados bloqueantes; confirmado sem colisão de nome com as fixtures da Etapa 4
- [x] Suíte de testes (gate completo) — `docker compose run --rm site bash tools/check.sh` — mesmos números do Green acima
- [x] Análise estática / lint — nenhum `.rb`/`.sh` alterado nesta etapa
- [x] Artefato visível — conferência visual via `tools/run.sh` + `curl`: home (200, lista os 3 posts), `/posts/api-tarefas-ruby/` (200, link do repositório), `/categories/ci%C3%AAncia-de-dados/` (200, lista os posts da categoria), `/tags/ruby/` (200), `/about/` (200), `/assets/js/data/search.json` (200, contém o post técnico)

### 2026-09-29 — BLOG-3 Phases 2 e 3

- **HEAD (working tree):** `e1cb549` + Phases 1+2+3 uncommitted (dois
  arquivos, `test/validate_front_matter_test.rb` e `test/site_test.rb`,
  48 insertions totais)
- **Red — n/a** (substituto: baseline + igualdade estrita, per Amendment
  2026-09-29).
- **Green (full — per Amendment):** `docker compose run --rm site bash
  tools/check.sh`
  - validador: **26 runs / 29 assertions / 0 failures / 0 errors / 0
    skips** (idem baseline)
  - htmlproofer: **16 arquivos / 0 falhas** (idem baseline; `Ran on 16
    files!` + `HTML-Proofer finished successfully`)
  - site_test.rb: **22 runs / 37 assertions / 6 failures / 0 errors / 0
    skips** (idem baseline)
  - Conjunto exato de 6 falhas confirmado por nome de teste:
    `test_tags_tem_pagina_por_tag_usada`,
    `test_tempo_de_leitura_visivel_no_post`,
    `test_post_tecnico_tem_highlight_e_mermaid`,
    `test_home_lista_posts_em_ordem_cronologica_decrescente`,
    `test_imagem_do_post_e_servida_e_referenciada`,
    `test_indice_de_busca_lista_os_tres_posts_ficticios` — idem baseline.
- **Cross-check da tag (Phase 3):**
  - `grep -c "# @spec" test/site_test.rb` → 22
  - `grep -c "# @spec" test/validate_front_matter_test.rb` → 26
  - `grep -c "def test_" test/site_test.rb` → 22
  - `grep -c "def test_" test/validate_front_matter_test.rb` → 26
  - Totais: 48 tags = 48 defs (invariante "1 tag por método")
- **Análise estática (arquivos tocados):** `docker compose run --rm site
  ruby -wc test/site_test.rb test/validate_front_matter_test.rb` →
  `Syntax OK` (ambos)
- **Diff acumulado:** `git diff --stat test/` → 48 insertions(+),
  0 deletions, 2 arquivos. Filtragem
  `git diff | grep -E "^[+-]" | grep -vE "^[+-]{3} |^[+-]\s*$|^[+-]\s*#"`
  → saída vazia. Nenhum `def`, `assert*`, `refute*`, `require`, `class`
  ou constante mudou.
- **Auditoria de impacto:** pendente (pré-commit; skill formal não
  invocada nesta sessão — checagem equivalente por grep registrada acima)
- **Artefato visível:** n/a (comentários no código)

### 2026-09-29 — BLOG-3 Phase 1

- **HEAD (working tree):** `e1cb549` + Phase 1 uncommitted
- **Red — n/a** (substituto: baseline abaixo). Rename mecânico de comentários
  não tem asserção de comportamento a falhar; o que se evita é churn
  acidental de teste, capturado pela igualdade estrita de contagem
  pré/pós.
- **Green (targeted, per Amendment):** `docker compose run --rm site
  bundle exec ruby -Itest test/validate_front_matter_test.rb`
  → 26 runs, 29 assertions, 0 failures, 0 errors, 0 skips
  (**idem baseline** `26/29/0/0`)
- **Cross-check da tag:** `grep -c "# @spec"
  test/validate_front_matter_test.rb` → 26; `grep -c "def test_"
  test/validate_front_matter_test.rb` → 26 (bate).
- **Análise estática (arquivo tocado):** `docker compose run --rm site
  ruby -wc test/validate_front_matter_test.rb` → `Syntax OK`
- **Diff:** `git diff --stat` → `26 insertions(+)`; filtragem de `^[+-]`
  por `^[+-]\s*#` deixa 0 linhas não-comentário. Nenhum `def`, `assert*`,
  `refute*`, `require`, `class` ou constante mudou.
- **Full suite (check.sh):** ainda não rerun (não obrigatório para Fase 1
  targeted; a igualdade estrita `26/29/0/0` no validador basta). Será
  rodada no fim da Fase 2 conforme Amendment.
- **Auditoria de impacto:** pendente (pré-commit)
- **Artefato visível:** n/a (comentários no código)

### 2026-09-29 — BLOG-3 Baseline

- **HEAD:** `e1cb549` (`docs(plan): abre BLOG-3 com matriz Coverage dos 41 ACs`)
- **Comando:** `docker compose run --rm site bash tools/check.sh`
- **Validador** (`test/validate_front_matter_test.rb` + CLI):
  26 runs, 29 assertions, 0 failures, 0 errors, 0 skips
- **Build produção + htmlproofer:** 16 arquivos gerados; 22 links internos
  verificados; 0 falhas
- **`test/site_test.rb`:** 22 runs, 37 assertions, **6 failures**, 0 errors,
  0 skips — falhas pré-existentes desde `686c5c0` (remoção dos posts
  fictícios), listadas em Execution Log e Deviations desta sessão.
- **Interpretação:** validador e vfm_test.rb servem de baseline sólido para
  a Fase 1 do BLOG-3 (invariante "26 runs / 29 assertions / 0 failures / 0
  errors" antes e depois). `site_test.rb` **não** tem baseline verde para a
  Fase 2; a contagem exata pré-comentário fica registrada aqui como
  referência caso a escolha (b) do Blocker seja adotada
  (`22 runs / 37 assertions / 6 failures / 0 errors` como invariante do
  "diff só de comentários").

### 2026-10-02 — BLOG-2 Fase técnica Baseline

- **HEAD:** `750a3d4` (`docs(plan): abre BLOG-2 Fase técnica (D-2, D-3, D-5, D-10)`)
- **Comando:** `docker compose run --rm site bash tools/check.sh`
- **Validador** (`test/validate_front_matter_test.rb` + CLI):
  26 runs, 29 assertions, 0 failures, 0 errors, 0 skips (verde)
- **Build produção + htmlproofer:** 16 arquivos gerados; 0 falhas
  (`Ran on 16 files!` + `HTML-Proofer finished successfully.`)
- **`test/site_test.rb`:** 22 runs, 37 assertions, **6 failures**,
  0 errors, 0 skips. Nomes exatos das 6 falhas (ordem de execução do
  minitest com `--seed 51654`):
  1. `test_post_tecnico_tem_highlight_e_mermaid` (site_test.rb:149) —
     "post não foi gerado"
  2. `test_imagem_do_post_e_servida_e_referenciada` (site_test.rb:157) —
     "post não foi gerado"
  3. `test_indice_de_busca_lista_os_tres_posts_ficticios` (site_test.rb:172) —
     espera URL `/posts/analise-exploratoria-vendas/` (slug removido em
     `686c5c0`)
  4. `test_tags_tem_pagina_por_tag_usada` (site_test.rb:137) —
     "_site/tags/ruby/ não foi gerado" (tag `ruby` dependia do post
     `visualizando-pipelines` removido)
  5. `test_tempo_de_leitura_visivel_no_post` (site_test.rb:143) —
     "post não foi gerado"
  6. `test_home_lista_posts_em_ordem_cronologica_decrescente`
     (site_test.rb:114) — "post ausente da home. Expected nil to not be nil."
- **Interpretação:** mesma contagem do baseline BLOG-3 (`e1cb549`,
  `22/37/6/0`) e mesmos 6 nomes de teste; sem drift em 15 commits.
  Valida a estratégia D-2 do plan: a reescrita das 6 asserções é o
  único caminho para o verde — nenhuma outra mudança (conteúdo,
  config, workflow) alteraria esses números.
- **Done when (Phase 1) espera:** `22/≥37/0/0` (6 reescritas verdes;
  assertion count pode subir se um teste reescrito fizer mais asserções).

## Wrap up

Autor único, sem PR (plan → Tooling → Git): a entrega é o merge de `blog-1-mvp` em `main`.

- [ ] Merge `blog-1-mvp` → `main` e push (é o deploy: BLOG-1 Step 6; D-7 concluído em 2026-09-29 — Pages Source = GitHub Actions no painel; falta só o push/merge)
- [ ] Spec linkado ao issue — n/a, `BLOG-1`/`BLOG-2`/`BLOG-3` são identificadores locais registrados no próprio `spec.md`
- [ ] Follow-up registrado: `BLOG-2 Fase técnica` como nova seção em `plan.md` (D-2..D-7)
- [ ] `spec.md` `status:` → `implemented` só quando a Verification do último issue em execução fechar (não aplicável nesta passada — BLOG-3 é comentários, não muda status)
