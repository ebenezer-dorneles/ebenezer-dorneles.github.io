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
