---
issues: [BLOG-1, BLOG-2, BLOG-3]
status: in-progress
phase: planning
spec-revision: 4
tier: M
---

# Blog de portfólio (Ciência de Dados & Dev)

Blog pessoal estático, hospedado no GitHub Pages, para publicar artigos técnicos sobre
projetos de Ciência de Dados e Desenvolvimento — portfólio complementar ao GitHub.
O conteúdo é escrito em Markdown com front matter YAML, versionado no próprio
repositório do blog, e publicado por `git push` para `main`. As superfícies que o
visitante toca são: home (lista cronológica), página de post, páginas de categoria e
de tag, busca client-side e página "sobre" com links de contato. A superfície que o
autor toca é o repositório Git mais `bundle exec jekyll serve` para preview local.

**Fora de escopo (este spec, qualquer fase):** login/cadastro de usuários,
monetização, múltiplos autores, CMS ou painel administrativo, backend próprio,
qualquer banco de dados.

---

## Regras de negócio

<!--
Numeração estável — o restante do documento referencia estas regras por número.

**LEGADO (a partir da rev 4).** Esta seção é o registro histórico das regras
originais do BLOG-1. A forma canônica atual está em `## Requirements` abaixo
(UC-1..UC-13, FR-1..FR-20, com AC-n verificáveis). A tabela de mapeamento
`regra ↔ FR/AC` está em `## Requirements → ### Mapeamento das regras 1–15`.
Decisões futuras devem citar `FR-n`/`AC-n.m`, não `regra N`. Decisões
narrativas do BLOG-1 abaixo (em `## Decisions`) conservam a numeração
original como parte do registro imutável.
-->

**Conteúdo e estrutura**

1. Todo post deve conter, no front matter: título, data de publicação, categoria
   (Ciência de Dados ou Desenvolvimento), ao menos 1 tag, e status (rascunho ou
   publicado).
2. Um post só é visível publicamente quando está publicado e a data de publicação é
   menor ou igual à data atual.
3. Todo post sobre um projeto deve conter link para o repositório GitHub correspondente.
4. Cada post deve indicar o tempo estimado de leitura, calculado automaticamente a
   partir da contagem de palavras.
5. Imagens e diagramas usados em posts ficam versionados dentro do próprio repositório
   do blog, sem dependência de hospedagem externa.

**Publicação e versionamento**

6. A publicação ocorre exclusivamente via `git push`/merge para `main`; não há painel de
   administração nem CMS externo.
7. Todo o histórico de edições de um post é rastreável pelo histórico de commits do Git.
8. Alterações em posts já publicados mantêm a data de publicação original; uma data de
   "última atualização" pode ser adicionada em revisão relevante.

**Navegação e organização**

9. Posts são listados em ordem cronológica decrescente na página inicial.
10. Cada categoria e cada tag possui uma página própria listando os posts associados.
11. As categorias principais são fixas em duas (Ciência de Dados, Desenvolvimento);
    tags são livres.

**Identidade e portfólio**

12. O blog exibe, em cabeçalho ou rodapé, links para GitHub, LinkedIn e/ou e-mail de
    contato do autor.
13. Cada post que documenta um projeto segue uma estrutura mínima sugerida: contexto,
    stack técnica, processo, resultado e aprendizados.

**Acesso**

14. Todo o conteúdo publicado é público e de leitura livre, sem autenticação.
15. Comentários, se habilitados, usam serviço de terceiros autenticado via GitHub
    (giscus), sem sistema de contas próprio.

---

## Requirements

Introduzida na revisão 4 (por AU-24/D-12 do rev 2). Modernização retroativa das
regras 1–15 em `UC-n` (casos de uso), `FR-n` (requisitos funcionais) e `AC-n.m`
(critérios de aceitação verificáveis). A partir daqui, decisões e testes citam
FR/AC diretamente. `## Regras de negócio` continua como referência histórica —
ver `### Mapeamento das regras 1–15` no fim desta seção.

Escopo desta seção: **conteúdo, publicação, navegação, identidade, acesso e
indexação** — tudo que o BLOG-1/BLOG-2 tocam. NFR / Constraints & dependencies
/ Interfaces / requests permanecem como dívida legada aceita (AU-25).

### Actors

- **Autor** — pessoa única (Ebenézer Dorneles) que escreve, revisa e publica.
  Toca o repositório Git e o `bundle exec jekyll serve` local.
- **Leitor** — visitante deslogado que consome via web. Sem autenticação; sem
  conta.
- **Buscador** — bot de rastreio (Google, Bing, DuckDuckGo). Age
  independentemente da vontade do autor; o único mecanismo de controle é a
  meta `robots` (FR-18) e o `sitemap.xml` (FR-17).

### Use case coverage

| UC | Descrição | Fase | Motivo | FRs |
|----|-----------|------|--------|-----|
| UC-1 | Autor cria e publica um post (fluxo padrão) | MVP | Núcleo do blog | FR-1, FR-2, FR-6, FR-7 |
| UC-2 | Autor publica post sobre um projeto | MVP | Objetivo declarado (portfólio) | FR-3, FR-13 |
| UC-3 | Autor atualiza um post publicado | MVP | Cotidiano; hook do starter já resolve | FR-8 |
| UC-4 | Autor adiciona imagens/diagramas a um post | MVP | Regra 5 + itens do MVP | FR-5, FR-19 |
| UC-5 | Autor previsualiza localmente antes de publicar | MVP | Item explícito do MVP | FR-20 |
| UC-6 | Leitor abre a home | MVP | Núcleo do blog | FR-9, FR-14 |
| UC-7 | Leitor navega por categoria | MVP | Regras 10/11 | FR-10, FR-11 |
| UC-8 | Leitor navega por tag | MVP | Regra 10 | FR-10 |
| UC-9 | Leitor busca conteúdo | MVP | Item MVP explícito | FR-16 |
| UC-10 | Leitor lê um post | MVP | Núcleo do blog | FR-4, FR-14, FR-19 |
| UC-11 | Leitor identifica autor e vias de contato | MVP | Regra 12 | FR-12 |
| UC-12 | Leitor comenta num post | Later (fase 2) | Depende de repo público + tráfego | FR-15 |
| UC-13 | Buscador rastreia e indexa o site | Split | MVP com `noindex: true` (FR-18 restringe); Fase de conteúdo BLOG-2 libera (D-1/D-11) | FR-17, FR-18 |

Nenhum UC caiu como *dropped*; UC-12 é o único *later*. Fase técnica do BLOG-2
não introduz UC novo — apenas satisfaz UC-13 no seu estado com `noindex: true`.

### Functional requirements

#### FR-1 — Front matter obrigatório em posts publicáveis

Toda entrada em `_posts/` deve ter, no front matter YAML: `title` não-vazio,
`date` válida, `categories` com exatamente 1 item pertencente ao conjunto fixo
`{Ciência de Dados, Desenvolvimento}`, `tags` como lista com ≥ 1 item onde cada
item é string minúscula sem acento. Rascunhos em `_drafts/` podem omitir
`date`. O validador (`tools/validate-front-matter.rb`) reprova o build no CI e
no gate local (`tools/check.sh`) em qualquer violação.

- **AC-1.1** — Given post em `_posts/` sem chave `title` ou com `title: ""`,
  When `bundle exec ruby tools/validate-front-matter.rb`, Then exit code != 0
  e stdout contém `<caminho>: title: ausente` ou `<caminho>: title: vazio`.
- **AC-1.2** — Given post em `_posts/` sem chave `date`, When validador, Then
  exit != 0 e stdout contém `<caminho>: date: ausente`.
- **AC-1.3** — Given post em `_posts/<AAAA-MM-DD-slug>.md` cujo prefixo do
  filename não bate `AAAA-MM-DD-`, When validador, Then exit != 0 e mensagem
  aponta o filename inválido (Jekyll ignora esses arquivos em silêncio; o
  validador não).
- **AC-1.4** — Given post com `categories` ausente, `categories: []` ou
  `categories` com ≥ 2 itens, When validador, Then exit != 0.
- **AC-1.5** — Given post com `categories: [X]` onde X ∉ `{Ciência de Dados,
  Desenvolvimento}`, When validador, Then exit != 0 (constante única em
  `FrontMatterValidator::CATEGORIES`).
- **AC-1.6** — Given post com `tags` ausente ou `tags: []`, When validador,
  Then exit != 0.
- **AC-1.7** — Given post com `tags: [X]` onde X contém maiúscula ou acento,
  When validador, Then exit != 0.
- **AC-1.8** — Given post em `_drafts/` sem `date`, When validador, Then
  exit == 0 (drafts não precisam de data).

#### FR-2 — Visibilidade condicional de posts

Um post é publicamente visível **somente quando** vive em `_posts/`, tem
`published: true` (default) e sua `date` é ≤ "agora" no fuso do site
(`America/Sao_Paulo`, D-15 do BLOG-1). Nenhum post fora dessas condições
aparece em `_site/`.

- **AC-2.1** — Given arquivo em `_drafts/`, When `jekyll build` (sem
  `--drafts`), Then não gera página em `_site/`.
- **AC-2.2** — Given post em `_posts/` com `published: false`, When build,
  Then não gera página em `_site/`.
- **AC-2.3** — Given post em `_posts/` com `date` no futuro relativo a
  `America/Sao_Paulo`, When build (config default `future: false`), Then não
  gera página em `_site/`.

#### FR-3 — Post-de-projeto expõe link do repositório

Post declarado como projeto (`project: true`) exige `repo` válido e `layout:
project-post`; o HTML publicado contém o link do repositório em posição fixa
(bloco antes do `{{ content }}`).

- **AC-3.1** — Given post com `project: true` e sem `repo`, When validador,
  Then exit != 0.
- **AC-3.2** — Given `project: true` e `repo` que não bate
  `https://github.com/<owner>/<repo>`, When validador, Then exit != 0.
- **AC-3.3** — Given `project: true` e `layout` != `project-post`, When
  validador, Then exit != 0.
- **AC-3.4** — Given post `project: true` renderizado, When leitor abre a URL,
  Then o HTML contém `<a href="{{ page.repo }}"` no bloco do layout
  `project-post`, antes do corpo do post.

#### FR-4 — Tempo de leitura visível no post

Cada post publicado exibe uma indicação de tempo estimado de leitura calculado
pelo tema (Chirpy `read_time` include).

- **AC-4.1** — Given post publicado com ≥ 100 palavras, When leitor abre a URL,
  Then o HTML contém elemento com classe/ícone de tempo de leitura do tema
  (`.post-meta` com string tipo "X min read").

#### FR-5 — Assets versionados no próprio repositório

Imagens e diagramas usados por posts vivem em `assets/img/posts/<slug>/`.
Nenhuma dependência de hospedagem externa para conteúdo próprio. O
`htmlproofer` (gate) reprova referência a imagem inexistente.

- **AC-5.1** — Given post que declara `image.path: foo.png` com `media_subpath:
  /assets/img/posts/<slug>/`, Then o arquivo `assets/img/posts/<slug>/foo.png`
  existe no repositório.
- **AC-5.2** — Given `_site/` construído com referência a imagem interna
  inexistente, When `bash tools/test.sh` (htmlproofer com
  `--disable-external`), Then exit != 0.

#### FR-6 — Publicação exclusiva via git push para `main`

Publicação ocorre pelo push (ou merge) para `main`; nenhum outro caminho.
Commits que só alteram `README.md`, `.gitignore` ou `LICENSE` não disparam o
workflow.

- **AC-6.1** — Given commit em `main` que modifica arquivo do site (post,
  layout, `_config.yml`, asset), When push, Then o workflow
  `.github/workflows/pages-deploy.yml` dispara.
- **AC-6.2** — Given commit em `main` que só modifica `README.md` (ou
  `.gitignore`, ou `LICENSE`), When push, Then o workflow **não** dispara
  (`paths-ignore` do starter).

#### FR-7 — Histórico via git

Todas as edições em posts (criação, alteração, remoção) ficam rastreáveis via
`git log <arquivo>`. Nenhum mecanismo alternativo (CMS externo, banco).

- **AC-7.1** — Property of the model — não requer teste; é consequência de FR-6
  (publicação via git push para `main`). Verify confirma inspecionando um
  post e o `git log` correspondente.

#### FR-8 — `last_modified_at` automático a partir de commits

Post com múltiplos commits mostra "última atualização" no HTML publicado,
preenchida pelo hook `_plugins/posts-lastmod-hook.rb` do starter a partir do
`git log`. Post com um único commit não mostra a seção.

- **AC-8.1** — Given post com ≥ 2 commits, When build (com `fetch-depth: 0` no
  workflow), Then o HTML publicado contém `last_modified_at` != `date` e
  renderiza a seção "última atualização" do tema.
- **AC-8.2** — Given post com 1 commit só, When build, Then o HTML **não**
  contém a seção "última atualização" (hook detecta `last_modified_at ==
  date`).
- **AC-8.3** — Given workflow com `fetch-depth: 0` mudado para checkout raso,
  When build, Then o hook falha silenciosamente e AC-8.1 quebra. Documentada
  como armadilha; sem teste automatizado por depender de mudança do workflow.

#### FR-9 — Home em ordem cronológica decrescente

A página inicial (`/`) lista os posts publicados em ordem decrescente por
`date`.

- **AC-9.1** — Given N ≥ 2 posts publicados com datas distintas, When leitor
  abre `/`, Then a ordem no HTML respeita `date_i > date_{i+1}`. Verificado no
  `test/site_test.rb` (invariante estrutural — D-2/D-8).

#### FR-10 — Página própria por categoria e por tag

Cada categoria em uso e cada tag em uso ganha uma página listando os posts
associados.

- **AC-10.1** — Given post com `categories: [X]`, When build, Then
  `_site/categories/<slug(X)>/index.html` existe e lista o post.
- **AC-10.2** — Given post com `tags: [Y]`, When build, Then
  `_site/tags/<slug(Y)>/index.html` existe e lista o post.

