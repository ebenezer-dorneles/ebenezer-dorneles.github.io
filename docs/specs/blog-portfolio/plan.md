# Plano — Blog de portfólio (Ciência de Dados & Dev)

<!--
No frontmatter — spec.md is the source of truth for status/issues.
One `## Plan — <ISSUE>` section per issue (any stable issue id) that touches
this spec. When a shipped feature is resumed
under a new issue, ADD a new section below; never rewrite a closed one.
Keep this file under ~250 lines — move completed detail into task.md's
Execution Log with a one-line pointer here.
-->

## Plan — BLOG-1

MVP do spec (`## Scope → MVP`). Pré-condição satisfeita: `## Audit — 2026-09-17` fechado,
17/17, zero questões abertas.

### Context

Pesquisa feita em 2026-09-18, contra o material real (starter `main` via rede, gem
`jekyll-theme-chirpy` 7.6.0 desempacotado no scratchpad). O repositório hoje só tem
`docs/` e `.gitignore`: não existe código a seguir, então a referência idiomática é
o próprio `cotes2020/chirpy-starter`.

- **O gate do CI não é o `tools/test.sh`.** O workflow do starter repete o build e o
  `htmlproofer` inline (`Build site` e `Test site`), sem chamar o script. Rodar o
  `test.sh` localmente reproduz o CI só por coincidência, e o validador de front matter
  não está em nenhum dos dois.
- **O `exclude:` do starter já cobre `docs` e `tools`**, então o spec e os scripts não
  vão para o site publicado. `test/` e `draft/` **não** estão cobertos: fixtures com
  front matter seriam renderizadas como páginas públicas, e `draft/` (local) iria parar
  no `_site` do build local.
- **O `noindex` global tem seam no tema.** O gem traz `_includes/metadata-hook.html`
  com o conteúdo `<!-- A placeholder to allow defining custom metadata -->`, incluído
  por `_includes/head.html:136`. O tema não emite `robots` em lugar nenhum (nem o
  `jekyll-seo-tag`).
- O `assets/robots.txt` do gem só tem `Disallow: /norobots/` e aponta o sitemap. Não
  serve como `noindex`: `Disallow` impede rastrear, não indexar uma URL já conhecida.
- `_config.yml` do starter: `lang: en`, `timezone:` vazio, `url: ""`, `baseurl: ""` e
  permalink de post `/posts/:title/`.
- **Ambiente local:** Ruby 4.0.6 com bundler 4.0.16, **sem** gerenciador de versões
  (rbenv, mise, asdf e chruby ausentes). O `.ruby-version` com `3.4` não tem efeito
  sozinho. `minitest` não está instalado como gem avulsa.
- Sem remote: `git remote -v` está vazio.

### Strategy

- **Um gate só, igual no local e no CI.** Um novo `tools/check.sh` roda, em ordem:
  validador de front matter → testes do validador → `bash tools/test.sh` (build de
  produção + `htmlproofer`, sem alterar o arquivo do starter) → testes do site gerado.
  O workflow troca os passos inline `Build site` e `Test site` por um único
  `bash tools/check.sh`. O restante fica igual ao starter: `fetch-depth: 0`,
  `submodules` comentado, `paths-ignore`, `upload-pages-artifact` e `deploy-pages`.
  Vale a troca porque é a única forma de "passou local" significar "passa no CI".
  O `base_path` do `configure-pages` é vazio num site de usuário na raiz, então o
  `_site` do `test.sh` é o mesmo diretório que o upload publica.
- **Validador = lógica pura + borda de I/O.** `tools/validate-front-matter.rb` expõe
  `FrontMatterValidator.validate(path:, source:, config:) → [erros]`, sem I/O, e a CLI
  só roda sob `if $PROGRAM_NAME == __FILE__`. Assim, o teste unitário chama a função e o
  teste de integração chama o processo.
- **Testes do site gerado como teste de integração.** `test/site_test.rb` lê o `_site/`
  e verifica o que o `htmlproofer` não vê: regras de negócio renderizadas, `noindex`,
  `lang` e ausência de diretórios que não deveriam publicar. É o "Red" das etapas de
  configuração e layout, que de outro modo seriam só inspeção visual.
- **`noindex` como chave de config, emitido pelo hook.** `_includes/metadata-hook.html`
  (nosso) emite `<meta name="robots" content="noindex, nofollow">` quando
  `site.noindex` é verdadeiro, e o `_config.yml` recebe `noindex: true`. Sair do MVP
  vira mudar uma chave, e o validador impede mudá-la cedo demais (Step 2).
  ⚠️ Isso **sombreia um arquivo do gem**, o que diverge da letra da decisão "nenhum
  arquivo do tema sobrescrito", embora não do motivo dela. O arquivo é um placeholder
  vazio, feito para ser sobrescrito, e um bump do tema não gera conflito. A alternativa,
  sobrescrever `head.html`, é justamente o que a decisão quer evitar. Aprovado pelo
  autor em 2026-09-18 e registrado no `## Feedback` do spec.
- **O que não muda:** o tema é gem e continua sem nenhum layout ou include do Chirpy
  copiado. Os arquivos do starter (`tools/test.sh`, `tools/run.sh`, `_plugins/`) ficam
  como vieram, exceto `_config.yml`, `_data/contact.yml`, `_data/share.yml`, `_tabs/about.md`,
  `README.md` e o workflow.

### Tooling e padrões

| Ponto | Escolha | Por quê |
|---|---|---|
| Testes | `minitest`, declarado no Gemfile (`group: :test`) | Stdlib de fato do Ruby, sem DSL. Não está instalado avulso, e declarar no Gemfile o fixa no `Gemfile.lock` junto com o resto |
| Unit | `test/validate_front_matter_test.rb`: um caso por regra violável, com a fonte YAML inline no teste | Cobrança do spec ("um caso de teste por regra violável"). Fonte inline deixa cada caso legível sem abrir fixture |
| Integração (CLI) | Mesmo arquivo: `Open3` sobre `test/fixtures/front_matter/{valid,invalid}/`, conferindo exit code e mensagem | Prova a borda de I/O e o exit ≠ 0 de que o CI depende |
| Integração (site) | `test/site_test.rb` sobre `_site/` gerado | As regras 3, 4, 9, 10 e 12, o `noindex` e o `exclude` só são observáveis no HTML final |
| Comando | `bash tools/check.sh` (local: `docker compose run --rm site bash tools/check.sh`) | O mesmo no local e no CI. Isolado: `bundle exec ruby -Itest test/validate_front_matter_test.rb` |
| Análise estática | `ruby -wc` nos `.rb` alterados; `bash -n` no `check.sh` | Um script de ~150 linhas não paga o RuboCop, que despejaria uma árvore de dependências no lock de um site. Não há erros pré-existentes (repositório sem código) |
| Lint do HTML | `htmlproofer` (já no gate) | Já está no starter. `--disable-external` continua: `repo` placeholder passa, imagem interna ausente reprova |
| Lint do workflow | nenhum | O primeiro run no Actions é o teste. `actionlint` não compensa com um arquivo só |
| Revisão | Autor único, sem PR. Antes de cada commit: skill `auditoria-de-impacto` sobre o diff. Antes do push: `bash tools/run.sh`, olhar home, post, categoria, tag, busca e "sobre" | O artefato visível é o site: revisão por inspeção local, e depois na URL publicada (Step 6) |
| Git | Branch `blog-1-mvp`, commits no padrão já usado (`tipo(escopo): descrição` em pt-BR), merge em `main` no Step 6 | Nada publica antes de existir remote. O merge em `main` é o deploy |

**Padrões de código.** Ruby: `# frozen_string_literal: true`, só stdlib no validador,
`snake_case`, mensagens de erro em pt-BR no formato `caminho: campo: problema`,
YAML sempre via `YAML.safe_load(..., permitted_classes: [Date, Time])`. As duas
categorias ficam numa constante única, `FrontMatterValidator::CATEGORIES`, que nenhuma
outra lista duplica. Liquid: o layout filho reusa classes e strings de
`_data/locales` do tema sempre que existirem, sem CSS inline e sem copiar markup do
`post.html`. Nenhum arquivo em `_layouts/` ou `_includes/` com nome de arquivo do gem,
exceto `metadata-hook.html` (ver Strategy).

### Stages (Red → Green → Refactor)

- [ ] **Step 0 — Ruby 3.4 via Docker Compose** (decisão do autor, 2026-09-18)
  - `compose.yaml` com um serviço `site` sobre a imagem oficial `ruby:3.4` (Debian,
    traz `git`). Motivos: não mexe no Ruby do sistema; a imagem é `x86_64-linux`, a
    mesma plataforma do runner, então o `Gemfile.lock` sai igual; e a tag fixa o 3.4
    explicitamente. Descartada a imagem do `.devcontainer` do starter
    (`devcontainers/jekyll:2-bullseye`): Debian antigo e versão de Ruby implícita.
    O `.devcontainer/` do starter não é copiado no Step 1.
  - Armadilhas desta máquina (Docker CE 29, Compose v5, **SELinux enforcing**):
    - bind mount com `:z`, senão o container não lê o repositório;
    - `user: "${UID:-1000}:${GID:-1000}"`, senão `Gemfile.lock` e `_site/` nascem com
      dono `root`;
    - `BUNDLE_PATH=/usr/local/bundle` num volume nomeado, para não reinstalar gems a
      cada `run` e não sujar o repositório com `vendor/`;
    - `git config --global --add safe.directory /srv/site` no container. Sem isso, o
      `git log` recusa um repositório de outro dono, e o hook de `last_modified_at`
      **some em silêncio no local**: é a mesma falha do checkout raso;
    - `jekyll serve` precisa de `-H 0.0.0.0` e da porta `4000:4000` publicada. O
      `tools/run.sh` do starter já aceita `-H`.
  - O CI **não** usa o compose, e continua com o `ruby/setup-ruby` do starter. O
    container só reproduz localmente o runtime do CI. A versão 3.4 fica em três lugares
    (`compose.yaml`, `.ruby-version` e o workflow); os três mudam juntos num bump.
  - Comandos: `docker compose run --rm site bash tools/check.sh` (gate) e
    `docker compose run --rm --service-ports site bash tools/run.sh -H 0.0.0.0`
    (preview).
  - Pronto quando: `docker compose run --rm site ruby -v` mostra `3.4.x`.
  - O remote não bloqueia os Steps 1–5, só o Step 6.

