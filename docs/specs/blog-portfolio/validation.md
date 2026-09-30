# Validation — Blog de portfólio (Ciência de Dados & Dev)

<!--
No frontmatter — spec.md is the source of truth.
Owned by the verify skill. One section per validation run, append-only.
Commands are re-run by verify, never copied from task.md.
-->

## Validation — BLOG-3 — rev 4 — 2026-09-29

**Escopo do pass:** BLOG-3 é `naming e rastreabilidade` (D-12 / rev 4).
Adiciona 48 comentários `# @spec FR-N AC-N.M` nos dois arquivos de teste,
sem mudança de comportamento. **Não valida BLOG-2** (Fase técnica e Fase
de conteúdo continuam em `### Deferred` do plan). O feature-level status
só fecha depois de BLOG-2.

**Commit revisado:** `76cb996`
(`test(blog-portfolio): tag 48 testes com # @spec para rastreabilidade (BLOG-3)`).
Diff independente conferido: `git diff b8d3e77..76cb996 -- test/ | grep -E "^[+-]" | grep -vE "^[+-]{3} |^[+-]\s*$|^[+-]\s*#"` → saída vazia (0 linhas não-comentário alteradas).

**Gate re-executado independentemente pela verify:**
`docker compose run --rm site bash tools/check.sh`
- validador: **26 runs / 29 assertions / 0 failures / 0 errors / 0 skips**
- htmlproofer: **16 arquivos / 0 falhas** (`Ran on 16 files!` + `HTML-Proofer finished successfully.`)
- site_test.rb: **22 runs / 37 assertions / 6 failures / 0 errors / 0 skips**

Igualdade estrita com o baseline `e1cb549` satisfeita (invariante do Amendment 2026-09-29). As 6 falhas são as mesmas do baseline em nome e mensagem; pertencem a BLOG-2 D-2 (reescrita de `site_test.rb` para invariantes estruturais que não dependam de posts fictícios removidos em `686c5c0`).

**Cross-check independente:**
- `grep -c "# @spec" test/site_test.rb` → 22
- `grep -c "# @spec" test/validate_front_matter_test.rb` → 26
- `grep -c "def test_" test/site_test.rb` → 22
- `grep -c "def test_" test/validate_front_matter_test.rb` → 26
- 48 tags = 48 defs (invariante "1 tag por método" preservada)

### Acceptance criteria

Convenção: **testado (green)** = teste passou no gate acima; **testado (red pré-existente)** = falha herdada, coberta por BLOG-2 D-2; **diferido** = destino registrado em Coverage como não-testado automatizado com motivo aceito pelo spec. `vfm` = `test/validate_front_matter_test.rb`; `site` = `test/site_test.rb`.