#### FR-11 — Conjunto fixo de categorias

O conjunto de categorias válidas é `{Ciência de Dados, Desenvolvimento}` e não
pode ser alterado sem revisão de spec. Tags são livres. Corolário do FR-1
AC-1.5 mais o constraint sobre o conjunto.

- **AC-11.1** — Given `tools/validate-front-matter.rb`, Then
  `FrontMatterValidator::CATEGORIES` == `["Ciência de Dados", "Desenvolvimento"]`
  (constante única, sem duplicação em outros arquivos).

#### FR-12 — Links de contato visíveis em todas as páginas

Toda página do site publicado contém, em cabeçalho ou rodapé, links para:
GitHub do autor, LinkedIn do autor, e e-mail (mailto).

- **AC-12.1** — Given qualquer URL do site publicado (home, post, categoria,
  tag, about), When leitor abre, Then o HTML contém:
    (a) `href="https://github.com/ebenezer-dorneles"` (ou `https://github.com/ebenezer-dorneles/*`);
    (b) `href="https://www.linkedin.com/in/ebedorneles/"` (ou perfil equivalente);
    (c) `href="mailto:ebenezerdorneles@gmail.com"`.
  Confirmado pelo `test/site_test.rb` para a home.

#### FR-13 — Template mínimo de post-de-projeto

Post-de-projeto (`project: true`) segue estrutura mínima sugerida com 5 seções:
contexto, stack técnica, processo, resultado, aprendizados. É **diretriz
editorial**, não é validada por script.

- **AC-13.1** — Given autor criando um novo post-de-projeto, Then existe
  `_drafts/template-projeto.md` com as 5 seções em headings `##` e front matter
  que passa no validador.
- **AC-13.2** — Given post publicado com `project: true`, When revisão humana,
  Then presença/ausência das 5 seções é observada — não bloqueia CI.

#### FR-14 — Acesso público sem autenticação

Todo conteúdo publicado é acessível sem login. Nenhum redirect para tela de
autenticação em nenhuma URL do site.

- **AC-14.1** — Given URL qualquer do site publicado, When leitor deslogado
  faz GET, Then resposta é `200 OK` (ou `301/302` só para redirect de
  trailing slash), nunca `401/403` nem redirect para login.

#### FR-15 — Comentários via giscus (fase 2)

Fase 2. Comentários, quando habilitados, usam giscus (autenticação por GitHub
OAuth). Sem sistema de contas próprio.

- **AC-15.1** — Fase 2. Given `_config.yml` com `comments.provider: giscus` e
  `comments.giscus.repo/repo_id/category/category_id` preenchidos, When post
  publicado, Then o widget do giscus aparece no fim do post e usa GitHub OAuth
  para postagem.

#### FR-16 — Busca client-side embutida

Site oferece busca sobre o conteúdo dos posts publicados, sem servidor de
busca externo.

- **AC-16.1** — Given site publicado com ≥ 1 post, Then
  `assets/js/data/search.json` existe com uma entrada por post contendo
  `title`, `url`, `categories`, `tags`, `date`, `content`.
- **AC-16.2** — Given leitor digita no campo de busca do tema, Then os posts
  que casam por título/conteúdo aparecem em resultados (verificado
  visualmente; automação da UI fora de escopo).

#### FR-17 — Sitemap e robots.txt disponíveis

Site publica `sitemap.xml` e `robots.txt` acessíveis no root, gerados pelos
plugins `jekyll-sitemap` do gem.

- **AC-17.1** — Given site publicado, When `GET https://<host>/sitemap.xml`,
  Then `200 OK` com XML listando todos os posts publicados.
- **AC-17.2** — Given site publicado, When `GET https://<host>/robots.txt`,
  Then `200 OK`.

#### FR-18 — `noindex` gated no marco de conteúdo (D-1, D-11)

O site emite meta `robots` `noindex, nofollow` em todas as páginas enquanto a
chave `noindex: true` estiver ativa em `_config.yml`. A troca para
`noindex: false` (Etapa B do D-1) só ocorre com ≥ 10 posts reais publicados
(D-11) — "real" = sem `[RASCUNHO]` no `title` **e** (se `project: true`)
`repo` responde HTTP 200 para leitor deslogado.

- **AC-18.1** — Given `_config.yml` com `noindex: true`, When leitor abre
  qualquer URL do site, Then o HTML `<head>` contém `<meta name="robots"
  content="noindex, nofollow">` (emitido por `_includes/metadata-hook.html`
  — sombreamento autorizado).
- **AC-18.2** — Given `_config.yml` com `noindex: false` (ou chave removida),
  When leitor abre qualquer URL, Then a meta `robots noindex` **não** está
  presente.
- **AC-18.3** — Given `_posts/` contém ≥ 10 arquivos `.md` sem `[RASCUNHO]`
  no `title`, e cada um com `project: true` tem `repo` que responde 200,
  When autor decide flipar, Then a condição do D-11 está satisfeita e
  `noindex: false` pode ser aplicado. Verificado pelo contador
  `count=$(grep -rL '\[RASCUNHO\]' _posts/ | wc -l); [ "$count" -ge 10 ]`
  mais checagem manual/scriptada dos `repo` HTTP 200 (Fase de conteúdo passo 2).

#### FR-19 — Realce de sintaxe e Mermaid renderizados

Posts que usam blocos de código têm realce Rouge; posts com `mermaid: true` no
front matter renderizam diagramas Mermaid. Vale para `layout: post` e para
`layout: project-post` (sombreamento de `_includes/js-selector.html` por D-4).

- **AC-19.1** — Given post com fenced code block em qualquer linguagem, Then o
  HTML publicado contém `<div class="highlight">` ou `<pre class="highlight">`
  gerado pelo Rouge.
- **AC-19.2** — Given post com `mermaid: true` e bloco Mermaid, When leitor
  abre a URL, Then o navegador carrega `mermaid.min.js` e o diagrama renderiza
  como SVG.
- **AC-19.3** — Given post com `layout: project-post` e `mermaid: true` +
  bloco Mermaid, When leitor abre, Then o comportamento é idêntico a AC-19.2
  (garantido pelo sombreamento de `_includes/js-selector.html`, D-4/`4083351`).

#### FR-20 — Preview local reproduz o build de produção

Autor pode rodar o site localmente e ver o mesmo output que o CI produz.

- **AC-20.1** — Given repositório com `Gemfile.lock` versionado, When autor
  roda `docker compose run --rm --service-ports site bash tools/run.sh -H
  0.0.0.0` (Ruby 3.4 no container, mesma versão do runner do Actions), Then
  `http://localhost:4000` responde 200 com o mesmo layout, meta tags e
  conteúdo que o CI publica (validado por inspeção visual, não automatizado).

### Mapeamento das regras 1–15

| Regra | FR/AC canônico | Notas |
|-------|----------------|-------|
| 1 | FR-1 (AC-1.1..1.8) + FR-11 (AC-11.1) | Categorias fixas em 2 estão em AC-1.5 e FR-11. Status "rascunho vs publicado" é FR-2 (drafts) + Jekyll `published: false` (D-4 do BLOG-1). |
| 2 | FR-2 (AC-2.1..2.3) | Visibilidade condicional; comportamento nativo Jekyll (`future: false` + timezone). |
| 3 | FR-3 (AC-3.1..3.4) | Validador cobra `repo`/`layout`; renderização em `project-post`. |
| 4 | FR-4 (AC-4.1) | Tema Chirpy calcula e renderiza. |
| 5 | FR-5 (AC-5.1..5.2) + FR-19 (AC-19.2 para diagramas) | Assets versionados; htmlproofer é gate. |
| 6 | FR-6 (AC-6.1..6.2) | `paths-ignore` no workflow. |
| 7 | FR-7 (AC-7.1) | Propriedade do modelo; verify por inspeção. |
| 8 | FR-8 (AC-8.1..8.3) | Hook do starter + `fetch-depth: 0`. |
| 9 | FR-9 (AC-9.1) | Comportamento nativo Jekyll. |
| 10 | FR-10 (AC-10.1..10.2) | `jekyll-archives` gera as páginas. |
| 11 | FR-11 (AC-11.1) + FR-1 (AC-1.5) | Constante única no validador. |
| 12 | FR-12 (AC-12.1) | Todas as páginas; validado por `site_test.rb`. |
| 13 | FR-13 (AC-13.1..13.2) | AC-13.2 é diretriz editorial. |
| 14 | FR-14 (AC-14.1) | Pages gratuito → repositório público (D do BLOG-1). |
| 15 | FR-15 (AC-15.1) | Fase 2 (giscus). |

FR-16..FR-20 são requisitos adicionais que não têm regra numerada correspondente
mas eram itens do MVP ou consequência de decisões (D-1/D-11 para FR-18, D-4
para FR-19).

---

## Data sources (confirmed in code)

Confirmado em 2026-09-17 contra `jekyll-theme-chirpy` **7.6.0** (gem desempacotado) e
contra o `cotes2020/chirpy-starter` (branch `main`). Ver `## Audit — 2026-09-17` para o
que o spike derrubou.

Não há banco de dados nem API: o que o build lê é o sistema de arquivos. A primeira
tabela diz **onde** o dado mora; a segunda, que é o contrato que o validador do CI
verifica, diz **qual** dado.

### Onde o dado mora

| Data source | Where it's defined | Origem | Notes |
|---|---|---|---|
| Posts publicados | `_posts/AAAA-MM-DD-slug.md` | nosso | Jekyll exige o prefixo de data **no nome do arquivo**; `date` no front matter sobrescreve a hora. |
| Rascunhos | `_drafts/slug.md` (sem prefixo de data) | nosso | Não entram no build sem `--drafts`. Mecanismo nativo para a regra 1. |
| Configuração do site | `_config.yml` | starter | Chaves confirmadas: `theme`, `lang`, `timezone`, `title`, `tagline`, `description`, `url`, `github.username`, `social.{name,email,links}`, `toc`, `cdn`, `assets.self_host`, `analytics.*`, `comments.*`, `actions.edit_post`, `theme_mode`. Alterações aqui **não** são recarregadas por `jekyll serve` — exige restart. |
| Links de contato do autor | `_data/contact.yml` (+ `social.links` no `_config.yml`) | starter | Atende a regra 12. Não vem do gem — é arquivo do starter. |
| Destinos de compartilhamento | `_data/share.yml` | starter | O tema já renderiza os botões via `_includes/post-sharing.html`. |
| Strings de interface por idioma | `_data/locales/<lang>.yml` | gem | `pt-BR.yml` existe no 7.6.0. Fora `locales/` e `origin/`, o gem não traz `_data/`. |
| Origem dos assets estáticos | `_data/origin/{cors,basic}.yml` | gem | `cors` (jsDelivr + Google Fonts) é o **default**; `basic` (local, `/assets/lib/`) só com `assets.self_host.enabled: true`. Ver `_includes/origin-type.html`. |
| Imagens de post | `assets/img/posts/<slug>/`, apontadas por `media_subpath` | nosso | Regra 5. `media_subpath` é o mecanismo do tema para o caminho base. |
| Hook de última modificação | `_plugins/posts-lastmod-hook.rb` | starter | Preenche `last_modified_at` a partir de `git log`. Depende de histórico completo no checkout. |
| Build/deploy | `.github/workflows/pages-deploy.yml` | starter | `fetch-depth: 0`, Ruby 3.4, `htmlproofer` como gate, `actions/deploy-pages`. |
| Comentários (fase 2) | `_config.yml` (`comments.provider: giscus`) | starter | Suportado nativamente. `repo_id`/`category_id` são gerados pelo giscus.app, não inventáveis. |

### Contrato de front matter

Campos que o tema **lê** (confirmado por `grep` em `_layouts/` e `_includes/` do gem
7.6.0) mais os dois campos nossos. "Obrigatório" significa: ausente reprova o build.

| Campo | Obrigatório | Tipo | Valores aceitos / formato | Quem lê | Regra |
|---|---|---|---|---|---|
| `title` | sim | string | livre, não vazio | tema | 1 |
| `date` | sim em `_posts/` | data | `AAAA-MM-DD HH:MM:SS +/-HHMM` | tema | 1, 2 |
| `categories` | sim | lista com exatamente 1 item | `Ciência de Dados` \| `Desenvolvimento` | tema | 1, 11 |
| `tags` | sim | lista, ≥ 1 item | livre, minúsculas, sem acento | tema | 1, 11 |
| `project` | não (default `false`) | booleano | `true` exige `repo` e `layout: project-post` | **validador** | 3, 13 |
| `repo` | sim **se** `project: true` | string | `https://github.com/<owner>/<repo>` | nosso layout | 3 |
| `layout` | sim se `project: true` | string | `project-post` | tema | 3 |
| `description` | não | string | ≤ 160 caracteres (limite prático de SEO) | tema | — |
| `image` | não | mapa | `path` + `alt` | tema | 5 |
| `media_subpath` | não | string | `/assets/img/posts/<slug>/` | tema | 5 |
| `mermaid` | não | booleano | `true` carrega o Mermaid na página | tema | — |
| `math` | não | booleano | `true` carrega MathJax | tema | — |
| `toc` | não (default `site.toc`) | booleano | `false` desliga o índice do post | tema | — |
| `comments` | não | booleano | `false` desliga comentários no post | tema | 15 |
| `lang` | não (default `site.lang`) | string | precisa existir em `_data/locales/` | tema | — |
| `published` | não (default `true`) | booleano | `false` despublica sem apagar o arquivo | Jekyll | 1 |
| `last_modified_at` | **não — preenchido pelo hook** | data | não escrever à mão | tema | 8 |

Limitações que o validador **não** cobre, e que ficam por conta da revisão humana:

- Se `repo` aponta para um repositório que existe e é público — o script valida formato,
  não existência (validar existência exigiria chamada de rede no CI, e o `htmlproofer`
  do workflow roda com `--disable-external`).