- [ ] **Step 1 — Scaffold do starter**
  - **Red**: `bash tools/test.sh` falha (o arquivo nem existe).
  - **Green**: `git clone --depth 1` do starter no scratchpad, copiando para o repositório
    **sem** `.git`, `.gitignore` (o nosso fica), `.gitmodules` e `assets/lib`.
    Justificativa: o MVP não usa o submódulo, e um `.gitmodules` sem gitlink só confunde.
    Volta no self-host da fase 2. Criar `.ruby-version` com `3.4`. Rodar `bundle install`
    **sob Ruby 3.4**, para o `BUNDLED WITH` do lock sair do bundler 2.x, e não do 4.0.16:
    o `setup-ruby` instala a versão do lock. Depois,
    `bundle lock --add-platform x86_64-linux`. `bash tools/test.sh` verde, com o site
    vazio do starter.
  - **Refactor**: nada. Commit: scaffold puro, sem edição, para que o diff dos passos
    seguintes mostre só o que é nosso.

- [ ] **Step 2 — Validador de front matter (TDD de verdade)**
  - **Red**: `test/validate_front_matter_test.rb`, um caso por regra, todos falhando:
    `title` ausente ou vazio · `date` ausente em `_posts/` (e aceito ausente em `_drafts/`) ·
    arquivo em `_posts/` sem prefixo `AAAA-MM-DD-` (o Jekyll **ignora em silêncio** esse
    arquivo) · `categories` ausente, com 0 ou 2 itens, ou fora de `CATEGORIES` · `tags`
    ausente ou vazia · tag com maiúscula ou acento (o contrato diz "minúsculas, sem
    acento", e tag acentuada gera página de tag duplicada) · `project: true` sem `repo` ·
    `repo` fora de `https://github.com/<owner>/<repo>` · `project: true` sem
    `layout: project-post` · `last_modified_at` escrito à mão · arquivo sem front matter
    ou com YAML inválido · **guarda do marco de saída:** post com título `[RASCUNHO]…`
    quando `noindex` não é `true` no `_config.yml`. Mais o caso válido (zero erros) e o
    teste de CLI (exit 0 e exit 1). Confirmar que falham pelo motivo certo.
  - **Green**: o script mínimo que passa. A CLI, sem argumentos, varre `_posts/**/*.md` e
    `_drafts/**/*.md`; reporta todos os erros, não só o primeiro; sai com 1 se houver
    algum.
  - **Refactor**: uma função por regra, cada uma devolvendo lista de erros; `ruby -wc`
    limpo. Criar `tools/check.sh` (só validador + testes unitários por enquanto) e
    `test/` no `exclude:`.

- [ ] **Step 3 — Configuração do site**
  - **Red**: `test/site_test.rb`: `<html lang="pt-BR">`; `<meta name="robots"
    content="noindex, nofollow">` na home; `sitemap.xml` e `robots.txt` existem; links
    de GitHub, LinkedIn e e-mail presentes na home (regra 12); página `/about/` existe;
    `_site/test`, `_site/draft`, `_site/docs` e `_site/compose.yaml` **não** existem.
  - **Green**: `_config.yml` com os campos do escopo do MVP, mais `timezone:
    America/Sao_Paulo`, `noindex: true` e `test`, `draft` e `compose.yaml` no `exclude:`;
    `_includes/metadata-hook.html`; `_data/contact.yml` e `_data/share.yml`;
    `_tabs/about.md` (texto provisório, marcado como tal). `check.sh` completo, com
    `test.sh` e `site_test.rb` no fim.
  - **Refactor**: `_config.yml` mantém a ordem e os comentários do starter, e só os
    valores mudam, para que um diff contra o starter continue legível num bump.

- [ ] **Step 4 — Layout `project-post` e template de projeto**
  - **Red**: fixture de post com `project: true` (exclusiva do teste, fora de `_posts/`).
    `site_test.rb` exige o link de `repo` no HTML do post e a ausência do bloco em post
    comum.
  - **Green**: `_layouts/project-post.html` com `layout: post`, bloco do repositório
    antes de `{{ content }}`. `_drafts/template-projeto.md` com as cinco seções da regra
    13 e front matter que passa no validador.
  - **Refactor**: reusar strings do locale quando houver; senão, texto em pt-BR no layout,
    registrado como dívida da i18n da fase 2.
  - Atenção: o template em `_drafts/` é validado pelo Step 2. Isso é intencional: um
    template inválido ensinaria errado.

- [ ] **Step 5 — Três posts fictícios**
  - **Red**: `site_test.rb` exige: home em ordem decrescente de data (regra 9); página
    de cada categoria e de cada tag usada (regra 10); **categoria de um nível renderiza
    sem árvore quebrada** (Audit item 17); tempo de leitura no post (regra 4); entrada
    de cada post no índice de busca do tema; `.highlight` (Rouge) e bloco Mermaid no
    post técnico; imagem do post servida de `assets/img/posts/<slug>/`.
  - **Green**: um post por categoria, mais o terceiro com código, Mermaid e imagem.
    Todos com título `[RASCUNHO]` e `repo` placeholder válido. Imagem pequena
    (redimensionada), porque a regra 5 faz o repositório crescer com binários.
  - **Refactor**: conferência visual com `bash tools/run.sh`, incluindo busca digitada
    de verdade. O teste só prova que o índice existe, não que a UI busca.

- [ ] **Step 6 — README, remote e primeiro deploy (bloqueante, decisão do autor)**
  - **Red**: nada publicado; `https://ebenezer-dorneles.github.io` responde 404.
  - **Green**: `README.md` com o fluxo da regra 6. Fazer o push de `main` e acompanhar o
    run até ficar verde. Estado em 2026-09-18: o repositório público foi criado vazio
    pelo autor (`default_branch: main`) e o `origin` aponta para ele via HTTPS. Pages →
    Source = **GitHub Actions** ainda não foi confirmado, porque a API de Pages exige
    autenticação. Conferir antes do primeiro push.
  - **Verificação no site publicado** (registrar comando e resultado no `task.md`):
    `robots.txt` e `sitemap.xml` respondem 200; a home tem o meta `noindex`; um post
    editado num **segundo commit** mostra a data de atualização (regra 8), o que prova o
    `fetch-depth: 0` na prática; e um commit só de `README.md` **não** dispara o
    workflow (`paths-ignore`, Audit item 14).
  - **Refactor**: nada.

### Deferred

- **Marco de saída do MVP → `BLOG-2`**: trocar os posts fictícios por reais, apagar os
  `[RASCUNHO]` e mudar `noindex` para `false`. Até lá, o validador do Step 2 barra
  qualquer tentativa de tirar o `noindex` antes da hora. Não entra no BLOG-1 porque
  depende de redação, não de engenharia.
- **Fase 2 (issues próprias):** giscus, analytics (GoatCounter/Cloudflare), domínio +
  `CNAME`, i18n completa (incluindo as strings pt-BR do `project-post`), self-host de
  assets (`.gitmodules` volta junto).
- Validação de `description` ≤ 160 e de existência do `repo`: fora do validador, como o
  spec já determina.

## Plan — BLOG-3

Spec revision: 4

Escopo: **naming e rastreabilidade** (D-12 / rev 4). Adicionar tag `FR-n`/`AC-n.m` em
cada teste de `test/validate_front_matter_test.rb` e `test/site_test.rb`, e escrever
esta matriz `## Coverage` cobrindo os 41 ACs do `## Requirements`. **Sem mudança de
comportamento**: nenhum `_config.yml`, `tools/`, `_layouts/`, `_includes/`, `_posts/`
ou `_data/` é tocado. Precondição: spec rev 4 aprovada (autor, 2026-09-29, `## Approvals`).

### Context

Estado hoje (2026-09-29, branch `blog-1-mvp`):

- `test/validate_front_matter_test.rb` — 26 métodos `test_*` (25 unit + 2 CLI); nomes
  descritivos em pt-BR, sem tag de AC (ex.: `test_title_ausente:27`,
  `test_repo_fora_do_formato_github:125`).
- `test/site_test.rb` — 22 métodos `test_*`; nomes descritivos em pt-BR sem tag de AC
  (ex.: `test_home_tem_meta_robots_noindex:29`, `test_indice_de_busca_lista_os_tres_posts_ficticios:143`).
- `## Requirements` do spec define 20 FRs e ~41 ACs; `## Audit — rev 4` confirma
  Coverage regra→FR e UC→FR→AC 100% completa (spec:1401–1407).
- `docker compose run --rm site bash tools/check.sh` **verde no último commit** (`b1e1bfe`):
  26 runs no validador + build+htmlproofer + 22 runs no site_test.
- BLOG-2 (D-2) vai reescrever `test/site_test.rb` mais tarde. A tag de AC precisa ser
  **transportável**: convenção que sobrevive à reescrita (comentário estruturado
  imediatamente antes de `def test_*`), não embutida no nome (que muda quando a
  asserção vira invariante estrutural).

Padrão de referência: nenhum no repositório (minitest usado sem convenção de tag hoje).
O contrato do ssd-verify menciona `validation.md` matriz por AC → arquivo:linha, o que
`grep -n "# @spec"` já resolve.

### Strategy

- **Um comentário Ruby estruturado por teste, imediatamente antes do `def`**, no
  formato `# @spec FR-N AC-N.M` (múltiplos ACs separados por espaço quando um teste
  cobre mais de um). Alternativa rejeitada: prefixo no nome do método
  (`test_ac_1_1_...`) — mais visível em falhas do minitest, mas custa churn em ~48
  nomes e obriga BLOG-2 a renomear ao reescrever `site_test.rb`. Comentário estruturado
  sobrevive à reescrita e é grep-friendly (`grep -n "# @spec"`).
- **Coverage é a fonte de verdade da rastreabilidade**, não o comentário no teste. A
  matriz abaixo mapeia cada AC → teste (arquivo:linha) ou → destino não-testado com
  motivo (BLOG-2 Verification externa, manual/editorial, Fase 2). Um AC sem
  destino é gap → CR.
- **Testes que cobrem invariantes de decisão** (não AC direto) recebem tag `# @spec
  D-N` ou `# @spec AU-N` conforme origem (ex.: `test_categoria_de_um_nivel_...`
  origina-se de Audit item 17 → `# @spec AU-17 (rev 1)`).
- **O que não muda:** nenhuma lógica de teste; nenhum código do validador ou dos
  layouts; nenhum artefato de conteúdo; nenhum arquivo de config. Diff é 100%
  comentários adicionados.

### Tooling & commands

Comandos rodam via `docker compose run --rm site …` (Step 0 do BLOG-1). O gate único
continua sendo `tools/check.sh` (não muda nesta issue).

| Check | Command | Scope | Why |
|---|---|---|---|
| Baseline (antes da 1ª mudança) | `docker compose run --rm site bash tools/check.sh` | validador + testes unit + build + htmlproofer + site_test | confirmar que a base parte verde (registrar contagem exata: 26 runs validador, 22 runs site_test) |
| Full test suite | `docker compose run --rm site bash tools/check.sh` | tudo | invariante: mesmo número de runs antes e depois (comentário não muda teste) |
| Targeted (Fase 1) | `docker compose run --rm site bundle exec ruby -Itest test/validate_front_matter_test.rb` | 26 runs | verifica tags aplicadas sem regressão |
| Targeted (Fase 2) | `docker compose run --rm site bundle exec ruby -Itest test/site_test.rb` | 22 runs | idem para site_test |
| Cross-check da Coverage (Fase 3) | `grep -n "# @spec" test/*.rb \| wc -l` e `grep -n "def test_" test/*.rb \| wc -l` | grep | a diferença deve ser exatamente **1** (o `test_valid_post_has_no_errors` baseline, tag `FR-1`) |
| Análise estática | `docker compose run --rm site ruby -wc test/validate_front_matter_test.rb test/site_test.rb` | ambos os arquivos | comentário mal formado (aspas erradas, encoding) reprova aqui |
| Lint / formatting | `bash -n tools/check.sh` (não muda; conferência de regressão) | check.sh | precaução; nenhuma edição prevista em `tools/` |
| Artifact regeneration | n/a | — | issue não gera artefato visível ao leitor (só comentários no código) |

**Baseline a registrar no task.md antes da Fase 1:** contagem exata de runs, assertions,
falhas e erros de cada suite; hash do último commit (`git rev-parse HEAD`).

### Review & code standards

- **Autor único, sem PR** (mesmo padrão do BLOG-1). Antes do commit: skill
  `auditoria-de-impacto` sobre o diff — específica para "diff só de comentários":
  confirmar que nenhum `def`, `assert*`, `refute*`, `require` ou constante mudou.
- **Convenção do comentário-tag**, aplicada uniformemente:
  - Linha única, imediatamente antes de `def test_*`, sem linha em branco entre elas.
  - Formato: `# @spec <TAG> [<TAG>...]` onde `<TAG>` é `FR-N`, `AC-N.M`, `D-N` ou
    `AU-N` (revisão citada se AU vier de rev específica: `AU-17 (rev 1)`).
  - Múltiplos tags no mesmo teste separados por espaço único.
  - Testes de CLI ganham tag `FR-N (CLI)` (ex.: `# @spec FR-1 (CLI)`).
  - Testes de regressão da `auditoria-de-impacto` (test_tag_nao_string_..., test_repo_nao_string_...)
    tagueiam o AC que exercitam mais o marcador `(auditoria-de-impacto)`.
- **Diretrizes de escopo** (não fazer, mesmo se tentador):
  - Não renomear teste; não reorganizar; não extrair helper; não alterar mensagens
    de asserção. Cada uma dessas mudanças precisa de spec/plan próprio.
  - Não adicionar teste novo mesmo que um AC esteja sem cobertura — isso é gap de
    escopo do BLOG-1 e vai para Coverage → não-testados com motivo.
- **Padrão Ruby** (não muda): `# frozen_string_literal: true`, `snake_case`,
  minitest declarativo sem DSL.

### Phases

Ordenadas por risco crescente: o arquivo maior e mais numeroso primeiro (mais chance
de deslize mecânico), depois o menor, depois a verificação cruzada.

**Phase 1 — Tag `validate_front_matter_test.rb`** · covers: FR-1, FR-3, FR-8, FR-18, D-1

- **Red:** n/a — não é teste-first. É rename mecânico de comentários. **Substituto:**
  contagem-baseline antes (`bundle exec ruby -Itest test/validate_front_matter_test.rb`
  → registrar runs/assertions/failures/errors) e regra: a mesma contagem deve valer
  após a Fase 1. `grep -c "# @spec" test/validate_front_matter_test.rb` → **25** ao
  fim (25 métodos taggeados; o CLI vai na Fase 1 também).
- **Green:** inserir `# @spec <TAG>` na linha imediatamente antes de cada `def test_*`,
  seguindo a Coverage abaixo. Um teste, uma linha, um commit não; commit único da Fase.
- **Refactor:** conferir alinhamento coluna 1 (dois espaços + `#`), sem TABs mistos.
- **Done when:** `bundle exec ruby -Itest test/validate_front_matter_test.rb` verde com
  a mesma contagem do baseline; `grep -c "# @spec" test/validate_front_matter_test.rb`
  é 25; `ruby -wc` limpo; `auditoria-de-impacto` fecha "diff só de comentários".
- **Not test-first?** rename de comentário não tem asserção de comportamento a falhar;
  a regressão a evitar é churn acidental de teste, capturada pelo baseline + count.

**Phase 2 — Tag `site_test.rb`** · covers: FR-3, FR-4, FR-5, FR-9, FR-10, FR-12, FR-16,
FR-17, FR-18, FR-19, AU-17 (rev 1), decisão pt-BR (D do BLOG-1)

- **Red:** n/a — mesmo raciocínio da Fase 1. **Substituto:** baseline `bundle exec
  ruby -Itest test/site_test.rb` (**precisa de `_site/` gerado antes** — usar
  `tools/check.sh` que builda; skip se não; ver Watch out do task.md). Regra: 22 runs,
  mesma contagem de assertions pré e pós.
- **Green:** inserir `# @spec <TAG>` conforme Coverage. Testes de "invariante de
  decisão" (D-N/AU-N) usam a tag correspondente sem inventar FR.
- **Refactor:** idem Fase 1.
- **Done when:** `docker compose run --rm site bash tools/check.sh` verde;
  `grep -c "# @spec" test/site_test.rb` é 22; `ruby -wc` limpo; `auditoria-de-impacto`
  fecha "diff só de comentários".
- **Not test-first?** mesmo motivo da Fase 1.

**Phase 3 — Verificação cruzada Coverage ↔ testes** · covers: garantia de rastreabilidade

- **Red:** n/a. **Substituto:** dois greps produzem números concretos que precisam
  bater com a Coverage abaixo:
  - `grep -n "# @spec" test/*.rb` — cada linha aparece **exatamente uma vez** na
    Coverage como origem de teste.
  - Cada AC listado como "testado" na Coverage aparece **em pelo menos uma linha**
    dos greps acima.
- **Green:** ajustar tags no código (não a Coverage) se o cross-check falhar, e
  registrar deviation em task.md quando fizer sentido. Se a Coverage estiver errada,
  isso é **plan-affecting** e vira Amendment ou CR — não silenciar corrigindo a
  Coverage sem trilha.
- **Refactor:** nenhum.
- **Done when:** os dois greps casam com a Coverage; `tools/check.sh` continua verde.
- **Not test-first?** verificação estrutural do trabalho das Fases 1 e 2, não código
  novo.

### Coverage

Convenção da coluna **Test / check**: `arquivo:linha` do `def test_*` quando testado; caso
contrário, motivo explícito (BLOG-2 Verification externa · manual/editorial · Fase 2 ·
propriedade do modelo). "vfm_test.rb" abrevia `test/validate_front_matter_test.rb`;
"site_test.rb" fica como está.

| Item | Phase | Test / check |
|---|---|---|
| AC-1.1 (title ausente/vazio) | 1 | vfm_test.rb:27 (`test_title_ausente`), vfm_test.rb:33 (`test_title_vazio`) |
| AC-1.2 (date ausente em `_posts/`) | 1 | vfm_test.rb:39 (`test_date_ausente_em_posts`) |
| AC-1.3 (filename sem prefixo AAAA-MM-DD-) | 1 | vfm_test.rb:51 (`test_arquivo_em_posts_sem_prefixo_de_data`) |
| AC-1.4 (categories ausente/vazio/≥2 itens) | 1 | vfm_test.rb:56, 62, 68 |
| AC-1.5 (categoria fora da lista fixa) | 1 | vfm_test.rb:74 (`test_categories_fora_da_lista_fixa`) |
| AC-1.6 (tags ausente/vazia) | 1 | vfm_test.rb:80 (`test_tags_ausente`), vfm_test.rb:86 (`test_tags_vazia`), vfm_test.rb:104 (não-string, auditoria-de-impacto) |
| AC-1.7 (tag maiúscula/acento) | 1 | vfm_test.rb:92 (`test_tag_com_maiuscula`), vfm_test.rb:98 (`test_tag_com_acento`) |
| AC-1.8 (draft sem date aceito) | 1 | vfm_test.rb:45 (`test_date_ausente_em_drafts_eh_aceito`) |
| AC-2.1 (drafts fora de `_site/`) | — | propriedade nativa do Jekyll (`--drafts` off por padrão); indiretamente confirmada por site_test.rb:66 (`test_diretorio_draft_nao_publicado`) checar `_site/draft` |
| AC-2.2 (published: false) | — | propriedade nativa do Jekyll; sem teste dedicado (aceito) |
| AC-2.3 (date futuro / `future: false`) | — | propriedade nativa do Jekyll com `timezone: America/Sao_Paulo`; sem teste (aceito) |
| AC-3.1 (project sem repo) | 1 | vfm_test.rb:119 (`test_project_true_sem_repo`) |
| AC-3.2 (repo fora do formato github) | 1 | vfm_test.rb:125 (`test_repo_fora_do_formato_github`), vfm_test.rb:110 (não-string, auditoria-de-impacto) |
| AC-3.3 (layout != project-post) | 1 | vfm_test.rb:134 (`test_project_true_sem_layout_project_post`) |
| AC-3.4 (HTML tem link do repo) | 2 | site_test.rb:78 (`test_post_de_projeto_tem_link_do_repositorio`); negativo em site_test.rb:86 (`test_post_comum_nao_tem_bloco_de_repositorio`) |
| AC-4.1 (tempo de leitura visível) | 2 | site_test.rb:123 (`test_tempo_de_leitura_visivel_no_post`) |
| AC-5.1 (asset local existe) | 2 | site_test.rb:135 (`test_imagem_do_post_e_servida_e_referenciada`) |
| AC-5.2 (htmlproofer reprova ref quebrada) | — | gate `tools/test.sh` (parte do `check.sh`); sem teste minitest dedicado — invariante do htmlproofer, garantido pelo próprio gate falhando quando quebrado |
| AC-6.1 (workflow dispara) | — | BLOG-2 Fase técnica passo 5 (Verification externa registrada em task.md) |
| AC-6.2 (paths-ignore não dispara) | — | BLOG-2 Fase técnica passo 5 |
| AC-7.1 (histórico via git) | — | propriedade do modelo (explícito no spec); verify por inspeção `git log` durante BLOG-2 Verification externa |
| AC-8.1 (last_modified_at em ≥ 2 commits) | — | BLOG-2 Fase técnica passo 5 (exige `fetch-depth: 0` + 2 commits reais) |
| AC-8.2 (last_modified_at em 1 commit) | — | BLOG-2 Fase técnica passo 5 |
| AC-8.3 (checkout raso quebra) | — | armadilha documentada (explícito no spec: sem teste automatizado) |
| **Invariante FR-8** (validador rejeita `last_modified_at` escrito à mão) | 1 | vfm_test.rb:143 (`test_last_modified_at_escrito_a_mao`) — complementa AC-8.x |
| AC-9.1 (home ordem cronológica decrescente) | 2 | site_test.rb:91 (`test_home_lista_posts_em_ordem_cronologica_decrescente`); nota D-8: verificação por vacuidade no site publicado enquanto `_posts/` tem 1 real, robusta no gate por symlinks de fixture |
| AC-10.1 (categorias) | 2 | site_test.rb:103 (`test_categorias_tem_pagina_por_categoria`) |
| AC-10.2 (tags) | 2 | site_test.rb:117 (`test_tags_tem_pagina_por_tag_usada`) |
| AC-11.1 (CATEGORIES constante única) | 1 | coberto por propriedade via vfm_test.rb:74 (rejeita Culinária) + vfm_test.rb:23 (`test_valid_post_has_no_errors` aceita Desenvolvimento) — a constante existe em `tools/validate-front-matter.rb:8` e não é duplicada em outros arquivos; assertion direta sobre a constante seria tautológica |
| AC-12.1 (a) GitHub | 2 | site_test.rb:44 (`test_home_tem_link_github`) |
| AC-12.1 (b) LinkedIn | 2 | site_test.rb:48 (`test_home_tem_link_linkedin`) |
| AC-12.1 (c) e-mail | 2 | site_test.rb:52 (`test_home_tem_link_email`) |
| AC-13.1 (template de projeto em `_drafts/`) | — | validador roda contra `_drafts/template-projeto.md` no `check.sh` (existe hoje; passar valida front matter); sem teste minitest dedicado — cobertura é o próprio gate falhando se o template regredir |
| AC-13.2 (5 seções — revisão editorial) | — | manual/editorial (explícito no spec; AU-32) |
| AC-14.1 (público sem auth) | — | BLOG-2 Verification externa |
| AC-15.1 (giscus) | — | Fase 2 (FR-15 marcado como Fase 2 no spec) |
| AC-16.1 (search.json existe) | 2 | site_test.rb:143 (`test_indice_de_busca_lista_os_tres_posts_ficticios`) |
| AC-16.2 (UI de busca) | — | manual/visual (AU-32) |
| AC-17.1 (sitemap.xml) | 2 | site_test.rb:36 (`test_sitemap_existe`) |
| AC-17.2 (robots.txt) | 2 | site_test.rb:40 (`test_robots_txt_existe`) |
| AC-18.1 (`noindex: true` → meta robots presente) | 2 | site_test.rb:29 (`test_home_tem_meta_robots_noindex`); complementado por vfm_test.rb:160/166 (guard `[RASCUNHO]` × `site.noindex`) na Fase 1 |
| AC-18.2 (`noindex: false` → meta ausente) | — | BLOG-2 Fase de conteúdo passo 2 (pós-flip, gated no D-11) |
| AC-18.3 (≥ 10 posts reais + repos 200) | — | operacional (contador shell + `curl`), BLOG-2 Fase de conteúdo pré-flip |
| AC-19.1 (Rouge) | 2 | site_test.rb:128 (`test_post_tecnico_tem_highlight_e_mermaid`) |
| AC-19.2 (Mermaid em layout post) | 2 | site_test.rb:128 (mesmo teste, asserção `language-mermaid`) |
| AC-19.3 (Mermaid em `project-post`) | — | garantido por D-4 (sombreamento `_includes/js-selector.html`, `4083351`); sem teste dedicado — nenhum post `project-post` com Mermaid existe hoje; verificação por inspeção pós-BLOG-2 quando post real com essa combinação for publicado |
| AC-20.1 (preview local ≡ CI) | — | manual/visual (AU-32) |
| **Config pt-BR (`_config.yml`)** | 2 | site_test.rb:25 (`test_home_declara_lang_pt_br`) — decisão de idioma do BLOG-1 |
| **Exclude do `_config.yml`** (test, draft, docs, compose.yaml não publicam) | 2 | site_test.rb:62, 66, 70, 74 (4 testes de `_diretorio_*_nao_publicado`) |
| **AU-17 (rev 1) categoria de 1 nível** | 2 | site_test.rb:110 (`test_categoria_de_um_nivel_nao_gera_arvore_quebrada`) |
| **Suporte a FR-12 (página `/about/`)** | 2 | site_test.rb:58 (`test_pagina_sobre_existe`) |
| **Contrato CLI do validador (FR-1)** | 1 | vfm_test.rb:183 (`test_cli_exit_0_em_fixture_valida`), vfm_test.rb:188 (`test_cli_exit_1_em_fixture_invalida`) |
| **Baseline positivo (FR-1)** | 1 | vfm_test.rb:23 (`test_valid_post_has_no_errors`) — sanidade das regras, cobre FR-1 no todo |
| **YAML/front matter parsing (FR-1)** | 1 | vfm_test.rb:149 (`test_arquivo_sem_front_matter`), vfm_test.rb:154 (`test_yaml_invalido`) |

**Nenhum AC sem destino** — todos os 41 ACs têm ou teste automatizado, ou destino
explícito não-testado com motivo aceito pelo spec (BLOG-2 Verification externa, manual
editorial por AU-32, Fase 2, propriedade nativa do Jekyll, ou propriedade do modelo).
Nenhum gap → nenhum CR.

### Rollout & rollback

N/A — spec rev 4 não requer `## Migration & rollout` (não há migração de dado; a
mudança é 100% em comentários de teste). Rollback = `git revert <sha do commit
único>`. Feature flag n/a. Sem coordenação com deploy: BLOG-3 não muda o site
publicado e o gate `check.sh` continua verde antes e depois.

### Deferred

- **BLOG-2 Fase técnica** (D-2 reescrever `site_test.rb` para invariantes; D-3 tirar
  `[RASCUNHO]` das fixtures; D-5 Verification externa pré-flip; D-6 `etl-prf-data`
  público; D-7 Pages Source; D-10 superseded do Step 6): plan próprio depois de
  BLOG-3 fechar. Quando D-2 reescrever `site_test.rb`, as tags aplicadas nesta issue
  são reaproveitadas na reescrita (asserção muda; a tag do AC que ela cobre não).
- **BLOG-2 Fase de conteúdo** (flip do `noindex` + Verification pós-flip): gated no
  marco D-11 (≥ 10 posts reais); registrado como "em espera", não em atraso.
- **Automação da matriz Coverage → validation.md** (ssd-verify vai consumir esta
  matriz manualmente na primeira passada): se o custo de re-sincronizar após BLOG-2
  reescrever `site_test.rb` for alto, avaliar script `tools/coverage-matrix.rb` numa
  issue própria de infraestrutura de testes; sem gatilho hoje.

### Spec gaps

Nenhum. Spec rev 4 aprovada em `## Approvals` (autor, 2026-09-29), 41 ACs com destino,
matriz Coverage completa. `## Audit — rev 4` fechado com zero itens open.

**Nota de tamanho do arquivo:** com esta seção, `plan.md` cruza a marca de ~250 linhas.
Contract do ssd-plan diz que a compactação (mover detalhe de plan finalizado para
`task.md` Execution Log e deixar pointer aqui) é responsabilidade do ssd-task no
próximo pass. Registrado para ssd-task tratar ao decompor BLOG-3 ou ao abrir plan de
BLOG-2.

### Amendment — 2026-09-29

Origem: deviation plan-affecting registrada em `task.md ## Deviations` (2026-09-29):

> Plan de BLOG-3 § Context afirma "check.sh verde no último commit (`b1e1bfe`)".
> A baseline coletada em HEAD `e1cb549` mostra 6 falhas em `test/site_test.rb`,
> todas resíduo do commit `686c5c0` ("chore(content): remove posts fictícios de
> prototipagem"), que precede `b1e1bfe`. Testes afetados:
> `test_post_tecnico_tem_highlight_e_mermaid`,
> `test_indice_de_busca_lista_os_tres_posts_ficticios`,
> `test_imagem_do_post_e_servida_e_referenciada`,
> `test_home_lista_posts_em_ordem_cronologica_decrescente`,
> `test_tempo_de_leitura_visivel_no_post`,
> `test_tags_tem_pagina_por_tag_usada`.

Escolha do autor (2026-09-29, via `AskUserQuestion`): opção (b) — aceitar gate
red com invariante estrita de contagem em vez de reordenar BLOG-2 antes de
BLOG-3. BLOG-3 continua sendo comments-only e não toca o comportamento das 6
falhas; elas ficam com BLOG-2 Fase técnica (D-2), conforme `### Deferred` já
registrava.

**Context (retificação).** Claim "check.sh verde em `b1e1bfe`" revogada.
Baseline real em HEAD `e1cb549` (fonte: `task.md ## Verification → 2026-09-29
— BLOG-3 Baseline`):

- validador (`test/validate_front_matter_test.rb` + CLI):
  **26 runs / 29 assertions / 0 failures / 0 errors** (verde)
- build produção + htmlproofer: **16 arquivos / 22 links internos / 0 falhas** (verde)
- `test/site_test.rb`: **22 runs / 37 assertions / 6 failures / 0 errors**
  (red pré-existente por remoção de slugs em `686c5c0`; hoje só existe 1 post
  real, `2026-09-29-etl-dados-prf.md`)

Consequência: `check.sh` sai com código ≠ 0 (site_test.rb dispara `set -e`),
mas os três passos anteriores ainda emitem suas contagens antes do abort. As 6
falhas são fora do escopo de BLOG-3 e serão curadas por BLOG-2 D-2 (reescrever
`site_test.rb` para invariantes estruturais que não citem slugs específicos).

**Tooling & commands (mudança).**

- Row "Baseline (antes da 1ª mudança)" — critério deixa de ser "parte verde" e
  passa a ser "registrar contagem exata". Baseline em HEAD `e1cb549` já
  registrada em task.md.
- Row "Full test suite" — invariante deixa de ser "verde" e passa a ser
  **igualdade estrita de contagem antes/depois**: `26/29/0/0` no validador,
  `22 links/0 falhas` no htmlproofer, `22/37/6/0` no site_test.rb. Igualdade
  prova "diff só de comentários" com mais rigor do que "verde" faria.
- Row "Targeted (Fase 1)" — inalterada (validador está verde no baseline).
- Row "Targeted (Fase 2)" — invariante passa a ser `22 runs / 37 assertions /
  6 failures / 0 errors`, com as **mesmas 6 asserções falhas e mesmas
  mensagens** antes e depois.

**Phase 2 — Done when (mudança).** Substituir "docker compose run --rm site
bash tools/check.sh verde" por:

- validador: `26/29/0/0` (idem baseline)
- htmlproofer: `22 links / 0 falhas` (idem baseline)
- site_test.rb: `22/37/6/0` (idem baseline; conjunto exato das 6 falhas
  inalterado, verificado pelo próprio nome dos testes na saída do minitest)
- `grep -c "# @spec" test/site_test.rb` é 22
- `ruby -wc test/site_test.rb` limpo
- `auditoria-de-impacto` fecha "diff só de comentários"

**Phase 3 — Done when (mudança).** "tools/check.sh continua verde" →
"tools/check.sh apresenta as mesmas contagens do baseline (validador
`26/29/0/0`; htmlproofer `22 links/0 falhas`; site_test.rb `22/37/6/0`, com o
mesmo conjunto de falhas)".

**Coverage (sem mudança).** As linhas da matriz que apontam para os 6 testes
red (AC-4.1, AC-5.1, AC-9.1, AC-10.2, AC-16.1, AC-19.1, AC-19.2) continuam
corretas — o mapeamento AC→teste independe do teste estar verde hoje. Quando
BLOG-2 D-2 reescrever `site_test.rb`, as tags `# @spec` aplicadas nesta issue
sobrevivem à reescrita (`### Strategy` já previu isso), então a Coverage não
precisa ser rescrita agora.

**Deferred (mantido).** BLOG-2 Fase técnica continua depois de BLOG-3 fechar;
ordenação preservada.

## Plan — BLOG-2 Fase técnica

Spec revision: 4

Escopo: **fase técnica do marco de saída do MVP** (spec `### BLOG-2 — Marco de
saída do MVP → Fase técnica`), executável com `noindex: true` ainda ativo.
Cobre D-2 (reescrever `test/site_test.rb` para invariantes estruturais,
curando as 6 falhas herdadas de `686c5c0`), D-3 (renomear fixtures sem
`[RASCUNHO]`), D-5 (Verification externa pré-flip, viável agora que D-6/D-7
foram concluídos pelo autor em 2026-09-29) e D-10 (supersede formal dos
subitens do Step 6 do BLOG-1 em `task.md`). **Fora do escopo:** o flip do
`noindex` (Fase de conteúdo, gated em D-11); o merge/push de `blog-1-mvp` →
`main`, que é decisão operacional do autor fora do pipeline SSD (D-5 depende
do primeiro deploy ter ocorrido). Precondição: spec rev 4 aprovada (autor,
2026-09-29, `## Approvals`), BLOG-3 fechado (`76cb996` + `e87db58`), zero CRs
abertos.

### Context

Estado em 2026-10-02 (branch `blog-1-mvp`, HEAD `94ba825`):

- **D-6 concluído** (2026-09-29): autor tornou `github.com/ebenezer-dorneles/etl-prf-data`
  público. `_posts/2026-09-29-etl-dados-prf.md:8` agora resolve 200 para
  leitor deslogado. Habilita AC-18.3 (parte "repo HTTP 200") para o post
  real único e desbloqueia a Verification externa (D-5).
- **D-7 concluído** (2026-09-29): autor trocou Pages → Source para GitHub
  Actions no painel de `ebenezer-dorneles.github.io`. Workflow
  `.github/workflows/pages-deploy.yml` (do starter, intocado desde o Step 1
  do BLOG-1) agora é o publisher. Primeiro deploy pendente apenas de
  push/merge.
- **Gate local** `docker compose run --rm site bash tools/check.sh` em
  `94ba825`: validador 26/29/0/0 (verde); htmlproofer 16 arquivos/0 falhas
  (verde); **`test/site_test.rb` 22/37/6/0** — 6 falhas herdadas desde
  `686c5c0` (remoção dos posts fictícios): `test_tags_tem_pagina_por_tag_usada`,
  `test_tempo_de_leitura_visivel_no_post`, `test_post_tecnico_tem_highlight_e_mermaid`,
  `test_home_lista_posts_em_ordem_cronologica_decrescente`,
  `test_imagem_do_post_e_servida_e_referenciada`,
  `test_indice_de_busca_lista_os_tres_posts_ficticios`.
- **Tags `# @spec`** aplicadas no BLOG-3 (`76cb996`) — 48 no total, 22 em
  `site_test.rb`. A reescrita D-2 **deve preservar o mapeamento AC→método**
  (a asserção muda; a tag do AC que ela cobre não), per `## Plan — BLOG-3 →
  ### Deferred` (plan.md:448).
- **Fixtures**: `test/fixtures/site_posts/2026-01-01-fixture-post-projeto.md`
  (title `[RASCUNHO] Fixture de post de projeto`) e `2026-01-02-fixture-post-comum.md`
  (title `[RASCUNHO] Fixture de post comum`). Hoje inofensivas porque
  `check_draft_guard` em `tools/validate-front-matter.rb:118-125` só reprova
  quando `_config.yml` tem `noindex` ≠ `true`. **D-3 desarma a armadilha
  antes do flip** da Fase de conteúdo — e deve ser feito nesta Fase técnica
  para a Fase de conteúdo poder flipar com commit único de 1 chave.
- **Post real único** no `_posts/`: `2026-09-29-etl-dados-prf.md` com
  `project: true`, `mermaid: true`, bloco Rouge (Python), e `image.path`
  resolvendo pela convenção `media_subpath` (ver Execution Log do Step 5 do
  BLOG-1 em task.md:349). As asserções reescritas por D-2 passam a rodar
  contra ele + as duas fixtures symlinkadas.
- **Workflow** (`.github/workflows/pages-deploy.yml`): mantém `fetch-depth:
  0` (habilita hook `_plugins/posts-lastmod-hook.rb` do starter, premissa
  de AC-8.1); `paths-ignore` com `.gitignore`, `README.md`, `LICENSE`
  (premissa de AC-6.2). O workflow **não** invoca `tools/check.sh` — ainda
  usa os passos inline `Build site` / `Test site` do starter; esta dívida
  continua fora do escopo do BLOG-2 (ver `### BLOG-2 → Fora do escopo` da
  spec:1080-1082).
- **Checklist do Step 6 do BLOG-1** em `task.md` continua desmarcado (ver
  bloco citação no topo de task.md:16-23). D-10 define a disciplina: na
  decomposição deste plan pelo ssd-task, subitens viram
  `- [ ] ~~item~~ (superseded by BLOG-2)` e `## Deviations` do task.md ganha
  linha datada registrando o superseded.

### Strategy

- **D-2 (reescrita de `site_test.rb`)**: trocar asserções por slug fictício
  (`analise-exploratoria-vendas`, `api-tarefas-ruby`, `visualizando-pipelines`
  — todos removidos em `686c5c0`) por **invariantes estruturais** sobre o
  `_site/` gerado, exatamente como D-2 na spec:650-668 descreve:
  (a) home: ≥ 1 post, em ordem decrescente de `<time datetime="…">` extraída
  do HTML (fixtures symlinkadas garantem ≥ 2 elementos sempre no gate local);
  (b) para cada categoria usada por algum post em `_site/`, existe
  `_site/categories/<slug>/index.html` listando-o — idem para tags;
  (c) `assets/js/data/search.json` contém uma entrada por post **publicado**
  (contagem via `JSON.parse`, não via slug);
  (d) asserções de Rouge, Mermaid e imagem rodam contra o **primeiro post
  que declara cada capacidade** — a cobertura hoje é o post ETL/PRF (Python
  → Rouge, `mermaid: true` + bloco, imagem em `assets/img/posts/etl-dados-prf/`),
  mas o teste descobre o post dinamicamente iterando `_site/posts/*/index.html`
  para não voltar a quebrar quando o conteúdo evoluir.
  As tags `# @spec` existentes (site_test.rb:25-173) permanecem no mesmo
  método; só o corpo da asserção muda. Tags markers informais da deviation
  2026-09-29 (`(decisão pt-BR)`, `(exclude _config.yml)`) ficam intactas.
- **D-3 (renomear fixtures)**: `test/fixtures/site_posts/2026-01-01-…md:2`
  (`title: "[RASCUNHO] Fixture de post de projeto"`) → `"Fixture de post de
  projeto"`; idem para `2026-01-02-…md:2`. Slugs de arquivo preservados
  (usados por `tools/check.sh:19-23` para symlink). Depois do rename,
  `check_draft_guard` (validator) deixa de reprovar as fixtures se o flip
  do `noindex` ocorrer na Fase de conteúdo. Nenhum teste cita os títulos
  (confirmado por `grep -n "RASCUNHO" test/site_test.rb` esperado → vazio;
  conferir no Red).
- **D-5 (Verification externa pré-flip)**: 4 cheques, cada um com
  comando + resultado esperado, a serem registrados pelo ssd-task em
  `task.md ## Verification`. **Precondição operacional:** push/merge para
  `main` já ocorreu e workflow finalizou verde (fora deste plan — ver
  Deferred). Cheques: (i) `curl -s https://ebenezer-dorneles.github.io/robots.txt
  -o /dev/null -w '%{http_code}\n'` → 200; (ii) idem para `/sitemap.xml` →
  200; (iii) `curl -s https://ebenezer-dorneles.github.io/ | grep -c '<meta
  name="robots" content="noindex, nofollow">'` → 1 (prova AC-18.1 no
  deploy real); (iv) **prova de `fetch-depth: 0`**: commitar edit trivial
  (ex.: typo-fix) no post ETL/PRF, push, aguardar run, confirmar pela URL
  do post que a seção "Last updated" renderiza (`last_modified_at` ≠
  `date`) — prova AC-8.1 e indiretamente AC-6.1; (v) **prova de
  `paths-ignore`**: commitar edit só em `README.md`, push, confirmar via
  `gh run list -L 1 --json path,headSha` (ou painel Actions) que **nenhum
  run novo** foi disparado (prova AC-6.2). Resultado de cada curl/edit vai
  em bloco literal no `task.md`.
- **D-10 (supersede Step 6)**: pure bookkeeping no task.md. Fica como
  disciplina a ssd-task aplicar na decomposição; não gera código. Phases
  abaixo listam como fase final para rastreabilidade.
- **O que não muda:** `tools/`, `_layouts/`, `_includes/`, `_data/`,
  `_config.yml`, `.github/`, `_posts/` (exceto o typo-fix de prova de AC-8.1,
  edit intencional de 1 linha). Nenhum arquivo do tema sombreado; nenhum
  bump de gem; nenhuma mudança no gate script.

### Tooling & commands

| Check | Command | Scope | Why |
|---|---|---|---|
| Baseline (antes da Fase 1) | `docker compose run --rm site bash tools/check.sh` | validador + htmlproofer + site_test | registrar contagem exata em HEAD `94ba825`: esperado `26/29/0/0`, `16 arquivos/0 falhas`, `22/37/6/0`. Confirma herança das 6 falhas antes da reescrita D-2. |
| Full test suite | `docker compose run --rm site bash tools/check.sh` | tudo | gate único. **Invariante Fase 1 pós-D-2:** `site_test.rb` passa a `22/≥37/0/0` (6 falhas curadas, assertion count pode crescer). |
| Targeted (Fase 1 — D-2) | `docker compose run --rm site bundle exec ruby -Itest test/site_test.rb` | 22 runs | isola a reescrita sem rebuildar o site a cada iteração (usa `_site/` do último `tools/check.sh`). |
| Targeted (Fase 2 — D-3) | `docker compose run --rm site bundle exec ruby tools/validate-front-matter.rb` + `docker compose run --rm site bash tools/check.sh` | validador + full gate | confirma que (a) rename das fixtures mantém validador verde (fixtures passam no front matter check) e (b) full gate segue `22/≥37/0/0`. |
| Static analysis | `docker compose run --rm site ruby -wc test/site_test.rb` | `site_test.rb` após D-2 | pega typo de sintaxe que o minitest não acha até a asserção rodar. |
| Lint / formatting | `bash -n tools/check.sh` | `check.sh` | precaução; nenhuma edição prevista. |
| Artifact regeneration | `docker compose run -d --rm --service-ports site bash tools/run.sh -H 0.0.0.0` + `curl http://localhost:4000/` | preview local | opcional, só para inspeção visual pós-D-2 (home, categoria, tag, post ETL/PRF); não automatizado. |
| Verification externa (D-5) | `curl -s -o /dev/null -w '%{http_code}\n' https://ebenezer-dorneles.github.io/{robots.txt,sitemap.xml}` + `curl -s https://ebenezer-dorneles.github.io/ \| grep -c 'noindex, nofollow'` + edit→push→`gh run list` | site publicado + Actions | prova AC-6.1, AC-6.2, AC-8.1, AC-17.1, AC-17.2, AC-18.1 no deploy real. Requer push ter ocorrido. |

**Baseline a registrar em task.md antes da Fase 1:** contagem exata das três
suites + conjunto nomeado das 6 falhas atuais em `site_test.rb` + hash do
HEAD (`git rev-parse HEAD`).

### Review & code standards

- **Autor único, sem PR** (mesmo padrão do BLOG-1/BLOG-3). Antes de cada
  commit: `auditoria-de-impacto` sobre o diff. Para D-2, pedir foco explícito
  em "6 asserções reescritas sem perder cobertura de AC" (regredir um AC é
  ruído silencioso que o gate não pega — o teste passa pelo motivo errado).
- **Padrão Ruby** (não muda): `# frozen_string_literal: true`, `snake_case`,
  minitest declarativo sem DSL, `Nokogiri` já disponível (confirmar em
  `Gemfile.lock`; se não, decidir no Red da Fase 1 entre `Nokogiri` e
  `Regexp` — a convenção atual de `site_test.rb` é `File.read` + `include?`
  simples, idiomaticamente preservar).
- **Convenção `# @spec`** (do BLOG-3): preservar tags existentes sobre os
  métodos reescritos. Se um teste reescrito passar a cobrir ACs adicionais,
  **somar** à tag (`# @spec FR-9 AC-9.1 FR-10 AC-10.1`), não substituir.
- **Diretrizes de escopo** (não fazer): não mudar `_config.yml`; não tocar
  `_posts/` (exceto o typo-fix controlado da Fase 3 para prova de AC-8.1,
  revertível por `git revert`); não mexer no workflow do GitHub; não
  renomear métodos `test_*` (mudança de interface do minitest).
- **Nomes dos métodos de `site_test.rb`**: `test_indice_de_busca_lista_os_tres_posts_ficticios`
  cita "três posts fictícios" no nome — contradiz a invariante estrutural
  pós-D-2. Renomear está fora do escopo (Strategy); registrar como follow-up
  (ver Deferred).

### Phases

Ordenadas por risco crescente: a reescrita de testes é o maior risco
técnico (regredir cobertura silenciosamente). Rename de fixtures e
bookkeeping do task.md são baixo risco. Verification externa depende de
ação do autor fora do SSD (push), por isso vem após o trabalho local.

**Phase 1 — Reescrever `test/site_test.rb` para invariantes estruturais (D-2)** · covers: AC-4.1, AC-5.1, AC-9.1, AC-10.2, AC-16.1, AC-19.1, AC-19.2, D-2, D-8

- **Red:** baseline capturada (confirma 6 falhas pelos nomes atuais). Para
  cada um dos 6 testes, substituir a asserção por slug por invariante
  estrutural e rodar: a nova asserção deve falhar primeiro **pelo motivo
  certo** se o conteúdo não existir — ex.: `test_tempo_de_leitura_visivel_no_post`
  reescrito para "primeiro post iterado em `_site/posts/*/index.html`
  contém `min read`" falha se nenhum post existir. Confirmar o motivo da
  falha nova (não a mesma mensagem "no such file" do baseline).
- **Green:** aplicar as 6 reescritas. Invariantes:
  (a) `test_home_lista_posts_em_ordem_cronologica_decrescente`: extrair
  `<time datetime="…">` da home via regex ou Nokogiri, asserar ≥ 1 e
  ordem decrescente;
  (b) `test_tags_tem_pagina_por_tag_usada`: iterar front matter dos posts
  publicados em `_site/posts/*/index.html` (ou derivar das URLs em
  `search.json`), coletar tags, asserar `_site/tags/<slug(tag)>/index.html`
  para cada;
  (c) `test_indice_de_busca_lista_os_tres_posts_ficticios`: renomear
  internamente (comentário) ou aceitar nome legado; asserar
  `JSON.parse(File.read("_site/assets/js/data/search.json")).size ==
  Dir["_site/posts/*/index.html"].size`;
  (d) `test_tempo_de_leitura_visivel_no_post`, `test_post_tecnico_tem_highlight_e_mermaid`,
  `test_imagem_do_post_e_servida_e_referenciada`: encontrar o primeiro
  post que declare a capacidade (`read_time`/bloco de código/`mermaid: true`
  + fenced block/`image.path`) e asserar sobre ele.
- **Refactor:** extrair helper `published_posts` em `SiteTest`
  (`Dir["_site/posts/*/index.html"]`) se usado em ≥ 3 métodos; `ruby -wc`
  limpo.
- **Done when:** `tools/check.sh` → `site_test.rb` `22/≥37/0/0` (todas verdes;
  assertion count pode subir); `grep -c "# @spec" test/site_test.rb` continua
  22 (invariante do BLOG-3); `grep -nE "RASCUNHO|analise-exploratoria|api-tarefas-ruby|visualizando-pipelines" test/site_test.rb` sem saída (slugs mortos exorcizados);
  `auditoria-de-impacto` fecha sem achado de "regressão de AC".

**Phase 2 — Renomear fixtures sem `[RASCUNHO]` (D-3)** · covers: D-3, armadilha `check_draft_guard` pré-flip

- **Red:** `grep -c "\[RASCUNHO\]" test/fixtures/site_posts/*.md` → 2
  (estado atual). Simular flip local provisório: `sed -i 's/^noindex: true/noindex: false/' _config.yml`
  (num shell throwaway, sem commitar) + `docker compose run --rm site bundle
  exec ruby tools/validate-front-matter.rb` deve **reprovar** com
  `check_draft_guard` sobre as fixtures symlinkadas pelo `check.sh`.
  Reverter o `_config.yml` imediatamente (`git checkout _config.yml`).
  Prova que D-3 é precondição real do flip.
- **Green:** editar `test/fixtures/site_posts/2026-01-01-fixture-post-projeto.md:2`
  removendo `[RASCUNHO] ` do `title`; idem para `2026-01-02-fixture-post-comum.md:2`.
  Nenhuma outra edição.
- **Refactor:** nada.
- **Done when:** `grep -c "\[RASCUNHO\]" test/fixtures/site_posts/*.md` → 0;
  `tools/check.sh` segue `22/≥37/0/0` (idem Fase 1); simulação pós-rename
  (mesma `sed` throwaway) agora passa no validador (prova a precondição do
  flip).
- **Not test-first?** o "teste" aqui é a simulação local do flip — não há
  teste minitest dedicado porque validar `[RASCUNHO]` + `noindex: false`
  já é coberto pelos testes de `check_draft_guard` em
  `test/validate_front_matter_test.rb` (não precisam de novo teste).

**Phase 3 — Verification externa pré-flip (D-5)** · covers: AC-6.1, AC-6.2, AC-8.1, AC-17.1, AC-17.2, AC-18.1, D-5

- **Precondição:** autor executou `git push origin main` (ou merge de
  `blog-1-mvp` → `main`) e workflow finalizou verde. Fora do SSD; o plan
  registra isso como pré-requisito, não como passo deste plan.
- **Red:** `curl -s -o /dev/null -w '%{http_code}\n' https://ebenezer-dorneles.github.io/`
  antes do push → 404 (confirmado em AU-19 do spec rev 2); se já ≠ 404,
  o push aconteceu entre a aprovação deste plan e o start desta Fase.
- **Green:** executar os 5 cheques da Strategy (D-5), em ordem:
  1. `curl -s -o /dev/null -w '%{http_code}\n' https://ebenezer-dorneles.github.io/robots.txt` → 200
  2. `curl -s -o /dev/null -w '%{http_code}\n' https://ebenezer-dorneles.github.io/sitemap.xml` → 200
  3. `curl -s https://ebenezer-dorneles.github.io/ | grep -c '<meta name="robots" content="noindex, nofollow">'` → 1
  4. **Prova fetch-depth: 0 / AC-8.1**: typo-fix de 1 linha em
     `_posts/2026-09-29-etl-dados-prf.md`, commit (`fix(content): typo em
     etl-prf post`), push, aguardar run, `curl -s https://ebenezer-dorneles.github.io/posts/<slug>/
     | grep -c 'Last updated'` → ≥ 1
  5. **Prova paths-ignore / AC-6.2**: edit só em `README.md` (uma linha),
     commit (`docs(readme): minor copy edit`), push, `gh run list -L 2
     --json path,headSha,createdAt --jq '.[0].headSha'` → igual ao SHA do
     commit **anterior** (do passo 4), não ao do commit do README. Alternativa
     sem `gh`: olhar aba Actions do repo e confirmar que o commit do README
     não aparece.
- **Refactor:** registrar comando + resultado literal (incluindo exit code
  e primeiros 200 caracteres do output quando aplicável) em `task.md ##
  Verification → Phase 3 — Verification externa (D-5)`, uma subseção por
  cheque. É esse registro que fecha D-5.
- **Done when:** 5 cheques registrados com resultados conforme esperado;
  nenhum re-run de workflow pendente; `gh run list -L 3` mostra 2 runs
  bem-sucedidos (push inicial + typo-fix); AC-18.3 (parte "repo HTTP 200")
  verificada manualmente para o único post `project: true` (`curl -s -o
  /dev/null -w '%{http_code}\n' https://github.com/ebenezer-dorneles/etl-prf-data`
  → 200, habilitado por D-6).
- **Not test-first?** Verification externa é **inspeção de deploy real**,
  não TDD; o "Red" é o estado pré-push (site 404). Substituto da falha-por-asserção
  é a conferência linha-a-linha do resultado esperado × resultado observado,
  registrada no task.md.

**Phase 4 — Supersede subitens do Step 6 do BLOG-1 (D-10)** · covers: D-10

- **Red:** `grep -c "~~" docs/specs/blog-portfolio/task.md` → 0 nos subitens
  do Step 6 (nenhum superseded registrado ainda).
- **Green:** quando ssd-task decompuser este plan, aplicar: cada subitem
  aberto do Step 6 do BLOG-1 em `task.md ## Checklist` (bloco citação
  task.md:16-23 e o próprio Step 6 na Execution Log de 2026-09-18) ganha
  wrapping `- [ ] ~~<item>~~ (superseded by BLOG-2 Fase técnica D-5)`;
  `## Deviations` do task.md ganha linha datada citando D-10 como fonte.
  Nenhum item é apagado.
- **Refactor:** nada.
- **Done when:** `grep -c "superseded by BLOG-2" docs/specs/blog-portfolio/task.md`
  ≥ 1; ssd-status para BLOG-1 Step 6 não acusa mais "unchecked checklist
  items pendentes do Step 6" como blocker.
- **Not test-first?** reorganização documental; a asserção é o grep acima.

### Coverage

| Item | Phase | Test / check |
|---|---|---|
| AC-4.1 (tempo de leitura visível) | 1 | `site_test.rb test_tempo_de_leitura_visivel_no_post` reescrito (invariante: primeiro post com `read_time` renderiza `min read`) |
| AC-5.1 (asset local existe) | 1 | `test_imagem_do_post_e_servida_e_referenciada` reescrito (invariante: para primeiro post com `image.path`, asset existe em `assets/img/posts/<slug>/`) |
| AC-9.1 (home ordem cronológica) | 1 | `test_home_lista_posts_em_ordem_cronologica_decrescente` reescrito (invariante: `<time datetime>` extraído da home em ordem decrescente, D-8) |
| AC-10.2 (página por tag) | 1 | `test_tags_tem_pagina_por_tag_usada` reescrito (invariante: para cada tag usada por post publicado, existe `_site/tags/<slug>/index.html`) |
| AC-16.1 (`search.json` existe) | 1 | `test_indice_de_busca_lista_os_tres_posts_ficticios` reescrito (invariante: `search.json.size == publicados.size`) — nome legado mantido no método; renomear fica em Deferred |
| AC-19.1 (Rouge highlight) | 1 | `test_post_tecnico_tem_highlight_e_mermaid` reescrito (invariante: primeiro post com fenced code block tem `<div class="highlight">`) |
| AC-19.2 (Mermaid em `post`) | 1 | mesmo teste (invariante: primeiro post com `mermaid: true` renderiza `language-mermaid`) |
| AC-6.1 (workflow dispara em push de arquivo do site) | 3 | D-5 passo 4 (edit em `_posts/`, push, run aparece em `gh run list`) |
| AC-6.2 (`paths-ignore` não dispara em README-only) | 3 | D-5 passo 5 (edit em `README.md`, push, nenhum run novo) |
| AC-8.1 (`last_modified_at` em ≥ 2 commits) | 3 | D-5 passo 4 (post com 2 commits mostra "Last updated" no HTML publicado) |
| AC-17.1 (sitemap.xml 200) | 3 | D-5 passo 2 (`curl` externo) |
| AC-17.2 (robots.txt 200) | 3 | D-5 passo 1 (`curl` externo) |
| AC-18.1 (meta robots `noindex, nofollow`) | 3 | D-5 passo 3 (`curl` externo + grep) |
| AC-18.3 (parte "repo HTTP 200") | 3 | D-5 Done when (curl no `repo` do post ETL/PRF, agora 200 pós-D-6) |
| D-2 (reescrita de `site_test.rb`) | 1 | Fase 1 inteira |
| D-3 (fixtures sem `[RASCUNHO]`) | 2 | Fase 2 inteira |
| D-5 (Verification externa pré-flip) | 3 | Fase 3 inteira |
| D-6 (`etl-prf-data` público) | — | já concluído pelo autor em 2026-09-29 (Context + task.md Execution Log 2026-09-29) |
| D-7 (Pages Source = GitHub Actions) | — | já concluído pelo autor em 2026-09-29 (Context + task.md Execution Log 2026-09-29) |
| D-8 (invariante home via fixtures) | 1 | aplicado na reescrita de AC-9.1 (fixtures + post real = ≥ 2 datas ordenáveis no gate local) |
| D-10 (supersede Step 6) | 4 | Fase 4 inteira |
| AC-7.1 (histórico via git) | — | propriedade do modelo (explícito no spec); verify por inspeção `git log` sobre o typo-fix do passo 4 da Fase 3 |
| AC-8.2 (`last_modified_at` em 1 commit) | — | implícito no AC-8.1: o post ETL/PRF antes do typo-fix é o caso de 1 commit (Last updated ausente). Registrar observação em task.md Verification da Fase 3 (não requer passo dedicado) |
| AC-8.3 (checkout raso quebra) | — | armadilha documentada no spec; sem teste automatizado (explícito) |
| AC-11.1 (CATEGORIES constante única) | — | coberto pelo BLOG-3 (plan.md:407); inalterado por BLOG-2 Fase técnica |
| AC-14.1 (público sem auth) | — | implícito nos 5 cheques `curl` da Fase 3 (todos sem credenciais, resposta 200). Registrar observação em task.md Verification |
| AC-15.1 (giscus) | — | Fase 2 (FR-15); fora do BLOG-2 |
| AC-18.2 (meta ausente pós-flip) | — | Fase de conteúdo (gated no D-11); fora do BLOG-2 Fase técnica |
| AC-18.3 (contador "≥ 10 posts reais") | — | Fase de conteúdo (operacional, pré-flip); fora do BLOG-2 Fase técnica |
| AC-19.3 (Mermaid em `project-post`) | — | garantido por D-4 sem teste dedicado (plan.md:423); nenhum post `project-post` + Mermaid existe hoje além do ETL/PRF, que já é `project: true` + `mermaid: true` — AC-19.3 fica implicitamente coberto pelo mesmo teste reescrito da Fase 1 (confirmar no Refactor) |
| AC-20.1 (preview local ≡ CI) | — | manual/visual (AU-32); fora do escopo técnico desta fase |
| D-4 (sombreamento `js-selector.html`) | — | fato consumado em `4083351`; inalterado |
| D-9 (diff manual em bumps) | — | disciplina processual (R-3); não acionada neste plan (sem bump do Chirpy) |
| D-11 (gate de 10 posts) | — | Fase de conteúdo; fora do BLOG-2 Fase técnica |
| D-12 (modernização UC/FR/AC) | — | entregue por BLOG-3 (`76cb996` + `e87db58`) |
| D-13 (procedimento despublicação) | — | ativa só pós-flip; fora do BLOG-2 Fase técnica |

**Nenhum AC/decisão do escopo sem destino.** AC-18.2, AC-18.3, AC-15.1 e
D-11/D-13 ficam explicitamente diferidos à Fase de conteúdo (gated no marco
de 10 posts reais) ou à Fase 2 do projeto — registrado em Deferred.

### Rollout & rollback

N/A — spec rev 4 não requer `## Migration & rollout` para esta fase (não há
migração de dado; nenhum breaking change de API; mudanças locais em
`test/site_test.rb` + fixtures + bookkeeping de task.md). Rollback por fase:

- **Fase 1 (D-2):** `git revert <sha da reescrita>` restaura as 6 asserções
  antigas (gate volta a `22/37/6/0`); nenhum efeito externo.
- **Fase 2 (D-3):** `git revert <sha do rename>` restaura `[RASCUNHO]` nos
  títulos; `check_draft_guard` volta a reprovar pré-flip (estado atual).
- **Fase 3 (D-5):** Verification é observacional (curl + inspeção); o único
  commit alcançável é o typo-fix do passo 4 e o edit do README do passo 5
  — ambos reversíveis por `git revert`. Reversão do typo-fix mantém AC-8.1
  provado (o fato ocorreu; o commit de prova pode ser desfeito depois).
- **Fase 4 (D-10):** edit de documentação (`task.md`); `git revert` restaura
  checklist original.

Sem feature flag. Sem coordenação com deploy (D-5 **observa** o deploy;
não o modifica).

### Deferred

- **Fase de conteúdo (gated no D-11):** flip do `noindex` (`_config.yml`
  `noindex: true` → `false`) + Verification pós-flip (home sem meta robots;
  sitemap continua; htmlproofer verde; `curl` nos `repo`s de todos
  `project: true` → 200). Pré-condição: ≥ 10 posts reais no `_posts/`.
  Cronologia: semanas a meses, conforme spec (`### BLOG-2 → Fase de conteúdo`).
  Plan separado quando o marco for atingido.
- **Dívida de infra do workflow:** trocar passos inline `Build site`/`Test
  site` do `.github/workflows/pages-deploy.yml` por `bash tools/check.sh`
  (hoje o validador só roda no gate local, não no CI). Fora do escopo do
  BLOG-2 por decisão explícita da spec (`### BLOG-2 → Fora do escopo`).
  Vira issue própria quando o workflow for tocado.
- **Rename do método `test_indice_de_busca_lista_os_tres_posts_ficticios`:**
  pós-D-2 o nome contradiz a invariante (não cita mais "três posts
  fictícios"). Rename está fora do escopo da Fase 1 (Review & code
  standards). Follow-up para quando outro trabalho tocar `site_test.rb`.
- **Dívida de i18n do `project-post`** (D-4, BLOG-1 Step 4): strings pt-BR
  fixas no layout; vira issue própria em fase 2 com `hreflang` + prefixo
  de idioma.
- **Reconciliação de `_includes/js-selector.html` / `metadata-hook.html` em
  bumps do Chirpy** (D-9/R-3): disciplina processual, não trabalho ativo
  deste plan. Primeiro bump pós-BLOG-2 ativa.

### Spec gaps

Nenhum. Spec rev 4 aprovada em `## Approvals` (autor, 2026-09-29); D-2, D-3,
D-5, D-10 todos têm Decisions estabelecidas desde rev 2; D-6/D-7 (fatos
consumados pelo autor em 2026-09-29) alinhados com D-11 (Fase técnica
executável agora). Nenhum AU-n open em qualquer `## Audit — rev N`.

**Nota de tamanho do arquivo:** este `plan.md` já cruzou a marca de ~250
linhas desde a abertura de BLOG-3 (plan.md:465-469 registra). Com esta nova
seção, `plan.md` fica em ~730 linhas. O contrato do ssd-plan prevê que a
compactação (mover detalhe de plan finalizado para `task.md` Execution Log e
deixar pointer aqui) seja responsabilidade do ssd-task no próximo pass.
Registrado novamente para ssd-task tratar ao decompor BLOG-2 Fase técnica.
