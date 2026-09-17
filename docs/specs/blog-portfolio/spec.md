---
issues: [#1]
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

> **Aviso de contrato:** o repositório está vazio — não existe código para confirmar
> nada ainda. A tabela abaixo é o contrato **pretendido**, não verificado. Nenhum
> item aqui pode ser tratado como confirmado até o scaffold do Jekyll existir e um
> build local rodar. Fechar isto é item obrigatório do audit (ver Open questions #1).

| Data source | Where it's defined | Relevant fields | Notes |
|---|---|---|---|
| Posts publicados | `_posts/AAAA-MM-DD-slug.md` | `title`, `date`, `categories`, `tags`, `description`, `image`, `repo`, `last_modified_at`, `mermaid` | Jekyll exige o prefixo de data **no nome do arquivo**; `date` no front matter sobrescreve a hora. `categories`/`tags` são listas YAML — uma string solta funciona mas quebra a consistência das páginas de arquivo. |
| Rascunhos | `_drafts/slug.md` (sem prefixo de data) | idem, sem `date` | Não entram no build sem `--drafts`. É o mecanismo nativo para a regra 1 (`status: draft`) — ver Decisions. |
| Configuração do site | `_config.yml` | `title`, `tagline`, `url`, `baseurl`, `lang`, `timezone`, `social`, `github.username`, `theme`/`remote_theme`, `plugins` | Alterações em `_config.yml` **não** são recarregadas por `jekyll serve` — exige restart. `url`/`baseurl` errados quebram todos os links em produção e não em local. |
| Metadados do autor / links | `_data/` + `_config.yml` (`social`) | `name`, `email`, `links[]` | Layout exato depende da versão do Chirpy — a confirmar no scaffold. |
| Imagens de post | `assets/img/posts/<slug>/` | — | Versionadas no repositório (regra 5). Sem CDN externa. |
| Comentários (fase 2) | `_config.yml` (`comments.provider`, `comments.giscus.*`) | `repo`, `repo_id`, `category_id` | giscus só funciona com repositório **público** e Discussions habilitado; `repo_id`/`category_id` são gerados pelo giscus.app, não inventáveis. |
| Build/deploy | `.github/workflows/pages-deploy.yml` | — | Existe porque o build é via Actions, não nativo — ver Decisions. |

---

## Decisions

- **Build via GitHub Actions, não pelo build nativo do GitHub Pages** — a
  especificação inicial assumiu "Jekyll + Chirpy com build automático do Pages, sem CI
  próprio". Isso é contraditório: o build nativo do Pages só aceita plugins de uma
  allowlist, e o Chirpy depende de plugins fora dela (notadamente `jekyll-archives`,
  que gera as páginas de categoria e tag exigidas pela regra 10). A resolução é o
  workflow de Actions que o próprio starter do Chirpy já entrega. Custo: um arquivo de
  workflow. Preservado: publicação por `git push` para `main`, gratuita, sem servidor.
  Descartado: trocar o Chirpy por tema whitelist-compatível (perderia busca, tempo de
  leitura e arquivos prontos) e escrever à mão as páginas de cada tag (inviável, regra
  11 diz que tags são livres).
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
- **A regra 3 (link para o repositório) é um campo `repo` no front matter, não um link
  solto no corpo do texto** — campo é verificável pelo script e renderizável em posição
  fixa pelo layout; link no meio do texto não é nem um nem outro. Posts que não
  documentam um projeto simplesmente omitem o campo.
- **A regra 13 (estrutura mínima: contexto, stack, processo, resultado, aprendizados) é
  um template em `_drafts/`, não uma validação** — é diretriz editorial, e validar
  presença de headings engessaria posts que legitimamente fogem do formato.
- **Categorias fixas em duas, tags livres** — como na regra 11. As duas categorias vivem
  como constante única no script de validação, para não haver duas listas divergindo.
- **Imagens em `assets/img/posts/<slug>/`, versionadas** — regra 5, sem hospedagem
  externa. Consequência aceita: o repositório cresce com binários; a mitigação é
  redimensionar antes de commitar, não Git LFS (LFS tem cota própria e complica o
  checkout do Actions).
- **Repositório `<usuario>.github.io`, servido na raiz** — evita `baseurl`, a fonte
  clássica de links quebrados que só aparecem em produção. Descartado: repositório de
  projeto com `baseurl: /blog`.
- **Idioma, analytics, comentários e domínio próprio ficam fora do MVP** — nenhum deles
  é pré-requisito para o objetivo declarado (publicar e ser encontrado), e cada um
  adiciona configuração que precisa ser mantida. Analytics em particular: métrica sem
  tráfego não informa nada, e adiciona um terceiro à página. Ver Scope.

---

## Scope

### MVP

- Scaffold do Chirpy Starter no repositório, com `Gemfile`/`Gemfile.lock` commitados e
  versão de Ruby fixada, mais `_config.yml` preenchido (`title`, `tagline`, `url`,
  `timezone`, `social`, `github.username`).
- Workflow `.github/workflows/pages-deploy.yml` publicando de `main` para o GitHub
  Pages, com build verde.
- `README.md` do repositório com o fluxo de publicação: escrever → `bundle exec jekyll
  serve` → commit → push → build do Actions → publicado (regra 6, caso de uso
  "visualizar localmente").
- Contrato de front matter documentado + script de validação rodando no CI e
  bloqueando o merge/deploy em caso de violação (regras 1, 3, 11).
- Template de post de projeto em `_drafts/` com as cinco seções da regra 13.
- Home em ordem cronológica decrescente (regra 9) e páginas de categoria e de tag
  (regra 10) funcionando — verificadas com posts reais, não com o post de exemplo do
  tema.
- Página "sobre" e links de GitHub / LinkedIn / e-mail visíveis em todas as páginas
  (regra 12).
- Busca client-side embutida do tema, verificada com ao menos dois posts.
- Tempo estimado de leitura visível no post (regra 4).
- `jekyll-seo-tag` + `jekyll-sitemap` ativos; `sitemap.xml` e `robots.txt` acessíveis
  no site publicado (ator Buscador).
- Realce de sintaxe (Rouge) e Mermaid verificados em um post que use ambos.
- Dois a três posts reais publicados — o MVP não está entregue com o blog vazio, porque
  nenhuma das regras de navegação, busca e SEO é verificável sem conteúdo.

### Out of scope / future phases

- **Comentários via giscus** — depende de repositório público e de GitHub Discussions
  habilitado, e os IDs vêm de um passo manual no giscus.app. Fase 2, quando houver
  leitores para comentar (regra 15 já define o provedor).
- **Analytics (Plausible / GA4)** — fase 2. Plausible é pago; GA4 é gratuito mas adiciona
  rastreamento de terceiros. Decisão adiada até existir tráfego para medir.
- **Domínio próprio + `CNAME`** — fase 2. Reforça identidade, mas troca a URL do site e
  exige DNS; fazer depois que o conteúdo estiver estável evita links mortos.
- **Suporte a mais de um idioma / versões em inglês** — impacta `lang`, `hreflang` e a
  estrutura de URLs; grande o suficiente para ser sua própria issue.
- **`last_modified_at` / data de "última atualização"** (regra 8, segunda metade) — a
  primeira metade (preservar a data original) é garantida pelo nome do arquivo e já vale
  no MVP. Exibir a data de revisão depende de qual mecanismo o Chirpy instalado oferece;
  entra quando houver o primeiro post de fato revisado.
- **Migração para Hugo/Quarto** — registrada como caminho natural caso apareça a
  necessidade de notebooks executados ou gráficos gerados no build. Sem gatilho hoje.
- **Botões de compartilhamento** — o caso de uso "compartilhar post" é atendido pela URL
  canônica do post mais os metadados do `jekyll-seo-tag` (preview em redes sociais).
  Botões dedicados só se pedidos.

---

## Open questions

1. **O contrato de data sources acima não foi confirmado em código** (o repositório está
   vazio). Caminhos, nomes de campos do Chirpy e formato de `_data/` precisam ser
   verificados contra o scaffold real antes do plan. Bloqueia o fechamento do audit.
2. **Usuário do GitHub e nome do repositório** — a decisão de servir na raiz assume
   `<usuario>.github.io`. Confirmar o handle e se esse repositório já existe/está livre.
3. **Idioma dos posts na v1** — pt-BR, inglês ou ambos? Afeta `lang` no `_config.yml`,
   os metadados de SEO e o público-alvo declarado (recrutadores). Escolher um agora é
   barato; mudar depois, não.
4. **Quais são os dois a três posts reais do MVP?** O MVP depende deles, então precisam
   ser nomeados antes do plan — quais projetos, e qual o repositório GitHub de cada.
5. **Em que linguagem escrever o script de validação de front matter?** Ruby já está no
   ambiente de build (nenhuma dependência nova); Python é mais familiar num contexto de
   Ciência de Dados, ao custo de um setup extra no workflow.
6. **Rastreador de issues e identificador real** — o frontmatter usa `#1` como
   provisório. Se o rastreamento não for por issues do GitHub, ajustar.
7. **Remote do GitHub** — o repositório local foi inicializado, mas ainda não tem
   remote configurado. Depende da questão 2.

---

## Feedback

<!--
Post-ship review feedback. Dated entries. Do NOT splice these into "Decisions" above
— that section is the original design record. Large feedback items become their own
issue and a new `## Plan — <ISSUE>` section in plan.md.
-->