| AC | Test / check | Command | Result | Asserts the "Then"? |
|---|---|---|---|---|
| AC-1.1 (title ausente/vazio) | vfm `test_title_ausente`, `test_title_vazio` (tag `FR-1 AC-1.1`) | `bundle exec ruby -Itest test/validate_front_matter_test.rb` | 26/29/0/0 | yes — asserta `errors.any? include?("title")` em ambas as omissões |
| AC-1.2 (date ausente em `_posts/`) | vfm `test_date_ausente_em_posts` (tag `FR-1 AC-1.2`) | idem | 0 failures | yes — asserta erro de `date` em `_posts/…md` |
| AC-1.3 (filename sem prefixo AAAA-MM-DD-) | vfm `test_arquivo_em_posts_sem_prefixo_de_data` (tag `FR-1 AC-1.3`) | idem | 0 failures | yes — asserta mensagem `nome do arquivo`/`prefixo` |
| AC-1.4 (categories ausente/vazio/≥2 itens) | vfm `test_categories_ausente`, `test_categories_com_zero_itens`, `test_categories_com_dois_itens` (tag `FR-1 AC-1.4`) | idem | 0 failures | yes — três casos cobrem os três estados |
| AC-1.5 (categoria fora da lista fixa) | vfm `test_categories_fora_da_lista_fixa` (tag `FR-1 AC-1.5 AC-11.1`) | idem | 0 failures | yes — encena `Culinária` e asserta erro |
| AC-1.6 (tags ausente/vazia) | vfm `test_tags_ausente`, `test_tags_vazia`, `test_tag_nao_string_…` (tags `FR-1 AC-1.6` + `AC-1.6 (auditoria-de-impacto)`) | idem | 0 failures | yes — três estados cobertos, incluindo tipo não-string |
| AC-1.7 (tag maiúscula/acento) | vfm `test_tag_com_maiuscula`, `test_tag_com_acento` (tag `FR-1 AC-1.7`) | idem | 0 failures | yes |
| AC-1.8 (draft sem date aceito) | vfm `test_date_ausente_em_drafts_eh_aceito` (tag `FR-1 AC-1.8`) | idem | 0 failures | yes — asserta ausência de erro `date` em `_drafts/` |
| AC-2.1 (drafts fora de `_site/`) | site `test_diretorio_draft_nao_publicado` (tag `AC-2.1 (exclude _config.yml)`) — cobertura indireta; propriedade nativa de Jekyll | `bash tools/check.sh` (via `tools/test.sh`) | ok (`_site/draft` ausente) | partial — asserta ausência do diretório `_site/draft`, o que só ocorre se a propriedade Jekyll `--drafts off` (default) valer. Aceito pelo spec (Coverage nota "propriedade nativa"). |
| AC-2.2 (`published: false`) | — | — | deferred | Propriedade nativa Jekyll; sem teste (aceito pelo spec) |
| AC-2.3 (date futuro / `future: false`) | — | — | deferred | Propriedade nativa Jekyll com `timezone: America/Sao_Paulo`; sem teste (aceito) |
| AC-3.1 (`project: true` sem `repo`) | vfm `test_project_true_sem_repo` (tag `FR-3 AC-3.1`) | validador | 0 failures | yes |
| AC-3.2 (`repo` fora do formato github) | vfm `test_repo_fora_do_formato_github`, `test_repo_nao_string_…` (tags `FR-3 AC-3.2` + `AC-3.2 (auditoria-de-impacto)`) | validador | 0 failures | yes — inclui não-string |
| AC-3.3 (layout ≠ `project-post`) | vfm `test_project_true_sem_layout_project_post` (tag `FR-3 AC-3.3`) | validador | 0 failures | yes |
| AC-3.4 (HTML tem link do repo em `project-post`) | site `test_post_de_projeto_tem_link_do_repositorio` (+ negativo `test_post_comum_nao_tem_bloco_de_repositorio`) (tag `FR-3 AC-3.4`) | check.sh | ok (verde no baseline e no re-run; não estão entre as 6 falhas) | yes — asserta `href="…/fixture-exemplo"` no HTML gerado do `_layouts/project-post.html` |
| AC-4.1 (tempo de leitura visível) | site `test_tempo_de_leitura_visivel_no_post` (tag `FR-4 AC-4.1`) | check.sh | **red pré-existente** — post `api-tarefas-ruby` foi removido em `686c5c0` | yes (o teste cobre o AC), mas o AC está atualmente inobservável até BLOG-2 D-2 |
| AC-5.1 (asset local existe) | site `test_imagem_do_post_e_servida_e_referenciada` (tag `FR-5 AC-5.1`) | check.sh | **red pré-existente** — mesmo motivo | yes; deferred a BLOG-2 D-2 |
| AC-5.2 (htmlproofer reprova ref quebrada) | gate `tools/test.sh` (parte do check.sh) | check.sh | ok — 0 falhas de htmlproofer no gate; invariante do htmlproofer garantida pelo próprio gate falhando quando ref quebra | partial — não há teste minitest dedicado; a asserção é a saída do htmlproofer no build real (aceito) |
| AC-6.1 (workflow dispara) | BLOG-2 Fase técnica passo 5 | — | deferred | Verification externa em BLOG-2 |
| AC-6.2 (`paths-ignore` não dispara) | BLOG-2 Fase técnica passo 5 | — | deferred | idem |
| AC-7.1 (histórico via git) | Propriedade do modelo; verify por inspeção `git log` durante BLOG-2 Verification externa | — | deferred | Aceito pelo spec |
| AC-8.1 (`last_modified_at` em ≥ 2 commits) | BLOG-2 Fase técnica passo 5 (requer `fetch-depth: 0` + 2 commits reais) | — | deferred | Cobertura invariante em vfm `test_last_modified_at_escrito_a_mao` (tag `FR-8`) — rejeita valor escrito à mão, complementar aos AC-8.x |
| AC-8.2 (`last_modified_at` em 1 commit) | BLOG-2 Fase técnica passo 5 | — | deferred | idem |
| AC-8.3 (checkout raso quebra) | Armadilha documentada no spec | — | deferred | Sem teste automatizado (explícito) |
| AC-9.1 (home ordem cronológica) | site `test_home_lista_posts_em_ordem_cronologica_decrescente` (tag `FR-9 AC-9.1`) | check.sh | **red pré-existente** — mesmo motivo dos posts removidos | yes; deferred a BLOG-2 D-2 (D-8 nota: verificação por vacuidade / fixtures) |
| AC-10.1 (categorias) | site `test_categorias_tem_pagina_por_categoria` (tag `FR-10 AC-10.1`) | check.sh | ok (verde no baseline e no re-run) | yes — asserta existência de `_site/categories/{desenvolvimento,ciência-de-dados}/index.html` |
| AC-10.2 (tags) | site `test_tags_tem_pagina_por_tag_usada` (tag `FR-10 AC-10.2`) | check.sh | **red pré-existente** — checa slug `ruby` que veio dos posts removidos | yes; deferred a BLOG-2 D-2 |
| AC-11.1 (CATEGORIES constante única) | vfm `test_categories_fora_da_lista_fixa` + `test_valid_post_has_no_errors` (tags `FR-1 AC-1.5 AC-11.1` e `FR-1 AC-11.1`); constante em `tools/validate-front-matter.rb:8` | validador | 0 failures + inspeção estática | partial — assertion direta sobre a constante seria tautológica (registrado em Coverage); a evidência é a rejeição de `Culinária` + aceitação de `Desenvolvimento` no positivo |
| AC-12.1 (a) GitHub | site `test_home_tem_link_github` (tag `FR-12 AC-12.1`) | check.sh | ok | yes |
| AC-12.1 (b) LinkedIn | site `test_home_tem_link_linkedin` (tag `FR-12 AC-12.1`) | check.sh | ok | yes |
| AC-12.1 (c) e-mail | site `test_home_tem_link_email` (tag `FR-12 AC-12.1`) | check.sh | ok | yes |
| AC-13.1 (template `_drafts/`) | validador varre `_drafts/template-projeto.md` no check.sh | check.sh | ok (validador 0/0/0/0) | partial — o pass do validador prova front matter válido; a existência das 5 seções em `##` é editorial |
| AC-13.2 (5 seções — editorial) | Manual/editorial | — | deferred (AU-32) | Aceito pelo spec |
| AC-14.1 (público sem auth) | BLOG-2 Verification externa | — | deferred | |
| AC-15.1 (giscus) | Fase 2 | — | deferred (FR-15 é fase 2) | |
| AC-16.1 (search.json existe) | site `test_indice_de_busca_lista_os_tres_posts_ficticios` (tag `FR-16 AC-16.1`) | check.sh | **red pré-existente** — teste cobra 3 URLs de posts removidos | yes; deferred a BLOG-2 D-2 (que vai afrouxar a asserção para "N posts publicados", independente de slug) |
| AC-16.2 (UI de busca) | Manual/visual | — | deferred (AU-32) | |
| AC-17.1 (sitemap.xml) | site `test_sitemap_existe` (tag `FR-17 AC-17.1`) | check.sh | ok | yes |
| AC-17.2 (robots.txt) | site `test_robots_txt_existe` (tag `FR-17 AC-17.2`) | check.sh | ok | yes |
| AC-18.1 (`noindex: true` → meta robots) | site `test_home_tem_meta_robots_noindex` (tag `FR-18 AC-18.1`); complementado por vfm `test_titulo_rascunho_*` (tags `FR-18 AC-18.1`) | check.sh + validador | ok | yes — regex casa `<meta name="robots" content="noindex, nofollow"…>` |
| AC-18.2 (`noindex: false` → meta ausente) | BLOG-2 Fase de conteúdo passo 2 | — | deferred (pós-flip, gated no D-11) | |
| AC-18.3 (≥ 10 posts reais + repos 200) | Operacional (BLOG-2 Fase de conteúdo pré-flip) | — | deferred | |
| AC-19.1 (Rouge highlight) | site `test_post_tecnico_tem_highlight_e_mermaid` (tag `FR-19 AC-19.1 AC-19.2`) | check.sh | **red pré-existente** — post `visualizando-pipelines` removido | yes; deferred a BLOG-2 D-2 |
| AC-19.2 (Mermaid em `post`) | site — mesmo teste | check.sh | **red pré-existente** | yes; deferred a BLOG-2 D-2 |
| AC-19.3 (Mermaid em `project-post`) | Garantido por D-4 (sombreamento `_includes/js-selector.html`, commit `4083351`); sem post `project-post`+Mermaid hoje | — | deferred | Verificação por inspeção pós-BLOG-2 (aceito pelo spec) |
| AC-20.1 (preview local ≡ CI) | Manual/visual | — | deferred (AU-32) | |