- Se as cinco seções da regra 13 estão presentes — é diretriz editorial, ver Decisions.
- O campo `project` existe justamente porque "é um post sobre projeto" não é detectável
  automaticamente. Sem ele a regra 3 não seria verificável por máquina: o autor declara,
  e o validador cobra o `repo` a partir da declaração. Marcar `project: false` num post
  que é de projeto continua sendo um erro que só revisão humana pega.

---

## Decisions

- **Build via GitHub Actions, não pelo build nativo do GitHub Pages** — a
  especificação inicial assumiu "Jekyll + Chirpy com build automático do Pages, sem CI
  próprio". O spike do audit mostrou que isso é impossível por **três** razões
  independentes, não uma: (a) `jekyll-archives`, dependência do Chirpy 7.6.0 que gera as
  páginas de categoria e tag da regra 10, está fora da allowlist do `github-pages`;
  (b) o gem `github-pages` (v232) fixa `jekyll = 3.10.0`, enquanto o Chirpy exige
  `jekyll ~> 4.3` — conflito de versão que nenhuma configuração resolve; (c) o starter
  traz `_plugins/posts-lastmod-hook.rb`, e plugins locais são ignorados pelo build
  nativo. A resolução é o workflow de Actions que o próprio starter já entrega. Custo: um
  arquivo de workflow. Preservado: publicação por `git push` para `main`, gratuita, sem
  servidor. Descartado: trocar o Chirpy por tema whitelist-compatível (perderia busca,
  tempo de leitura e arquivos prontos) e escrever à mão as páginas de cada tag (inviável,
  regra 11 diz que tags são livres).
- **Jekyll + Chirpy, não Hugo/Quarto/Astro** — Jekyll é o caminho de menor atrito no
  ecossistema GitHub e o Chirpy já cobre, sem código, quatro regras de negócio:
  categorias/tags (10), tempo de leitura (4), busca (busca client-side embutida) e
  Mermaid (via `mermaid: true`). Descartado: Hugo/Quarto — ganho real só quando houver
  necessidade de notebooks ou gráficos gerados no build, o que não existe na v1 (segue
  registrado como caminho de migração); Astro/Next — mais poder de customização em
  troca de manutenção de dependências JS, desproporcional para um blog de texto.
- **Chirpy consumido como `jekyll-theme-chirpy` (gem) a partir do Starter, não como
  fork do tema** — atualizar o tema passa a ser um bump de versão no `Gemfile` em vez
  de merge de upstream num fork divergente. Descartado: fork do repositório do tema
  (permite customizar tudo, mas transforma cada update em conflito); `remote_theme`
  (não suportado fora do build nativo do Pages, que já foi descartado acima).
- **A regra 1 (`status: draft | published`) é implementada pelos mecanismos nativos do
  Jekyll, não por um campo `status` customizado** — `_drafts/` para o que está em
  elaboração, `_posts/` para o que está publicado, e `published: false` no front matter
  como escape para despublicar algo sem apagar. Um campo `status` customizado não é lido
  por nada no Jekyll: exigiria filtro manual em cada layout e listagem, e um esquecimento
  publicaria um rascunho. A semântica da regra é preservada; o campo, não.
- **A regra 2 (post visível só quando a data ≤ hoje) é o comportamento padrão do
  Jekyll** (`future: false`), mais o `timezone` fixado em `_config.yml` para que "hoje"
  signifique o mesmo no runner do Actions e na máquina local. Nenhum código próprio.
- **Validação de front matter como script executado no CI, bloqueando o deploy** — as
  regras 1, 3 e 11 são obrigações ("deve"), e obrigação sem verificação é convenção que
  decai. O script checa: campos obrigatórios presentes; `categories` com exatamente uma
  das duas categorias fixas; ao menos uma tag; e, quando `project: true`, que `repo` é
  URL de repositório GitHub e que `layout` é `project-post`. Descartado: pre-commit hook
  (não roda no Actions, e é local por máquina); revisão manual (é justamente o que decai).
- **Validador escrito em Ruby, em `tools/validate-front-matter.rb`** — Ruby já está no
  ambiente de build (`ruby/setup-ruby` + `bundler-cache` no workflow), lê YAML com a
  stdlib (`yaml` + `safe_load`) e não adiciona nenhum passo ao CI. `tools/` é onde o
  starter já guarda `run.sh` e `test.sh`, então o script fica junto do que já existe.
  Roda no workflow **antes** do `jekyll b`, para falhar rápido e barato. Descartado:
  Python — mais familiar num contexto de Ciência de Dados, mas custaria um `setup-python`
  a mais no workflow para resolver um problema que o runtime já presente resolve; e um
  plugin Jekyll que abortasse o build (acoplaria a validação ao build, impedindo rodá-la
  isolada e deixando a mensagem de erro dentro do log do Jekyll).
- **A regra 3 (link para o repositório) é um campo `repo` no front matter, renderizado
  por um layout filho `project-post`** — campo é verificável pelo script e renderizável
  em posição fixa; link no meio do texto não é nem um nem outro. O spike mostrou que o
  tema não tem seam para campos customizados: `_layouts/post.html` inclui apenas
  `datetime`, `lang`, `post-edit`, `post-sharing`, `read-time` e `toc-status`. Sobrescrever
  `_layouts/post.html` inteiro reintroduziria exatamente a divergência com o upstream que
  a decisão de usar o gem evita. A saída é herança de layout: `_layouts/project-post.html`
  com `layout: post` no próprio front matter, acrescentando o bloco do repositório ao
  redor de `{{ content }}`. Nenhum arquivo do tema é sobrescrito, e um bump de versão do
  Chirpy não toca esse arquivo. Custo: posts de projeto declaram `layout: project-post`
  (o validador cobra isso quando `project: true`).
- **A regra 13 (estrutura mínima: contexto, stack, processo, resultado, aprendizados) é
  um template em `_drafts/`, não uma validação** — é diretriz editorial, e validar
  presença de headings engessaria posts que legitimamente fogem do formato.
- **Categorias fixas em duas, tags livres** — como na regra 11. As duas categorias vivem
  como constante única no script de validação, para não haver duas listas divergindo.
- **Imagens em `assets/img/posts/<slug>/`, versionadas** — regra 5, sem hospedagem
  externa. Consequência aceita: o repositório cresce com binários; a mitigação é
  redimensionar antes de commitar, não Git LFS (LFS tem cota própria e complica o
  checkout do Actions).
- **Repositório `ebenezer-dorneles.github.io`, servido na raiz** — evita `baseurl`, a
  fonte clássica de links quebrados que só aparecem em produção. O site fica em
  `https://ebenezer-dorneles.github.io`. Descartado: repositório de projeto com
  `baseurl: /blog`.
- **Conteúdo do MVP é fictício, para prototipagem** — os posts da primeira entrega são
  *fake*, escritos só para exercitar o tema: sem eles não é possível verificar ordenação
  cronológica (9), páginas de categoria e tag (10), busca, tempo de leitura (4) nem
  sitemap. Consequências aceitas e obrigatórias: cada post fictício traz `title` com
  prefixo `[RASCUNHO]`, o `repo` aponta para um placeholder sintaticamente válido (o
  validador checa formato, não existência) e **todos são removidos antes de o blog ser
  divulgado a qualquer leitor**. Publicar portfólio com projeto inventado é o pior
  resultado possível para o objetivo declarado. Descartado: prototipar com os posts
  reais (atrasa a entrega técnica esperando redação) e prototipar com o post de exemplo
  do tema (um post só não exercita listagem, arquivo nem busca).
- **MVP em pt-BR, inglês como fase 2, com a estrutura preparada desde já** — o objetivo
  é ter os dois idiomas, mas pagar a i18n agora custa customização de layouts e da
  geração de páginas de arquivo por idioma (o Chirpy não traz isso de fábrica) e dobra o
  esforço de redação de todo post, para sempre. O MVP sai em pt-BR com `lang: pt-BR` no
  `_config.yml` e `lang` declarável por post, e as URLs pensadas para receber um prefixo
  de idioma depois, sem quebrar links existentes. Descartado por ora: pares traduzidos
  com `hreflang` e seletor de idioma (fase 2, issue própria); um idioma por post sem
  tradução (deixaria parte do blog ilegível para metade do público-alvo).
- **`Gemfile.lock` versionado, contrariando o `.gitignore` do starter** — o starter
  ignora o lock (convenção de gem, não de site). Com `gem "jekyll-theme-chirpy", "~> 7.6"`
  e sem lock, cada build do Actions resolve as versões de novo: um 7.7.0 publicado pelo
  upstream muda o site sem nenhum commit do autor, e a máquina local passa a divergir do
  CI. Para um site, build reproduzível vale mais que lock atualizado. Descartado: fixar
  versão exata no `Gemfile` (esconde as transitivas, que é onde a surpresa mora).
- **Assets estáticos via CDN (default `cors`), sem o submódulo `assets/lib`** — o starter
  declara um submódulo (`.gitmodules` → `chirpy-static-assets`) e deixa `submodules: true`
  **comentado** no workflow. Self-host exige as três coisas alinhadas (submódulo clonado,
  `submodules: true` no CI, `assets.self_host.enabled: true` no config); qualquer uma
  faltando quebra o CSS/JS de um jeito que não aparece em teste local. O MVP fica no
  default: jsDelivr + Google Fonts. Consequência aceita: duas dependências de terceiros
  no carregamento da página. A regra 5 cobre imagens de post, não bibliotecas do tema.
  Self-host entra em fase 2, como uma mudança só, se privacidade ou offline pesarem.
- **Ruby 3.4 fixado em `.ruby-version`, igual ao CI** — o workflow do starter fixa
  `ruby-version: 3.4`; a máquina de desenvolvimento tem Ruby 4.0.6. Jekyll 4.3 não é
  testado pelo upstream em Ruby 4.0, e divergência de runtime entre local e CI produz
  exatamente o bug que só aparece em produção. Descartado: subir o CI para 4.0 (sai do
  que o tema suporta).
- **O site nasce com `noindex` global, removido só quando os posts fictícios saírem** —
  o Pages no plano gratuito exige repositório público, então "não divulgado" não é "não
  acessível": com `jekyll-sitemap` e `jekyll-seo-tag` ativos desde o MVP (e ambos são
  itens de MVP), os posts fake seriam rastreados e poderiam sobreviver em cache de
  buscador depois de removidos do repositório. Portfólio indexado com projeto inventado é
  o pior resultado possível para o objetivo. A remoção do `noindex` é o marco de saída do
  MVP, não um detalhe. Descartado: repositório privado (Pages privado exige plano pago);
  confiar em ninguém achar a URL.
- **`timezone: America/Sao_Paulo` explícito** — o starter deixa `timezone:` vazio. A regra
  2 depende do `future: false` do Jekyll, que compara a data do post com "agora" no fuso
  configurado; vazio, local e runner do Actions discordam na virada do dia e um post
  agendado aparece ou desaparece por horas.
- **A regra 8 é atendida automaticamente pelo hook do starter, e entra no MVP** — o spike
  encontrou `_plugins/posts-lastmod-hook.rb`, que preenche `last_modified_at` a partir de
  `git log` quando o post tem mais de um commit, e `_layouts/post.html` já renderiza o
  campo quando ele difere de `date`. Custo zero: nada a implementar, nada a escrever à
  mão. **Armadilha registrada:** o hook depende de histórico completo — o workflow usa
  `fetch-depth: 0`, e trocar isso por checkout raso faz a data de atualização parar de
  aparecer silenciosamente, sem erro de build.
- **Identificador de spec local (`BLOG-<n>`), sem rastreador de issues** — não há
  tracker no projeto, mas `plan.md` precisa de um identificador estável por seção
  (`## Plan — <ISSUE>`). A sequência `BLOG-1`, `BLOG-2`… é atribuída neste próprio spec.
  Descartado: issues do GitHub (overhead de ferramenta para um autor só); deixar o campo
  vazio (quebraria o encadeamento com plan.md e task.md).
- **Analytics, comentários e domínio próprio ficam fora do MVP** — nenhum deles é
  pré-requisito para o objetivo declarado (publicar e ser encontrado), e cada um adiciona
  configuração que precisa ser mantida. Analytics em particular: métrica sem tráfego não
  informa nada, e adiciona um terceiro à página. Correção do audit: **Plausible não é
  suportado pelo tema** — os provedores nativos no `_config.yml` são Google, GoatCounter,
  Umami, Matomo, Cloudflare e Fathom. Se analytics entrar na fase 2, a escolha natural é
  GoatCounter ou Cloudflare (gratuitos e leves); Plausible exigiria sobrescrever o `head`.

### Decisions — BLOG-2 (rev 2)

<!--
Primeiras decisões numeradas da spec (`D-n`). As decisões narrativas acima
seguem como registro histórico do BLOG-1; novas decisões passam a usar o
contrato compartilhado do pipeline.
-->

- **D-1 — Marco de saída executado em duas etapas independentes**
  · type: product · decided-by: user (autor, 2026-09-29, via pedido de revisão)
  · **Etapa A** (feita antes desta revisão): remover os três posts fictícios
  (`686c5c0`) e publicar pelo menos um post real sem prefixo `[RASCUNHO]`
  (`6b16713` — post ETL/PRF). **Etapa B** (gated em conteúdo — ver D-11):
  trocar `noindex: true` para `noindex: false` no `_config.yml`, **somente
  quando o marco de ≥ 10 posts reais publicados for atingido**. D-11 define
  o contador exato, o critério de "post real" e o comando de verificação.
  · Motivo: publicar sem conteúdo real quebra o objetivo declarado; separar
  as etapas permite validar o site com conteúdo real **antes** de expor à
  indexação, que é irreversível na prática (cache de buscador sobrevive à
  reversão do commit — ver `## Risks & assumptions` → R-1).
  · Alternativas rejeitadas: fazer as duas mudanças no mesmo commit (não
  permite janela de validação com conteúdo real); ~~esperar N ≥ 2 posts reais
  para tirar o `noindex`~~ — superseded por **D-11** (contador concreto de 10,
  com critério de "post real" fechado).
  · Evidência: `git log --oneline`; estado atual de `_posts/` e de `_config.yml`.

