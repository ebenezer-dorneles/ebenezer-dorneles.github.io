---
issues: [BLOG-1]
status: in-progress
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
  decai. Um script checa: campos obrigatórios presentes; `categories` contém exatamente
  uma das duas categorias fixas; ao menos uma tag; e, quando o post declara `repo`, que
  o valor é uma URL de repositório GitHub. Descartado: pre-commit hook (não roda no
  Actions, e é local por máquina); revisão manual (é justamente o que decai).
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
- Contrato de front matter documentado + script de validação rodando no CI e
  bloqueando o merge/deploy em caso de violação (regras 1, 3, 11).
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

---

## Open questions

<!-- Move each to "Decisions" (with the answer) once closed during review. -->

1. **Em que linguagem escrever o script de validação de front matter?** Recomendação:
   Ruby — já está no ambiente de build (`ruby/setup-ruby` + `bundler-cache` no workflow),
   não adiciona passo ao CI e lê YAML com a stdlib. Python é mais familiar num contexto de
   Ciência de Dados, ao custo de um `setup-python` a mais no workflow. É o único item que
   bloqueia o plan.

<!--
Fechadas:
- "Contrato de data sources não confirmado em código" → fechada pelo spike do
  `## Audit — 2026-09-17` (itens 2, 8, 15, 16).
- "Usuário do GitHub e nome do repositório" → Decisions.
- "Idioma dos posts" → Decisions.
- "Posts reais do MVP" → Decisions (conteúdo fictício).
- "Rastreador de issues" → Decisions (`BLOG-<n>`).
- "Remote do GitHub" → Decisions (`ebenezer-dorneles.github.io`).
-->

---

## Feedback

<!--
Post-ship review feedback. Dated entries. Do NOT splice these into "Decisions" above
— that section is the original design record. Large feedback items become their own
issue and a new `## Plan — <ISSUE>` section in plan.md.
-->

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