### Use cases (MVP)

| UC | FRs | Delivered? | Notes |
|---|---|---|---|
| UC-1 (autor cria e publica post) | FR-1, FR-2, FR-6, FR-7 | partial | FR-1 verde (validador); FR-2 propriedade nativa; FR-6 workflow existe mas `AC-6.1/6.2` deferido a BLOG-2; FR-7 propriedade do modelo |
| UC-2 (autor publica post de projeto) | FR-3, FR-13 | partial | FR-3 verde para AC-3.1..3.3 (validador) e AC-3.4 (HTML); FR-13 template existe + 5 seções editoriais deferidas |
| UC-3 (autor atualiza post) | FR-8 | partial | Invariante FR-8 verde (rejeita `last_modified_at` manual); AC-8.1/8.2/8.3 deferidos a BLOG-2 |
| UC-4 (imagens/diagramas) | FR-5, FR-19 | red pré-existente | AC-5.1/19.1/19.2 são 3 das 6 falhas herdadas de `686c5c0`; deferido a BLOG-2 D-2 |
| UC-5 (preview local) | FR-20 | deferred | AC-20.1 é manual/visual (AU-32) |
| UC-6 (home) | FR-9, FR-14 | red pré-existente | AC-9.1 é falha herdada; FR-14 deferido |
| UC-7 (categoria) | FR-10, FR-11 | partial | AC-10.1 verde; AC-11.1 verde (parcial, por rejeição); AC-10.2 red (deferido a BLOG-2) |
| UC-8 (tag) | FR-10 | red pré-existente | AC-10.2 |
| UC-9 (busca) | FR-16 | red pré-existente | AC-16.1 |
| UC-10 (leitor lê post) | FR-4, FR-14, FR-19 | red pré-existente | AC-4.1, AC-19.1/2 |
| UC-11 (contato) | FR-12 | delivered | AC-12.1 (a)(b)(c) verdes |
| UC-12 (comentário) | FR-15 | later | Fase 2 |
| UC-13 (indexação) | FR-17, FR-18 | delivered para MVP | AC-17.1/17.2/18.1 verdes; AC-18.2/18.3 gated no D-11 (BLOG-2 Fase de conteúdo) |