- **D-2 — `test/site_test.rb` migra para invariantes estruturais**
  · type: technical · decided-by: agent
  · Substituir asserções por slug fictício (`analise-exploratoria-vendas`,
  `api-tarefas-ruby`, `visualizando-pipelines`) por invariantes: (a) a home
  contém ≥ 1 post, ordenados por data decrescente; (b) para cada categoria
  usada por algum post em `_site/`, existe página `/categories/<slug>/`
  correspondente; idem para tags; (c) o índice de busca
  (`assets/js/data/search.json`) contém uma entrada por post real; (d) as
  asserções específicas de Rouge, Mermaid e imagem passam a rodar contra o
  primeiro post que declara cada capacidade — hoje o post ETL/PRF satisfaz
  os três.
  · Motivo: fixar slugs de conteúdo torna a suíte frágil a cada publicação
  ou remoção de post; a suíte reprova hoje porque os slugs dos três fictícios
  foram removidos.
  · Alternativas rejeitadas: atualizar as asserções com os slugs reais a
  cada publicação (mesma fragilidade, custo recorrente indefinido); marcar
  os testes com `skip` (esconde regressão, não a resolve).
  · Evidência: gate atual — `docker compose run --rm site bash tools/check.sh`
  → 6 falhas em `site_test.rb` por slugs ausentes.

- **D-3 — Fixtures em `test/fixtures/site_posts/` deixam de usar prefixo `[RASCUNHO]`**
  · type: technical · decided-by: agent
  · Renomear os títulos das duas fixtures (`fixture-post-projeto`,
  `fixture-post-comum`) para variantes sem `[RASCUNHO]`, preservando os
  slugs de arquivo (usados pelos testes) e o comportamento estrutural
  (uma com `project: true`, uma comum).
  · Motivo: o prefixo `[RASCUNHO]` é gatilho do guardrail `check_draft_guard`
  do validador — proíbe publicar `[RASCUNHO]` com `noindex: false`.
  Fixtures **nunca** são conteúdo publicável, e depois da Etapa B do D-1
  (`noindex: false`) o guardrail passaria a reprovar as próprias fixtures,
  quebrando o gate por um sinal falso.
  · Alternativas rejeitadas: adicionar flag `--allow-draft-marker` só para
  fixtures no validador (aumenta superfície do script para ganhar zero);
  desligar a asserção do guardrail para fixtures via caminho (acopla o
  validador ao layout de teste, invertendo a direção da dependência).
  · Evidência: Watch out do task.md (achado da auditoria de impacto do Step 4).