### Non-functional requirements

| NFR | How checked | Result |
|---|---|---|
| — | Spec rev 4 não requer `## Non-functional requirements` (AU-25: NFR/Constraints/Interfaces/requests permanecem como dívida legada aceita) | N/A |

### Decisions honored

Verifica só as decisões que **BLOG-3** exercita ou toca. Decisões do BLOG-1 (D-1..D-15) foram cobertas em passes anteriores implícitos (código já mergeado em `blog-1-mvp`); decisões de BLOG-2 (D-2..D-11) ficam para o verify de BLOG-2.

| D | Where in code | Honored? |
|---|---|---|
| D-12 (rev 4) — modernização em UC/FR/AC | `spec.md § Requirements` (linhas 82–437) + `plan.md § Coverage` matriz (BLOG-3) + `# @spec` tags em `test/*.rb` | yes — spec rev 4 aprovado 2026-09-29; matriz Coverage completa em plan.md; 48 tags aplicadas nesta issue |
| Amendment 2026-09-29 (invariante estrita de contagem) | Adotado no gate: `22/37/6/0` conservado no re-run | yes — sem alteração de comportamento; gate mantém contagem exata do baseline |
| Convenção `# @spec` (plan `### Strategy`) | `test/validate_front_matter_test.rb:23–213`, `test/site_test.rb:25–164` | yes com desvio local — 5 tags em `site_test.rb` usam markers informais (`(decisão pt-BR)`, `(exclude _config.yml)`); Coverage matrix do próprio plan registra essas rows com títulos informais também |