- **D-4 — Segundo arquivo do tema sombreado: `_includes/js-selector.html`**
  · type: technical · decided-by: agent (registra fato consumado em `4083351`)
  · O include seleciona o bundle JS por `page.layout == "post"` e o layout
  filho `project-post` faz `page.layout` valer `project-post` (herança de
  layout no Jekyll **não** propaga o nome). Sem sombreamento, posts de
  projeto caem no bundle `commons.min.js` e ficam sem `mermaid.initialize`,
  dayjs, lazy-polyfill, glightbox, clipboard e pageviews — quebrando o item
  de MVP "Realce de sintaxe (Rouge) e Mermaid verificados em um post que use
  ambos" para o único tipo de post que a spec destaca (projeto).
  · Diverge da **letra** da decisão original ("nenhum arquivo do tema
  sobrescrito") mas não do **motivo** — diferente do `metadata-hook.html`
  (placeholder vazio, feito para ser sobrescrito), este é código do tema, e
  bumps do Chirpy podem exigir reconciliação. Aceito porque as alternativas
  são piores.
  · Alternativas rejeitadas: (i) copiar mermaid/dayjs/etc. inline no
  `project-post.html` (duplica lógica do tema, diverge silenciosamente de
  mudanças upstream); (ii) trocar `layout: project-post` por `layout: post` e
  injetar o bloco do repositório via `include` acionado por `page.project`
  (perde a garantia estrutural do layout dedicado, item explícito de MVP);
  (iii) contribuir upstream com um cheque mais frouxo (fora de escopo, adia
  a entrega); (iv) manter o cheque original e chamar `mermaid.initialize`
  à mão no post — não resolve dayjs/lazy-polyfill/glightbox/clipboard.
  · **Consequência aceita:** `_includes/js-selector.html` sombreado precisa
  ser reconciliado a cada bump do Chirpy — item permanente de Watch out.
  · Evidência: `git show 4083351`; `_includes/js-selector.html` do gem 7.6.0
  (branch original) vs. o nosso.

- **D-5 — Verification do primeiro deploy é feita dentro do BLOG-2**
  · type: product · decided-by: user (autor, 2026-09-29, via pedido de revisão)
  · O Step 6 do BLOG-1 (README, `origin`, primeiro deploy, Verification
  externa) ficou meio-executado no código: `README.md` existe, `origin`
  aponta para o repositório público, o post real ETL/PRF foi de fato
  publicado via Actions — mas a Verification (comandos + resultados) nunca
  entrou no `task.md`. A revisão 2 registra que essa Verification é feita
  como parte do BLOG-2, num único bloco coerente que também cobre a troca
  do `noindex`, em vez de simular retroativamente uma validação do BLOG-1.
  · Motivo: os checks externos do Step 6 (`robots.txt`/`sitemap.xml`
  respondendo 200, meta `noindex` presente antes e ausente depois,
  `last_modified_at` num segundo commit, `paths-ignore` do workflow) só
  fazem sentido no estado pós-marco de saída — antes da troca do `noindex`,
  metade das asserções seria diferente. Fechar Step 6 antes de BLOG-2 é
  Verification em cima de estado transitório.
  · Alternativas rejeitadas: (a) refazer a Verification retroativa do BLOG-1
  agora e outra vez depois de `noindex: false` (duplica trabalho por
  formalismo); (b) declarar Step 6 fechado sem Verification (viola a regra
  da própria skill task de gravar comando + resultado); (c) pular a
  Verification externa (perde a prova do `fetch-depth: 0` e do
  `paths-ignore`, dois itens explícitos do plan).

- **D-6 — Precondição para Etapa B do D-1: `etl-prf-data` público**
  · type: product · decided-by: user (autor, 2026-09-29, via AU-18 do
  `## Audit — rev 2 — 2026-09-29`)
  · Repositório `github.com/ebenezer-dorneles/etl-prf-data` existe mas
  está privado; leitor deslogado recebe 404 na primeira ação do post
  ETL/PRF (clicar no link do projeto). Tornar o repositório público antes
  de aplicar `noindex: false`. Requer conferência manual prévia de que
  não há conteúdo sensível commitado (segredos, `.env`, dados internos,
  drafts não publicados) — responsabilidade do autor.
  · Alternativas rejeitadas: apontar `repo:` para outro repositório público
  (não casa com o conteúdo específico do post); tirar `project: true` (o
  post deixa de ser post-de-projeto, exatamente o tipo que a spec destaca);
  deferir a Etapa B (adia a saída do MVP sem razão de conteúdo).
  · Consequência operacional: entra como **primeiro item** do plan do
  BLOG-2, antes da troca do `noindex`.

- **D-7 — Diagnosticar Pages Source como primeira ação técnica do plan de BLOG-2**
  · type: product · decided-by: user (autor, 2026-09-29, via AU-19 do
  `## Audit — rev 2 — 2026-09-29`)
  · Site publicado responde 404 hoje. Sem `gh` no host, o diagnóstico
  requer o autor abrindo `github.com/ebenezer-dorneles/ebenezer-dorneles.github.io/settings/pages`
  e `.../actions`, conferindo (a) Pages Source = "GitHub Actions", (b)
  status do último workflow run. Hipótese principal: Watch out do Step 6
  (Pages Source nunca confirmado, ficou em "Deploy from a branch" default)
  — nesse caso, habilitar Pages Source e um push republica. Se o
  diagnóstico revelar workflow quebrado (ex.: `htmlproofer` batendo em
  link do post real, `configure-pages` falhando), escalar via **CR nova**
  no `plan.md` do BLOG-2.
  · Alternativas rejeitadas: (a) instalar `gh` no host + `gh auth login`
  interativo só para diagnosticar (custo alto, autor confere mais rápido
  no painel web); (b) tentar cegamente refazer o push sem diagnóstico
  (arrisca outro build que não resolve e apaga sinal do problema
  original).
  · Evidência adicional: `command -v gh` sem saída (2026-09-29).

- **D-8 — Invariante "home em ordem cronológica descrescente" verificado via fixtures**
  · type: technical · decided-by: agent (2026-09-29, via AU-21 do delta audit rev 2)
  · FR-9 (AC-9.1) exige "home em ordem cronológica decrescente". Com 1 post real
  no `_posts/`, a asserção do site publicado é trivialmente verdadeira. Resolução:
  manter D-2 como está — a ordem é verificada no `tools/check.sh`, que roda
  com fixtures symlinkadas (`2026-01-01` + `2026-01-02` + posts reais = sempre
  ≥ 2 elementos ordenáveis), garantindo cobertura estrutural do código do
  tema. No site publicado com 1 post, a asserção é vacuamente verdadeira
  até o 2º post real — comportamento aceito, reversível na primeira
  publicação seguinte.
  · Alternativa rejeitada: exigir ≥ 2 posts reais como pré-condição para
  Etapa B do D-1 (atrasa saída do MVP por asserção que já tem cobertura
  de teste).

- **D-9 — Detecção de drift do tema em bumps do Chirpy: diff manual documentado**
  · type: technical · decided-by: agent (2026-09-29, via AU-22 do delta audit rev 2)
  · Sombreamento de `_includes/js-selector.html` (D-4) e
  `_includes/metadata-hook.html` precisa ser reconciliado a cada bump do gem.
  Mecanismo: no commit que sobe a versão do `jekyll-theme-chirpy`, executar
  `docker compose run --rm site diff -u $(bundle show jekyll-theme-chirpy)/_includes/js-selector.html _includes/js-selector.html`
  e idem para `metadata-hook.html`; colar o output (mesmo se vazio) no
  corpo do commit message. Documento único de disciplina, sem automação
  em CI — bumps são raros e manuais. Consequência aceita: bump sem checagem
  quebra mermaid/toc em produção, regressão **visível**, não silenciosa.
  · Alternativa rejeitada: check automatizado no CI (custo de manutenção
  desproporcional à frequência real do gatilho).

- **D-10 — Subitens do Step 6 no `task.md` viram `superseded by BLOG-2` na abertura do plan de BLOG-2**
  · type: technical · decided-by: agent (2026-09-29, via AU-23 do delta audit rev 2)
  · O checklist do Step 6 (BLOG-1) permanece desmarcado no `task.md` — desalinhado
  com D-5, que consolida a Verification em BLOG-2. Resolução: quando
  `ssd-task` decompuser o BLOG-2, os subitens abertos do Step 6 passam a
  `- [ ] ~~item~~ (superseded by BLOG-2)`, e `## Deviations` do task.md
  ganha uma linha datada registrando o superseded. Nada é apagado; a
  rastreabilidade fica intacta.
  · Alternativa rejeitada: marcar como concluídos sem Verification (viola
  a regra do próprio ssd-task de gravar comando + resultado); deixar
  desmarcado indefinidamente (torna ambíguo o estado do BLOG-1).

- **D-11 — Etapa B do D-1 (flip do `noindex`) tem pré-condição de conteúdo: ≥ 10 posts reais publicados**
  · type: product · decided-by: user (autor, 2026-09-29, via AU-20 do delta audit rev 2)
  · Refina o D-1 Etapa B: `noindex: true` → `noindex: false` só é aplicado
  quando `_posts/` contém **≥ 10 posts reais publicados**, onde "real" =
  sem prefixo `[RASCUNHO]` no `title` **e** (se `project: true`) com `repo`
  que responde HTTP 200 para leitor deslogado (D-6 aplicado). O gate deixa
  de ser "validação visual" (AU-20) e passa a ser contador concreto e
  verificável:
    `count=$(grep -rL '\[RASCUNHO\]' _posts/ | wc -l); [ "$count" -ge 10 ]`
  · Motivo: portfólio publicado com 1 post é frágil demais para justificar
  exposição a busca — cache de buscador é irreversível na prática
  (Decisions do BLOG-1 e AU-26), e primeira impressão de um portfólio
  quase vazio pesa contra o objetivo declarado. 10 posts é limite
  suficiente para o site ter cara de portfólio, exercitar múltiplas
  categorias e tags, e para as invariantes do D-2 rodarem contra volume
  real em vez de por vacuidade.
  · Consequência para o plan de BLOG-2: divide-se em duas fases naturais.
  **Fase técnica (executável agora):** tornar `etl-prf-data` público (D-6),
  configurar Pages Source (D-7), reescrever `test/site_test.rb` para
  invariantes (D-2), ajustar fixtures (D-3), verificar deploy do estado
  atual com `noindex: true` (D-5), consolidar 4083351/6b16713. **Fase de
  conteúdo (gated):** o flip do `noindex` fica em espera até o 10º post
  real existir. Pode levar semanas ou meses; é característica desejada,
  não bug do processo.
  · Alternativas rejeitadas: (a) valor menor (5 posts insuficiente para
  cara de portfólio); (b) prazo em vez de contagem (data arbitrária
  desliga a métrica que importa); (c) manter D-1 como está sem AC (AU-20
  reabre); (d) publicar sem `noindex` e assumir que ninguém vai achar
  (autor confia no anonimato — quebra em qualquer link compartilhado).
  · Encaminhamento: requer edit em D-1 (adicionar a precondição explícita
  no texto de Etapa B, ligando para D-11) e na subseção `### BLOG-2 —
  Marco de saída do MVP` de `## Scope` (dividir "pendente" em "agora" vs
  "no marco de 10 posts"). Deferido para **ssd-spec** (revisão 3).

- **D-12 — Modernização UC-n/FR-n/AC-n em issue própria (BLOG-3), precede execução do plan de BLOG-2**
  · type: technical · decided-by: user (autor, 2026-09-29, via AU-24 do delta audit rev 2)
  · Regras de negócio 1–15 da spec legada são convertidas em `UC-n`/`FR-n`/`AC-n`
  numa issue dedicada (`BLOG-3`) antes de o plan de BLOG-2 começar. BLOG-2
  continua registrado na spec (D-1..D-11, D-13, subseção BLOG-2 do Scope) mas
  seu plan e execução esperam BLOG-3 fechar a modernização estrutural.
  · Motivo: garantir que o plan de BLOG-2 — que introduz D-11 gated em
  conteúdo, testes reescritos e mudança de config sensível — seja escrito
  sobre estrutura sólida, com Coverage rastreável até FR-n/AC-n em vez do
  proxy "regra 3", "regra 9" (agora `FR-3`, `FR-9` a partir da rev 4). Reconhece o custo aceito: adiar a fase
  técnica do BLOG-2 (repo público, Pages Source, testes migrados,
  fixtures ajustadas) por trabalho estrutural.
  · Consequência operacional: pipeline vira `spec rev 3 (edits awaiting) →
  audit delta → aprovação → BLOG-3 (rev 4 de modernização + plan + task +
  verify) → BLOG-2 (plan sobre spec modernizada) → task → verify`.
  Estado atual (gate local vermelho, `noindex: true`, site 404) **permanece
  durante todo BLOG-3**. O autor aceita essa janela.
  · Alternativa rejeitada: modernizar dentro do BLOG-2 (mistura escopo);
  aceitar como dívida legada (AU-24 fica aberta indefinidamente); só FR-n
  para BLOG-2 (mistura estilos, cria dívida durável).

- **D-13 — Procedimento de despublicação de emergência depois de `noindex: false`**
  · type: product · decided-by: user (autor, 2026-09-29, via AU-26 do delta audit rev 2)
  · Uma vez que Etapa B do D-1 seja aplicada (após o marco de 10 posts do
  D-11) e o site esteja indexado por buscadores, o procedimento para
  despublicar em emergência é o seguinte, escolhido pela natureza do
  problema:

  **(A) Post com erro editorial ou informação incorreta:**
    1. `git revert <sha>` do commit que introduziu o problema **ou** edit
       corretivo do post com atualização de `last_modified_at`.
    2. `git push` para `main`; Actions republica em minutos.
    3. Recrawl orgânico do Google leva horas a dias. Se urgente:
       Google Search Console → Inspeção de URL → Solicitar indexação.

  **(B) Dado sensível vazado (segredo, e-mail privado, dado de terceiro
  sem consentimento):**
    1. Remover o conteúdo do post e re-publicar imediatamente (mesmo fluxo A).
    2. Para que a URL antiga não sobreviva em cache:
       - Google: Search Console → Remoções → Solicitar remoção temporária
         (efeito imediato, dura ~6 meses; renovar ou consolidar depois);
       - Bing: Bing Webmaster Tools → Content Removal.
    3. Se o dado estava em commit anterior, reescrever histórico:
       `git filter-repo --path <arquivo> --invert-paths` seguido de
       `git push --force-with-lease origin main`. Cuidado: reescreve `main`;
       fazer numa janela de baixo tráfego.
    4. Se o vazamento for reputacionalmente crítico e (1)–(3) forem
       insuficientes, tornar `ebenezer-dorneles.github.io` privado
       temporariamente (perde Pages no plano gratuito, o site fica offline)
       enquanto se reescreve o histórico. Restaurar público depois.

  **(C) O que nunca fazer:** commit "silencioso" que apaga arquivo sem
  `git revert` visível — quebra o FR-7 (histórico via git) e
  esconde o incidente do próprio autor no futuro.

  · Motivo: sem procedimento pré-escrito, resposta a incidente é
  improvisada sob pressão — o autor toma decisões erradas (force push sem
  `--force-with-lease`, revert que não recrawla, remoção de arquivo sem
  apagar da URL indexada, esquecer do cache do Bing). Documentar antes do
  incidente é o único jeito.
  · Alternativa rejeitada: aceitar como consequência do modelo Pages
  público (autor navega documentação de dois consoles durante incidente
  ativo — perde tempo crítico).

---

## Scope

### MVP

- Scaffold do Chirpy Starter no repositório (`jekyll-theme-chirpy ~> 7.6`), com
  `Gemfile` e `Gemfile.lock` versionados — exige remover `Gemfile.lock` do `.gitignore`
  herdado — e `.ruby-version` com `3.4`, igual ao CI.
- `_config.yml` preenchido: `title`, `tagline`, `description`, `url:
  "https://ebenezer-dorneles.github.io"`, `lang: pt-BR`, `timezone: America/Sao_Paulo`,
  `github.username: ebenezer-dorneles`, `social.{name,email,links}`.
- Workflow `.github/workflows/pages-deploy.yml` publicando de `main`, com build verde.
  Mantém `fetch-depth: 0` (o hook de `last_modified_at` depende disso) e deixa
  `submodules: true` comentado (MVP não usa o submódulo de assets).
- **Configurar Pages → Source = "GitHub Actions" nas settings do repositório** — passo
  manual, fora do Git. Sem ele o `actions/deploy-pages` falha; com a fonte em "Deploy from
  a branch" o workflow roda e não publica.
- `README.md` do repositório com o fluxo de publicação: escrever → `bundle exec jekyll
  serve` → commit → push → build do Actions → publicado (regra 6, caso de uso
  "visualizar localmente").
- `tools/validate-front-matter.rb` (Ruby, stdlib) rodando no workflow antes do build e
  reprovando o deploy em caso de violação das regras 1, 3 e 11 — com as duas categorias
  fixas como constante única no script, mais um caso de teste por regra violável.
- Template de post de projeto em `_drafts/` com as cinco seções da regra 13.
- Home em ordem cronológica decrescente (regra 9) e páginas de categoria e de tag
  (regra 10) funcionando, verificadas com os posts de prototipagem. Confirmar no caminho
  que `categories` com **um** item só renderiza bem — o Chirpy suporta hierarquia de dois
  níveis (`[Pai, Filho]`) e o contrato fixa um nível.
- Página "sobre" e links de GitHub / LinkedIn / e-mail visíveis em todas as páginas
  (regra 12).
- Busca client-side embutida do tema, verificada com ao menos dois posts.
- Tempo estimado de leitura visível no post (regra 4).
- `jekyll-seo-tag` + `jekyll-sitemap` ativos; `sitemap.xml` e `robots.txt` acessíveis
  no site publicado (ator Buscador), **com `noindex` global enquanto houver post
  fictício** (ver Decisions).
- Layout `_layouts/project-post.html` (herdando `layout: post`) renderizando o link do
  repositório a partir do campo `repo` (regra 3).
- Data de última atualização aparecendo em post com mais de um commit (regra 8), via o
  hook do starter — verificar, não implementar.
- Realce de sintaxe (Rouge) e Mermaid verificados em um post que use ambos.
- **Três posts fictícios de prototipagem** — o MVP não está entregue com o blog vazio,
  porque nenhuma das regras de navegação, busca e SEO é verificável sem conteúdo. São
  descartáveis por construção: um em cada categoria, o terceiro com código, Mermaid e
  imagem, para exercitar Rouge, diagramas e `assets/img/posts/`. Ver Decisions para as
  marcações obrigatórias e a remoção antes da divulgação.
- Remoção dos posts fictícios + remoção do `noindex` registradas como o marco de saída
  do MVP, não esquecidas no repositório.
- `bash tools/test.sh` verde localmente — o starter já traz build de produção mais
  `htmlproofer`, e o workflow roda o mesmo como gate. **Consequência para os posts
  fictícios:** imagem ou link interno inexistente reprova o build; `repo` placeholder não
  reprova, porque o `htmlproofer` roda com `--disable-external`.

### Out of scope / future phases

- **Comentários via giscus** — depende de repositório público e de GitHub Discussions
  habilitado, e os IDs vêm de um passo manual no giscus.app. Fase 2, quando houver
  leitores para comentar (regra 15 já define o provedor).
- **Analytics** — fase 2, e quando entrar será GoatCounter ou Cloudflare, não Plausible
  (não suportado pelo tema — ver Decisions). Decisão adiada até existir tráfego para medir.
- **Domínio próprio + `CNAME`** — fase 2. Reforça identidade, mas troca a URL do site e
  exige DNS; fazer depois que o conteúdo estiver estável evita links mortos.
- **Versões em inglês dos posts (i18n completa)** — decidida como fase 2, com issue
  própria: exige `hreflang`, seletor de idioma, prefixo de idioma nas URLs e páginas de
  arquivo por idioma. O MVP só garante que essa porta fica aberta (ver Decisions).
- ~~**`last_modified_at`**~~ — retirado de fora de escopo pelo audit: o starter traz o
  hook que preenche o campo a partir do `git log` e o tema já o renderiza. Passou a item
  de MVP (verificação, não implementação).
- **Self-host dos assets estáticos do tema** (submódulo `assets/lib` +
  `assets.self_host.enabled`) — fase 2, como uma mudança isolada. Tira jsDelivr e Google
  Fonts do carregamento, ao custo de três pontos de configuração que têm de estar
  alinhados (ver Decisions).
- **Migração para Hugo/Quarto** — registrada como caminho natural caso apareça a
  necessidade de notebooks executados ou gráficos gerados no build. Sem gatilho hoje.
- ~~**Botões de compartilhamento**~~ — retirado de fora de escopo pelo audit: o tema já
  traz `_includes/post-sharing.html` alimentado por `_data/share.yml`. Não é trabalho, é
  configuração; entra no MVP junto com o resto do `_data/`.

### BLOG-2 — Marco de saída do MVP

Executa o marco de saída registrado em Decisions do BLOG-1 e absorve o
trabalho já realizado no código sem plan/spec (`686c5c0`, `4083351`,
`6b16713`). Após o delta audit rev 2 e a decisão D-11, o BLOG-2 divide-se
em **duas fases naturais**, com pré-requisitos diferentes e cronologia
potencialmente distante entre elas. Ver D-1..D-13.

**Já feito antes desta revisão (documentar, não reimplementar):**

- Três posts fictícios de prototipagem removidos (`686c5c0`). O `_posts/`
  ficou vazio até o commit seguinte.
- Primeiro post real publicado: `_posts/2026-09-29-etl-dados-prf.md`
  (`6b16713`) — Ciência de Dados, com blocos de código Python (Rouge),
  diagrama Mermaid e imagem própria em `assets/img/posts/etl-dados-prf/`;
  sem prefixo `[RASCUNHO]`; `repo` apontando para repositório real (privado
  hoje — ver D-6). Satisfaz a Etapa A do D-1.
- Sombreamento de `_includes/js-selector.html` (`4083351`) — ver D-4. Sem
  essa correção, mermaid, dayjs, lazy-polyfill, glightbox, clipboard e
  pageviews não carregavam em `project-post`.
- `README.md` na raiz do repositório, com o fluxo do FR-6 (publicação via git push).
- `origin` configurado apontando para
  `https://github.com/ebenezer-dorneles/ebenezer-dorneles.github.io.git`.

#### Fase técnica (executável agora, com `noindex: true` ativo)

Todas as ações abaixo executam **com o `noindex: true` ainda ativo**. O site
permanece invisível a buscadores durante toda esta fase. Ordem sugerida para
o plan de BLOG-2 (a ordem exata é do ssd-plan, não da spec):

1. **Tornar `github.com/ebenezer-dorneles/etl-prf-data` público** (D-6) —
   conferência prévia de conteúdo sensível pelo autor, depois flip de
   visibilidade no GitHub. Precondição para o post ETL/PRF ser válido como
   post-de-projeto.
2. **Diagnosticar e habilitar Pages Source** (D-7) — autor confere
   `settings/pages` e `actions/` no navegador. Hipótese principal é
   `Deploy from a branch` default, que impede `actions/deploy-pages` de
   publicar. Se o diagnóstico revelar workflow quebrado (`htmlproofer`
   falhando, `configure-pages` errando), o próprio ssd-plan abre CR nova.
3. **Reescrever `test/site_test.rb` para invariantes estruturais** (D-2).
   Sem isso o gate local está vermelho (6 falhas hoje contra o estado atual
   após a remoção dos fictícios).
4. **Retirar prefixo `[RASCUNHO]` das fixtures**
   `test/fixtures/site_posts/*.md` (D-3), para o gate continuar verde
   depois do flip do `noindex` na Fase de conteúdo.
5. **Registrar Verification externa** com `noindex: true` ainda ativo (D-5)
   — comandos + resultados: `robots.txt`/`sitemap.xml` respondem 200; home
   tem `<meta name="robots" content="noindex, nofollow">`;
   `last_modified_at` aparece num post editado em segundo commit (prova do
   `fetch-depth: 0`); commit só de `README.md` **não** dispara o workflow
   (`paths-ignore`, Audit item 14 do rev 1).
6. **Marcar subitens do Step 6 (BLOG-1) como `superseded by BLOG-2`** no
   `task.md` (D-10); `## Deviations` do task.md registra o superseded
   datado.

Ao fim da Fase técnica, o site está publicado em
`https://ebenezer-dorneles.github.io/` com o post ETL/PRF, mas **invisível
a buscadores**. Gate local (`tools/check.sh`) verde. Estado de repouso
prolongado do BLOG-2.

#### Fase de conteúdo (gated no marco do D-11)

**Precondição:** `_posts/` contém ≥ 10 posts reais publicados, onde "real"
é título sem prefixo `[RASCUNHO]` **e** (se `project: true`) `repo` que
responde HTTP 200 para leitor deslogado. Contador operacional:

```bash
count=$(grep -rL '\[RASCUNHO\]' _posts/*.md | wc -l)
[ "$count" -ge 10 ] && echo "marco atingido" || echo "faltam $((10 - count))"
```

Cronologia esperada: **semanas a meses** depois do fim da Fase técnica,
conforme o autor publica o conteúdo real. O plan de BLOG-2 pode ficar
registrado como "aguardando marco" — sem trabalho ativo — durante todo esse
período. Fica em espera, não em atraso.

Quando o marco for atingido, o plan retoma:

1. **Flip do `noindex`**: `_config.yml`, `noindex: true` → `noindex: false`
   (ou remover a chave). Único commit; nenhuma outra edição na mesma leva
   (facilita o rollback do D-13-A se necessário).
2. **Verification pós-flip**: home **sem** meta robots; `sitemap.xml`
   continua servindo o mesmo conteúdo; `htmlproofer` sobre o `_site/`
   verde; `curl` no `repo` de cada post `project: true` responde 200 (o
   mesmo cheque pode virar precondição operacional antes do flip).
3. **Submissão inicial ao Google Search Console e Bing Webmaster Tools** —
   opcional, acelera a primeira indexação. Documentar em `## Feedback` se
   feito. Não é bloqueante: recrawl orgânico funciona.

**Fora do escopo do BLOG-2 (ambas as fases, registrado, não trabalhado):**

- `twitter.username` continua com placeholder do starter — Watch out do
  task.md; não afeta FR-12 (links de contato); entra em fase 2 se o autor decidir publicar
  em Twitter/X.
- Trocar os passos inline `Build site`/`Test site` do workflow por
  `bash tools/check.sh` — decisão adiada; hoje o validador só roda
  localmente. Pode virar issue própria de infra.
- Reconciliação futura do `_includes/js-selector.html` sombreado a cada
  bump do Chirpy — Watch out permanente (D-4/D-9), não trabalho ativo.
- **Modernização retroativa das regras 1–15 para UC-n/FR-n/AC-n** — vira
  **BLOG-3**, e por D-12 precede a execução do plan de BLOG-2.

### BLOG-3 — Modernização retroativa das regras 1–15

Introduzida na rev 4. Executa D-12: converter as 15 regras de negócio do
BLOG-1 em `UC-n`/`FR-n`/`AC-n` com rastreabilidade `UC → FR → AC → teste`.

**Já feito nesta revisão (spec-only, sem código):**

- `## Requirements` com 13 UCs (UC-1..UC-13), 20 FRs (FR-1..FR-20) e ACs por
  regra + itens do MVP + decisões D-1..D-13.
- `### Mapeamento das regras 1–15` na tabela final de `## Requirements`,
  documentando `regra N → FR-M(AC-M.k)` para cada uma das 15 regras.
- `## Regras de negócio` marcada como legado no seu próprio header, com
  ponteiro para `## Requirements`.
- Referências a "regra N" em D-8, D-12, D-13 e no `### BLOG-2 → Fase técnica`
  atualizadas para citar `FR-N` (D-2, D-3, D-4, D-5, D-6, D-7, D-9, D-10, D-11
  não citavam "regra N" diretamente).
- R-2 (Risks & assumptions) atualizado para citar `FR-13 (AC-13.2)`.

**Pendente no plan de BLOG-3 (código, não spec):**

- Adicionar tag `FR-n`/`AC-n.m` no nome ou docstring de cada teste em
  `test/validate_front_matter_test.rb` e `test/site_test.rb`, para que a
  matriz de Coverage do ssd-plan e o `validation.md` do ssd-verify possam
  rastrear cobertura por AC. Sem mudança de comportamento; apenas naming.
- Nova seção `## Coverage` no plan de BLOG-3 (owned pelo ssd-plan) mapeando
  cada AC → arquivo:linha de teste que a exercita.

**Fora do escopo do BLOG-3 (permanece como dívida legada aceita, AU-25):**

- `## Non-functional requirements` — não introduzido.
- `## Constraints & dependencies` — não introduzido.
- `## Interfaces / requests` — não introduzido.
- Modernização das Decisões narrativas do BLOG-1 (as ~20 decisões em
  `## Decisions` antes de `### Decisions — BLOG-2 (rev 2)`) — permanecem em
  texto narrativo original, citando "regra N" onde citam. São registro
  imutável do BLOG-1; futuras decisões usam FR-n/AC-n.

---

## Open questions

**Nenhuma aberta.** Todas foram fechadas em `## Decisions` ou pelo spike do
`## Audit — 2026-09-17`:

| Questão | Fechada em |
|---|---|
| Contrato de data sources não confirmado em código | Audit itens 2, 8, 15, 16 |
| Usuário do GitHub e nome do repositório | Decisions — `ebenezer-dorneles.github.io` |
| Idioma dos posts | Decisions — pt-BR no MVP, inglês em fase 2 |
| Quais posts reais no MVP | Decisions — conteúdo fictício de prototipagem |
| Rastreador de issues | Decisions — identificador local `BLOG-<n>` |
| Remote do GitHub | Decisions — junto do nome do repositório |
| Linguagem do validador de front matter | Decisions — Ruby, `tools/validate-front-matter.rb` |

---

## Risks & assumptions

Introduzida na revisão 3 (por AU-25 do `## Audit — rev 2 — 2026-09-29`).
Registra hipóteses e riscos que o texto das Decisions cita implicitamente e
que o correto funcionamento da spec depende. Cada item aponta a Decision que
o embute e o que acontece se a hipótese não se sustentar.

### R-1 — Cache de buscador é irreversível na prática (D-1, D-11, D-13)

**Hipótese:** uma vez que Google ou Bing indexem uma URL do site, religar
`noindex: true` depois **não** remove imediatamente a URL do índice, **não**
invalida o snippet em cache, e o buscador leva de dias a meses para recrawlar
e derrubar.

**Consequência se a hipótese falha** (buscador respeita `noindex` retroativo
rapidamente): o gate rígido do D-11 (10 posts reais antes do flip) fica
menos crítico, mas nada quebra — o desenho preserva conservadorismo.
Cenário improvável dado o comportamento documentado dos dois buscadores.

**Consequência se a hipótese vale** (comportamento esperado, majoritário):
justifica o gate do D-11, o procedimento explícito do D-13-B (Google Search
Console → Remoções + reescrita de histórico + repo privado temporário como
último recurso) e a orientação de commit único no flip para não empilhar
mudanças cujo rollback isolado ficaria difícil.

### R-2 — Autor mantém disciplina editorial ao aproximar o marco do D-11

**Hipótese:** o autor **não** vai burlar o critério de "post real" do D-11
publicando posts de corpo mínimo só para bater os 10, ou reetiquetando
rascunhos como reais para acelerar o flip do `noindex`.

**Consequência se a hipótese falha:** o site indexa com portfólio de
aparência mas sem substância. O objetivo declarado ("portfólio complementar
ao GitHub") é prejudicado exatamente no momento em que a promessa aumenta
(indexação por busca amplia o público). O contador do D-11 continua
satisfeito, mas o resultado prático é pior do que ter deferido o flip.

**Mitigador registrado (não é validação automática, é convenção editorial):**
posts de projeto seguem o template de `_drafts/template-projeto.md` (Step 4
do BLOG-1) com as cinco seções do FR-13 (AC-13.2) — contexto, stack técnica,
processo, resultado, aprendizados. O template lembra o autor da estrutura
mínima no momento de escrever. Fica a cargo da revisão humana; validador
não checa presença de headings.

### R-3 — Bump do Chirpy pode reintroduzir bug do JS-selector em silêncio

**Hipótese:** o autor **executa o diff manual documentado em D-9** antes de
commitar qualquer bump do `jekyll-theme-chirpy`:

```bash
docker compose run --rm site \
  diff -u $(bundle show jekyll-theme-chirpy)/_includes/js-selector.html \
          _includes/js-selector.html
# idem para _includes/metadata-hook.html
```

O output vai no corpo do commit message (mesmo se vazio, o que serve como
registro de que a checagem foi feita).

**Consequência se a hipótese falha** (autor esquece o diff): um bump que
altera o `_includes/js-selector.html` do gem faz o nosso sombreado (D-4)
divergir sem sinalizar. Sintoma: Mermaid, dayjs, lazy-polyfill, glightbox,
clipboard e pageviews param de funcionar em `project-post` (regressão do
`4083351`). Descoberta típica: leitor reporta o diagrama quebrado, depois
do commit já publicado.

**Sem automação em CI:** bumps são raros e manuais; o custo de um cheque
automatizado desproporcional ao benefício. Se a frequência aumentar,
reavaliar (feedback item, futura revisão).

---

## Feedback

<!--
Post-ship review feedback. Dated entries. Do NOT splice these into "Decisions" above
— that section is the original design record. Large feedback items become their own
issue and a new `## Plan — <ISSUE>` section in plan.md.
-->

**2026-09-18 — `noindex` via `_includes/metadata-hook.html` (aprovado pelo autor).** O
`noindex` global precisa de um ponto de injeção no `<head>`, e o único que o tema
oferece é `metadata-hook.html`: placeholder vazio do gem 7.6.0 (`<!-- A placeholder to
allow defining custom metadata -->`), incluído por `_includes/head.html`. Sombreá-lo
diverge da **letra** da decisão "nenhum arquivo do tema sobrescrito", mas não do
**motivo** dela: o arquivo é feito para ser sobrescrito e um bump do tema não gera
conflito. Alternativa descartada: sobrescrever `head.html`, que é exatamente a
divergência que a decisão evita. Esta é a única exceção. Ver `plan.md` → BLOG-1 →
Strategy.

---

## Audit — 2026-09-17

Spike executado contra o material real, não contra memória: gem
`jekyll-theme-chirpy` **7.6.0** desempacotado (`gem unpack`), árvore e arquivos do
`cotes2020/chirpy-starter@main`, e metadados do gem `github-pages` v232 — todos via
rede em 2026-09-17. É o que fecha a questão aberta que bloqueava este audit.

| # | Item | Type | Status | Decision |
|---|------|------|--------|----------|
| 1 | O build nativo do Pages foi descartado por causa de plugins, mas a incompatibilidade é maior: `github-pages` v232 fixa `jekyll = 3.10.0` e o Chirpy 7.6.0 exige `jekyll ~> 4.3`. Havia também `_plugins/` local no starter, que o build nativo ignora | decision | closed | Decisão reforçada com as três razões independentes; conclusão inalterada |
| 2 | O contrato de front matter omitia campos que o tema realmente lê (`media_subpath`, `toc`, `math`, `comments`, `authors`, `lang`) e descrevia `image` de forma vaga | impact | closed | Tabela de front matter reescrita a partir de `grep page\.[a-z_]+` em `_layouts/` e `_includes/` |
| 3 | Os campos nossos (`repo`, `project`) não têm onde ser renderizados: `_layouts/post.html` só inclui `datetime`, `lang`, `post-edit`, `post-sharing`, `read-time`, `toc-status`. Sobrescrever o layout inteiro reintroduz a divergência com o upstream que a escolha do gem evitava | impact | closed | Layout filho `_layouts/project-post.html` com `layout: post`; nenhum arquivo do tema sobrescrito — ver Decisions |
| 4 | `Gemfile.lock` está no `.gitignore` do starter, contra o item de MVP que pedia o lock versionado. Sem lock, `~> 7.6` resolve de novo a cada build: um 7.7.0 do upstream muda o site sem commit do autor | failure | closed | Remover `Gemfile.lock` do `.gitignore` e versionar — ver Decisions |
| 5 | O starter declara o submódulo `assets/lib` (`chirpy-static-assets`) e deixa `submodules: true` **comentado** no workflow. Self-host exige três pontos alinhados; qualquer um faltando quebra CSS/JS sem falhar o build | impact | closed | MVP fica no default `cors` (jsDelivr + Google Fonts), confirmado em `_includes/origin-type.html`; self-host vira item de fase 2 |
| 6 | O deploy usa `actions/deploy-pages`, que exige Pages → Source = "GitHub Actions" nas settings. Passo manual, fora do Git, ausente do escopo. Com a fonte em "Deploy from a branch" o workflow roda e não publica | failure | closed | Virou item explícito de MVP |
| 7 | O workflow fixa Ruby 3.4; a máquina de desenvolvimento tem 4.0.6. Jekyll 4.3 não é testado pelo upstream em Ruby 4.0 — divergência de runtime entre local e CI | failure | closed | `.ruby-version` com `3.4` — ver Decisions |
| 8 | A regra 8 estava fora de escopo por "depende do mecanismo que o Chirpy oferece". O starter traz `_plugins/posts-lastmod-hook.rb`, que preenche `last_modified_at` do `git log`, e `post.html` já renderiza o campo | impact | closed | Movida para o MVP a custo zero. Armadilha registrada: o hook depende de `fetch-depth: 0`; checkout raso a desliga silenciosamente |
| 9 | "Botões de compartilhamento" estava fora de escopo, mas o tema traz `_includes/post-sharing.html` + `_data/share.yml` | impact | closed | Retirado de fora de escopo; é configuração, entra no MVP |
| 10 | A nota de fase 2 citava Plausible, que o tema não suporta. Provedores nativos: Google, GoatCounter, Umami, Matomo, Cloudflare, Fathom | decision | closed | Texto corrigido; se entrar, GoatCounter ou Cloudflare |
| 11 | Pages gratuito exige repositório público, então os posts fictícios ficam acessíveis e — com `jekyll-sitemap` e `jekyll-seo-tag` no MVP — indexáveis. "Não divulgado" não é "não acessível", e cache de buscador sobrevive à remoção do arquivo | failure | closed | `noindex` global até os posts fictícios saírem; a remoção do `noindex` é o marco de saída do MVP — ver Decisions |
| 12 | O workflow roda `htmlproofer` como gate de build. Post fictício com imagem ou link interno inexistente **reprova o deploy**; por outro lado `--disable-external` significa que o `repo` placeholder não reprova | edge | closed | Restrição escrita no escopo dos posts de prototipagem; `bash tools/test.sh` virou item de verificação local |
| 13 | `timezone:` vem vazio no starter, e a regra 2 depende do `future: false` comparando com "agora" no fuso configurado. Vazio, local e runner discordam na virada do dia | edge | closed | `timezone: America/Sao_Paulo` explícito |
| 14 | O workflow tem `paths-ignore` com `README.md`, `.gitignore` e `LICENSE`: commit que só mexe no README não dispara deploy | edge | closed | Registrado para não virar depuração de "deploy travado"; comportamento aceito |
| 15 | A decisão de idioma assumia `lang` por post sem verificar. Confirmado: `_data/locales/pt-BR.yml` existe no 7.6.0 e `_layouts/default.html` resolve `page.lang \| site.alt_lang \| site.lang` | data | closed | Decisão de idioma implementável como escrita |
| 16 | A tabela dizia que os links do autor vinham de `_data/` genérico. O gem só traz `_data/locales/` e `_data/origin/`; `contact.yml` e `share.yml` são do starter | data | closed | Tabela corrigida com a coluna de origem (gem / starter / nosso) |
| 17 | O contrato exige `categories` com exatamente 1 item, mas o Chirpy suporta hierarquia de dois níveis e monta árvore de categorias | edge | closed | Risco baixo; virou verificação explícita no item de MVP das páginas de categoria, a conferir no primeiro build |

**Pressão sobre as decisões que sobreviveram.** O que quebra primeiro conforme o
conteúdo cresce não é o build nem a busca: é o `Gemfile.lock` envelhecendo sem bump
(um bump acumulado de várias versões do tema deixa de ser rotina e vira migração) e o
repositório engordando com imagens não redimensionadas, já que a regra 5 proíbe
hospedagem externa. Nenhum dos dois é problema no volume do MVP; ambos são baratos
agora e caros depois, então ficam registrados aqui em vez de virarem escopo.

**Não auditável nesta passada.** Tudo que depende de repositório remoto existente:
primeiro build verde no Actions, permissões de Pages, e o comportamento real do hook de
`last_modified_at` sobre o histórico do repositório. São verificações do plan, com
comando e resultado registrados no `task.md`, não itens de spec.

**Gate de saída.** Zero itens abertos: 17 achados, 17 fechados, e a última questão aberta
da spec (linguagem do validador) fechada em `## Decisions`. A spec deixa de ser rascunho.
Próximo passo do pipeline: **plan**.

---

## Audit — rev 2 — 2026-09-29

Delta audit da revisão 2. Escopo: D-1..D-5, subseção `### BLOG-2 — Marco de saída do
MVP` do Scope, e gaps herdados da spec legada (`UC-n`/`FR-n`/`AC-n` ausentes, quatro
seções condicionais faltando). Ver rev 1 acima para o audit original.

Duas checagens externas rodadas em 2026-09-29, resultado em `curl` bruto (sem folder de
evidência, resposta é o próprio código HTTP):

- `curl -o /dev/null -w '%{http_code}' https://github.com/ebenezer-dorneles/etl-prf-data` → **404**
- `curl -o /dev/null -w '%{http_code}' https://ebenezer-dorneles.github.io/` → **404**

Ambas mudam o entendimento do estado sob o qual D-1 Etapa B seria aplicada.

| ID | Item | Type | Severity | Resolution | Status | Decided by | Decision | Evidence |
|----|------|------|----------|------------|--------|------------|----------|----------|
| AU-18 | `repo:` do único post real (`_posts/2026-09-29-etl-dados-prf.md:8` → `https://github.com/ebenezer-dorneles/etl-prf-data`) responde 404 hoje. Validador não pega (spec: valida formato, não existência); `htmlproofer --disable-external` também não. Aplicar Etapa B do D-1 sob este estado publica portfólio com link quebrado para "o projeto", contradizendo a intenção da regra 3. | impact | critical | product | resolved | user (autor, 2026-09-29) | D-6 | `curl → 404` (2026-09-29); `_posts/2026-09-29-etl-dados-prf.md:8`; repo confirmado privado pelo autor em 2026-09-29 |
| AU-19 | `https://ebenezer-dorneles.github.io/` responde 404. Commit `6b16713` disparou o workflow, mas o site publicado não existe. Causas possíveis, todas a diagnosticar: (i) Pages → Source ainda "Deploy from a branch" (Watch out do Step 6, nunca confirmado); (ii) workflow falhou (htmlproofer contra o post real, ou primeiro build travado); (iii) run em execução. D-1 Etapa B em site que não publica é operação vazia. | impact | critical | product | resolved | user (autor, 2026-09-29) | D-7 | `curl https://ebenezer-dorneles.github.io/ → 404` (2026-09-29); task.md Watch out do Step 6 |
| AU-20 | D-1 diz "validar visualmente com conteúdo real (Actions verde, home mostrando o post, categorias/tags renderizando) **antes** de expor à indexação" sem definir critério verificável. Autor único revisa o próprio trabalho; sem checklist concreto, o gate entre Etapas A e B é subjetivo e perde regressão. | quality | high | product | resolved | user (autor, 2026-09-29) | D-11 — edits aplicados na rev 3 (D-1 Etapa B cita D-11 explicitamente; `### BLOG-2` do Scope contém contador operacional e prosa da precondição) | D-1 no `## Decisions`; conversa 2026-09-29; verificado na rev 3 |
| AU-21 | D-2 exige "home tem ≥ 1 post em ordem cronológica decrescente". Com 1 post real (`_posts/` hoje), a asserção de ordem é trivialmente satisfeita — regra 9 fica verificada por vacuidade. As fixtures do `check.sh` (`2026-01-01` e `2026-01-02`) são symlinks efêmeros de teste e **não** representam o site publicado. | edge | medium | technical | resolved | agent (2026-09-29) | D-8 | `ls _posts/`; `tools/check.sh:9-22` |
| AU-22 | D-4 registra Watch out permanente (reconciliar `_includes/js-selector.html` a cada bump do Chirpy) sem mecanismo de detecção. Bump do gem por `bundle update` não avisa o autor de mudanças no JS-selector — descoberta é reativa (quebra de mermaid/tocbot num post real, potencialmente depois de deploy). | impact | medium | technical | resolved | agent (2026-09-29) | D-9 | `git show 4083351`; `_includes/js-selector.html` local vs. gem 7.6.0 |
| AU-23 | D-5 diz por que a Verification do primeiro deploy vai para BLOG-2, mas não diz o que acontece com o checklist do Step 6 em `task.md` (todos os subitens desmarcados) enquanto BLOG-2 executa. Ambiguidade operacional para ssd-task/ssd-plan: marcar `superseded`, apagar, ou deixar desmarcado indefinidamente? | quality | low | technical | resolved | agent (2026-09-29) | D-10 | `task.md` — Checklist Step 6 |
| AU-24 | Gap legado citado no pedido: spec usa "Regras de negócio 1–15" em vez de `UC-n`/`FR-n`/`AC-n`. Rev 2 não aborda. Consequência: sem chain `UC→FR→AC→plan phase/test`, a rastreabilidade que downstream depende (Coverage do ssd-plan, matriz do ssd-verify) trabalha com proxy fraco ("regra 3"). BLOG-2 é planejável assim (as regras cobrem o comportamento), mas revisão futura com comportamento novo vai sofrer. | quality | high | technical | deferred | user (autor, 2026-09-29) | D-12 — modernização vira BLOG-3, precede execução do plan de BLOG-2 | spec inteira; ausência da seção `## Requirements` |
| AU-25 | Gap legado citado no pedido: seções obrigatórias por tier M ausentes — `## Non-functional requirements`, `## Constraints & dependencies`, `## Interfaces / requests`, `## Risks & assumptions`. Mais crítico para BLOG-2: **Risks & assumptions**. `noindex: false` é irreversível na prática (cache de buscador sobrevive ao rollback) mas o risco só aparece implicitamente no D-1. Sem seção dedicada, o próximo passo (audit ou verify) não tem onde ancorar. | quality | medium | technical | resolved | user (autor, 2026-09-29) | rev 3 adicionou `## Risks & assumptions` com R-1 (cache irreversível), R-2 (disciplina de 10 posts), R-3 (drift de tema). NFR/Constraints/Interfaces permanecem como dívida legada aceita. | seções ausentes; D-1; D-11; verificado na rev 3 |
| AU-26 | Edge case não coberto no BLOG-2: se a Etapa B é aplicada e depois surge necessidade de despublicar (erro grave em post, dado sensível, reputacional), o único caminho é (a) commit de rollback + esperar cache de buscador decair, ou (b) tornar o repo privado (perde Pages no gratuito). Sem procedimento definido, resposta a incidente é improvisada. | edge | medium | product | resolved | user (autor, 2026-09-29) | D-13 | Decisions do BLOG-1 (repo público exigido pelo plano Pages gratuito); D-11 |

**Pressão sobre as decisões que sobreviveram.** D-1 e D-5 se assumem sobre um "site que
já publica"; AU-19 mostra que essa premissa não vale hoje. Enquanto AU-19 estiver
`open`, tudo em BLOG-2 que depende do site (Verification, checagem do `noindex`,
`last_modified_at`, `paths-ignore`) fica em espera — não porque a spec esteja errada,
mas porque o alvo do teste ainda não existe.

**Não auditável nesta passada.** Diagnóstico da causa raiz de AU-19 exige acesso à
API do GitHub (status do último workflow run, configuração de Pages) ou ao painel do
repositório. Fora do escopo do audit (que não escreve código nem faz login em serviços);
entra como investigação inicial do BLOG-2 assim que aprovado.

**Gate de saída (após settlement em 2026-09-29).** 9 achados triados:

- **resolved (6):** AU-18 (D-6), AU-19 (D-7), AU-21 (D-8), AU-22 (D-9), AU-23 (D-10), AU-26 (D-13).
- **deferred (1):** AU-24 → D-12: modernização UC/FR/AC vira BLOG-3, precede execução do plan de BLOG-2.
- **open, awaiting spec edit (2):** AU-20 (D-11 exige edit em D-1 Etapa B e `### BLOG-2` do Scope) e AU-25 (adicionar `## Risks & assumptions` em rev 3).

Aprovação da rev 2 **não** libera aqui — dois achados abertos pendentes de edit. Próximo
passo do pipeline: **spec** → revisão 3, absorvendo os edits de AU-20 (D-11) e AU-25.
Depois: **audit** (delta rev 3) → aprovação → **BLOG-3** (spec rev 4 de modernização,
por D-12) → plan/task/verify de BLOG-3 → então plan de BLOG-2. A janela até o site
publicar com `noindex: false` é longa e reconhecida pelo autor (D-12).

---

## Audit — rev 3 — 2026-09-29

Delta audit da revisão 3. Escopo: verificar que os edits absorvem AU-20 e AU-25 do
delta audit rev 2, e re-leitura crítica das três áreas tocadas (D-1 Etapa B,
`### BLOG-2 — Marco de saída do MVP`, `## Risks & assumptions`) buscando novos
achados.

**Áreas tocadas na rev 3:**

- D-1 Etapa B — reescrita para citar D-11 explicitamente; alternativa "N ≥ 2 posts"
  agora strikethrough como superseded por D-11.
- `### BLOG-2 — Marco de saída do MVP` — rewrite estrutural em duas fases (Fase
  técnica agora, Fase de conteúdo gated no marco D-11), com contador operacional
  em shell.
- `## Risks & assumptions` — nova seção com R-1..R-3.

**Passos de verificação:** re-leitura das três áreas contra D-1..D-13 acima e
contra o texto das próprias áreas, buscando (a) inconsistências internas, (b)
promessas em uma área não realizadas em outra, (c) implícitos que a rev 3 pode
ter introduzido.

| ID | Item | Type | Severity | Resolution | Status | Decided by | Decision | Evidence |
|----|------|------|----------|------------|--------|------------|----------|----------|
| AU-27 | Divergência trivial entre o contador do D-11 (`grep -rL '\[RASCUNHO\]' _posts/`) e o do `### BLOG-2` Fase de conteúdo (`grep -rL '\[RASCUNHO\]' _posts/*.md`). Formalmente diferentes: `_posts/` faz varredura recursiva incluindo subdiretórios; `_posts/*.md` só o topo. Jekyll aceita subdiretórios em `_posts/` para hierarquia de categorias, mas o BLOG-1 não usa (categorização via front matter). Ainda assim, dois textos autorais do mesmo comando divergem. | quality | low | technical | invalid | agent (2026-09-29) | Ambas as consultas produzem resultado idêntico dado o padrão adotado no BLOG-1 (sem subdiretórios em `_posts/`, categorização por front matter — regra 11). Se essa convenção mudar, `_posts/*.md` deixa de servir, mas o contexto atual não permite divergência prática | `_posts/` no repo hoje; regra 11 |
| AU-28 | O contador do D-11 (`grep -rL '\[RASCUNHO\]' _posts/ \| wc -l`) checa **apenas** a metade "sem prefixo `[RASCUNHO]`" da definição de "post real". A outra metade — "se `project: true`, `repo` responde HTTP 200 para leitor deslogado" — não está no one-liner. Contador subestima falhas: um post com `[RASCUNHO]` removido mas `repo` ainda 404 contaria como real. | quality | medium | technical | resolved | agent (2026-09-29) | D-11 chama o script explicitamente de "contador operacional" (heurística de progresso), não gate. A prosa de D-11 define os dois critérios, e o `### BLOG-2` → Fase de conteúdo → passo 2 exige `curl` no `repo` de cada post `project: true` como precondição do flip. A cobertura completa está na spec, apenas distribuída — o script é indicador; o gate real é operacional | D-11 prosa; `### BLOG-2` Fase de conteúdo passo 2 |
| AU-29 | D-5 (rev 2) diz que Verification do primeiro deploy é feita "num único bloco coerente que também cobre a troca do `noindex`". Após o split da rev 3, o BLOG-2 naturalmente produz **duas** Verifications distintas: uma pré-flip (Fase técnica passo 5) e outra pós-flip (Fase de conteúdo passo 2), potencialmente com meses de distância. Wording de D-5 fica desatualizado. | quality | low | technical | invalid | agent (2026-09-29) | Reler D-5: "num único bloco coerente" no contexto se refere à disciplina de gravar comando + resultado num único registro por fase, **não** a bloco único no tempo. Duas Verifications separadas (pré e pós) preservam essa coerência dentro de cada uma. Wording de D-5 continua consistente com o desenho da rev 3 — não há gap funcional | D-5 no `## Decisions`; `### BLOG-2` rev 3 |
| AU-20 | *ver rev 2 acima* | — | — | — | resolved | user (autor, 2026-09-29) | D-11 — edits aplicados na rev 3 (verificado) | verificado na rev 3 |
| AU-25 | *ver rev 2 acima* | — | — | — | resolved | user (autor, 2026-09-29) | rev 3 adicionou `## Risks & assumptions` com R-1..R-3 (verificado) | verificado na rev 3 |

**Observações da re-leitura que não viraram findings.** (i) `### BLOG-2` Fase
técnica passo 5 substitui o item antigo "Confirmar que o workflow do Actions
publica o novo estado sem regressão do htmlproofer" — a confirmação segue implícita
em "Verification externa" (site respondendo 200 depende do deploy real ter ocorrido).
Não é omissão, é reescrita mais compacta. (ii) R-1 discute cache de buscador citando
"D-13-A" e "D-13-B" — verificado, D-13 usa rótulos (A), (B), (C); casamento correto.
(iii) A alternativa strikethrough em D-1 ("~~esperar N ≥ 2 posts~~") preserva
convenção do contrato de ids (removidos ficam struck, apontando para o que os
supersedeu). (iv) A cronologia "semanas a meses" da Fase de conteúdo não é
pressuposto do plan — é reconhecimento explícito do gap entre fases, o que
melhora rastreabilidade em ssd-status.

**Pressão adversarial.** Tentei achar promessa em uma área que outra não cumpre.
O único candidato: D-9 (diff manual de bumps) só é acionado se o autor lembrar
de rodar, e R-3 depende disso. R-3 registra explicitamente essa hipótese, e o
mitigador ("output no corpo do commit message, mesmo se vazio") é uma disciplina
processual clara. Aceito como registrado.

**Gate de saída.** 12 achados triados desde rev 2 (AU-18..AU-29): 9 resolved
(AU-18, AU-19, AU-20, AU-21, AU-22, AU-23, AU-25, AU-26, AU-28) + 1 deferred
(AU-24 → BLOG-3) + 2 invalid (AU-27, AU-29 — low tech, agente decide). **Zero
itens open** em qualquer seção de audit. Exit gate da rev 3: **aberto**.

Próximo passo do pipeline: **aprovação do usuário** para a revisão 3. Após
aprovação, `phase: approved` e o pipeline pode continuar com **BLOG-3** (spec
rev 4 de modernização retroativa por D-12).

---

## Audit — rev 4 — 2026-09-29

Delta audit da revisão 4. Escopo: verificar cobertura das regras 1–15 pelos
FR-1..FR-20, checagem de que cada AC-n.m é verificável com valor concreto,
consistência dos edits de "regra N" → "FR-N" em D-8/D-12/D-13/BLOG-2/R-2, e
integridade da tabela de mapeamento.

**Método:** re-leitura do `## Requirements` inteiro; tracing regra→FR e
UC→FR→AC nos dois sentidos; `grep -n "regra [0-9]"` para confirmar que
"regra N" só resta em conteúdo legado explicitamente marcado; teste manual
de cada AC contra "poderia ser transformado em teste com valor concreto".

**Coverage regras 1–15 → FR (confirmado):** cada uma das 15 regras aparece
na tabela `### Mapeamento das regras 1–15` apontando para ≥ 1 FR. Regras 1,
5 e 11 mapeiam para múltiplos FRs (intencional — semântica composta).
Bijeção estrita **não** é requisito: regras têm semântica composta, FRs
16–20 são acréscimos sem regra correspondente (documentado no texto).
Cobertura completa: ✓.

**Coverage UC → FR (confirmado):** todos os 13 UCs mapeiam para ≥ 1 FR na
`### Use case coverage`. UC-12 (later) e UC-13 (split MVP + Fase de conteúdo)
tratados explicitamente. Cobertura completa: ✓.

**Coverage FR → AC (confirmado):** cada um dos 20 FRs tem ≥ 1 AC. Total ≈ 41
ACs, com Given/When/Then legível em cada. Cobertura completa: ✓.

**Edits regra→FR (confirmado):** grep sobre a spec confirma que "regra [0-9]"
só resta em: (i) `## Regras de negócio` (marcada como legado); (ii) tabela
`### Mapeamento das regras 1–15` (função da própria tabela); (iii) `## Data
sources` e `## Decisions` narrativas do BLOG-1 (registro imutável, fora do
escopo do BLOG-3 por decisão explícita); (iv) `### MVP` de `## Scope`
(BLOG-1 escopo original, fora do escopo do BLOG-3); (v) D-12 (citação
histórica com alias "agora `FR-3`, `FR-9`"). Nenhum leak em D-1..D-13
modernos, BLOG-2 subsection ou Risks & assumptions. ✓.

| ID | Item | Type | Severity | Resolution | Status | Decided by | Decision | Evidence |
|----|------|------|----------|------------|--------|------------|----------|----------|
| AU-30 | FR-6 AC-6.1 testa apenas que o workflow **dispara** ("`o workflow ... dispara`"), não que ele **conclui com sucesso**. Um workflow que falha (htmlproofer error, configure-pages error, deploy-pages error) ainda satisfaz "disparou". Sem asserção adicional, um build reprovado passaria AC-6.1. Semantica de "publicação via git push" (regra 6 / FR-6) exige sucesso, não trigger. | quality | medium | technical | resolved | agent (2026-09-29) | Composição com AC-17.1 (`sitemap.xml` responde 200 no site publicado) e AC-18.1 (`meta robots noindex` presente após deploy) cobre indiretamente a garantia de sucesso — se o build/deploy falha, essas duas asserções falham na Verification externa do BLOG-2 Fase técnica passo 5. FR-6 AC-6.1 permanece focado no gatilho como sua responsabilidade única | FR-6 no Requirements; FR-17 AC-17.1; FR-18 AC-18.1; BLOG-2 → Fase técnica → passo 5 |
| AU-31 | Contract da skill ssd-spec lista `### Use case coverage` como conteúdo obrigatório de `## Scope`. A rev 4 coloca `### Use case coverage` sob `## Requirements`, junto de FR/AC. `## Scope` do spec não recebeu subseção equivalente. Discrepância formal de placement contra o contract. | quality | low | technical | invalid | agent (2026-09-29) | A rubrica do contract ("Scope (MVP, non-goals, use case coverage)") lista **conteúdo obrigatório**, não localização física. `### Use case coverage` existe e é canônica; sua colocação sob `## Requirements` é semanticamente coerente com o fluxo UC → FR → AC. Reader localiza via TOC sem custo. Não bloqueia downstream (Coverage do plan cita UC-n/FR-n/AC-n.m diretamente) | contract da skill; `## Requirements → ### Use case coverage` |
| AU-32 | Vários ACs dependem de verificação runtime/manual/humana, não automatizada no CI atual: AC-13.2 (revisão editorial das 5 seções), AC-16.2 (UI de busca digitada), AC-19.2/19.3 (Mermaid renderiza no browser), AC-20.1 (preview local igual ao CI, comparação visual). Coverage do plan e matriz do verify precisarão de checklist manual. | quality | low | technical | resolved | agent (2026-09-29) | Característica aceita do MVP portfolio blog (autor único, sem infra de teste de UI). Cada AC afetado é explícito sobre o mecanismo ("manual/scriptado", "verificado visualmente", "não automatizado"). ssd-verify vai formalizar checklist manual em `validation.md` para esses ACs; automação não é requisito da spec. Registrado como característica, não defeito | AC-13.2, AC-16.2, AC-19.2, AC-19.3, AC-20.1 no `## Requirements` |

**Observações da re-leitura que não viraram findings.** (i) FR-1 tem 8 ACs;
carga alta mas cada AC é um caminho de reprovação distinto do validador —
cobertura granular útil, não fragmentação. (ii) FR-11 tem AC-11.1 sobre uma
constante Ruby (`CATEGORIES` no validador); tecnicamente é assertion sobre
código-fonte, não behavior externo — aceito porque o comportamento externo
depende dessa constante, e sua unicidade previne divergência em duas listas.
(iii) AC-3.2 checa regex do `repo` mas não sua existência online (Decisions
do BLOG-1 já justificam: `htmlproofer --disable-external`); complementado
por D-6 no BLOG-2 (repo público como precondição operacional). (iv) FR-15
AC-15.1 marcado como "Fase 2" sem AC verificável agora — apropriado, UC-12
está como *later*. (v) FR-18 AC-18.3 mistura verificação por script
(contador de `[RASCUNHO]`) e por curl (repo HTTP 200) — refletindo o D-11
real, não é "hedge".

**Pressão adversarial.** Tentei achar uma regra 1–15 sem cobertura de FR,
um FR sem AC, um UC MVP sem FR mapeado, ou "regra N" leak em D-1..D-13
pós-edit — **nada encontrado**. Tentei achar AC com wording vago tipo
"adequado" ou "razoável" — nada encontrado; os pontos "manual/visual" são
explícitos sobre o mecanismo, não vagos sobre o critério.

**Gate de saída (rev 4).** 3 achados novos triados: 2 resolved (AU-30
composição com FR-17/FR-18; AU-32 característica aceita do MVP) + 1 invalid
(AU-31 placement defensível). Cumulativo desde rev 2 (AU-18..AU-32): 11
resolved + 1 deferred (AU-24 → BLOG-3) + 3 invalid. **Zero itens open** em
qualquer seção de audit. Exit gate da rev 4: **aberto**.

Próximo passo do pipeline: **aprovação do usuário** para a revisão 4. Após
aprovação, `phase: approved` libera `ssd-plan` para BLOG-3 (adicionar tags
FR-n/AC-n.m em nomes de teste + `## Coverage` matrix no plan), depois plan
de BLOG-2 Fase técnica.

---

## Revisions

| Rev | Data | Issue | Gatilho | Mudanças |
|---|---|---|---|---|
| 1 | 2026-09-17 | BLOG-1 | Marco zero (spec legada) | Corpo original + `## Audit — 2026-09-17` (17/17 fechados). |
| 2 | 2026-09-29 | BLOG-2 | Pedido do usuário (autor, 2026-09-29) — marco de saída do MVP | Frontmatter moderno (`phase: specifying`, `spec-revision: 2`, `tier: M`, `issues: [BLOG-1, BLOG-2]`). Nova subseção `### Decisions — BLOG-2 (rev 2)` com D-1..D-5. Nova subseção `### BLOG-2 — Marco de saída do MVP` em `## Scope`. Nova `## Approvals`. Reconhece commits `686c5c0`, `4083351` e `6b16713` como execução parcial do marco de saída. |
| 3 | 2026-09-29 | BLOG-2 | Absorve AU-20 (D-11) e AU-25 do delta audit rev 2 | Edit em D-1 Etapa B (agora cita D-11 como precondição de ≥ 10 posts reais; alternativa de N ≥ 2 supersedida). Rewrite de `### BLOG-2 — Marco de saída do MVP` em `## Scope` (dividida em **Fase técnica** executável agora e **Fase de conteúdo** gated no marco). Nova seção `## Risks & assumptions` com R-1 (cache irreversível), R-2 (disciplina editorial dos 10 posts), R-3 (drift do tema em bumps do Chirpy). |
| 4 | 2026-09-29 | BLOG-3 | Nova issue — modernização retroativa (D-12) | Frontmatter `phase: specifying`, `spec-revision: 4`. Nova seção `## Requirements` com Actors (Autor/Leitor/Buscador), Use case coverage (UC-1..UC-13, 12 MVP + 1 later), FR-1..FR-20 com AC-n.m verificáveis, e `### Mapeamento das regras 1–15`. `## Regras de negócio` marcada como legado (referência histórica). Referências a "regra N" em D-8, D-12, D-13, BLOG-2 Fase técnica, BLOG-2 Fora do escopo e R-2 atualizadas para `FR-N` (ou `FR-N (AC-N.M)`). Nova subseção `### BLOG-3 — Modernização retroativa das regras 1–15` em `## Scope`. NFR/Constraints/Interfaces seguem dívida aceita (AU-25). |

---

## Approvals

| Rev | Data | Aprovador | Observação |
|---|---|---|---|
| 1 | 2026-09-17 | — | Aprovação implícita — spec legada, não passou por `ssd-audit` formal. A auditoria de conteúdo em `## Audit — 2026-09-17` fechou 17/17 achados, e as etapas 0–5 do plan foram executadas sob essa base. |
| 2 | — | — | Não aprovada isoladamente. Delta audit rev 2 encontrou 2 open items awaiting spec edit (AU-20/D-11 e AU-25); ambos absorvidos na rev 3, que subsume rev 2 para efeito de aprovação. |
| 3 | 2026-09-29 | autor (Ebenézer Dorneles) | Aprovada explicitamente após `## Audit — rev 3 — 2026-09-29` fechar com zero open items. Habilita `BLOG-3` (modernização retroativa UC/FR/AC por D-12) como próximo passo do pipeline, seguido de `plan` de BLOG-2. |
| 4 | 2026-09-29 | autor (Ebenézer Dorneles) | Aprovada explicitamente após `## Audit — rev 4 — 2026-09-29` fechar com zero open items (11 resolved + 1 deferred + 3 invalid cumulativos desde rev 2). Habilita `ssd-plan` para BLOG-3 (tags FR-n/AC-n.m em nomes de teste + matriz `## Coverage` no plan), depois plan de BLOG-2 Fase técnica. |