### Audit items

BLOG-3 não introduz `AU-n` novos nem resolve `AU-n` do spec — é rastreabilidade. Auditoria da rev 4 (`spec.md § Audit — rev 4`) fechada sem itens open antes do pass. Nenhum AU depende deste commit.

| AU | Status in spec | Test / check | Result |
|---|---|---|---|
| AU-17 (rev 1) — categoria de 1 nível | resolved | site `test_categoria_de_um_nivel_nao_gera_arvore_quebrada` (tag `AU-17 (rev 1)`) | ok — verde no baseline e no re-run |
| AU-32 (rev 4) — cobertura manual/editorial aceita | accepted-risk | 5 destinos "manual/editorial" na Coverage (AC-13.2, AC-16.2, AC-20.1, e outros) | ok — registrado no spec como risco aceito |

### Impact of the diff

- **Changed areas vs impact surface:** só `test/` e `docs/`. Zero código de produção tocado (nem `tools/`, `_config.yml`, `_layouts/`, `_includes/`, `_data/`, `_posts/`). Confere com o escopo declarado em BLOG-3 (`plan.md § Plan — BLOG-3`).
- **Untested callers / consumers:** `tools/check.sh:38,40` continua sendo o único consumidor dos dois arquivos de teste; comportamento do consumo (exit code + stdout minitest) não mudou.
- **Irreversible side effects touched:** nenhum. Comentário Ruby não executa. Auditoria de impacto invocada nesta issue confirmou veredito "PRONTO PARA COMMIT" sem operação irreversível alcançável.
- **Input states not covered:** N/A — nenhum novo estado runtime introduzido pelo diff.

### Artifacts & rollout

- **Artefato "matriz Coverage AC→teste"** — `plan.md § Coverage` (linhas 370–437) + `# @spec` tags em `test/*.rb` — ok. Revisável por `grep -n "# @spec" test/*.rb` cruzado com a tabela.
- **Rollout & rollback pieces:** N/A — plan Rollout diz "spec rev 4 não requer `## Migration & rollout` (não há migração de dado; a mudança é 100% em comentários de teste). Rollback = `git revert 76cb996`. Sem coordenação com deploy — BLOG-3 não muda o site publicado."

### Result

**pass (issue scope)** — BLOG-3 entregou o que a rev 4 e o plan Amendment 2026-09-29 prometeram: 48 tags `# @spec` aplicadas seguindo a matriz Coverage, invariante estrita de contagem preservada (`22/37/6/0` idêntico ao baseline), zero código de produção tocado, `tools/check.sh` reprodutível.

**Feature-level: NOT IMPLEMENTED.** BLOG-2 (Fase técnica D-2..D-7 + Fase de conteúdo gated no D-11) permanece em `plan.md § Deferred`. 6 ACs continuam red no gate por dependerem de posts fictícios removidos em `686c5c0` — D-2 do BLOG-2 vai reescrever `site_test.rb` para invariantes estruturais e curar as 6 falhas. Outros ACs (AC-6.1/6.2, AC-8.1/8.2, AC-14.1, AC-18.2/18.3) aguardam Verification externa em BLOG-2.

**Next skill:** `ssd-plan` para abrir `## Plan — BLOG-2 Fase técnica` (D-2..D-7) — é a próxima issue a executar no pipeline. Alternativa `ssd-verify (BLOG-2)` só faz sentido depois de o BLOG-2 task fechar. `spec.md status` fica `in-progress` e `phase: validating` (verify passou para BLOG-3; feature aguarda BLOG-2).

### Change requests

Nenhum. Os desvios locais registrados em `task.md § Deviations` (5 tags informais em `site_test.rb`; off-by-one da contagem no plan) foram classificados `class: local` e não alteram spec.
