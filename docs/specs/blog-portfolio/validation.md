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

## Validation — BLOG-2 Fase técnica — rev 4 — 2026-10-02

**Escopo do pass:** `## Plan — BLOG-2 Fase técnica` (D-2 reescrever `test/site_test.rb` para invariantes estruturais; D-3 remover `[RASCUNHO]` das fixtures; D-5 Verification externa pré-flip; D-10 supersede dos subitens do Step 6 do BLOG-1). **Fora do escopo:** BLOG-2 Fase de conteúdo (gated no D-11 — ≥ 10 posts reais publicados), que permanece em `plan.md § Deferred`. O feature-level status não fecha nesta pass por causa dessa dependência operacional.

**Commits revisados** (BLOG-2 Fase técnica, intervalo `750a3d4..341cfa1`, 7 arquivos, +608/−141):

- `73382e2 test(blog-portfolio): reescreve test/site_test.rb para invariantes estruturais (D-2)` — Phase 1, merge via PR#1 `cd6c18c`.
- `bb10890 test(blog-portfolio): renomeia fixtures sem [RASCUNHO] (D-3)` — Phase 2, merge via PR#2 `f0f0c9c`.
- `ccb5dd8 fix(content): esclarece onde serão publicados os resultados no post etl-prf` — cheque 4 (typo-fix para provar AC-8.1), merge via PR#2.
- `fe0ef64 docs(task): registra cheques 1-3 da Phase 3 do BLOG-2` — merge via PR#2.
- `0b95c57 docs(task): registra cheque 4 verde + Deviations da Phase 3` — merge via PR#3 `5c8336b`.
- `e9b5a88 docs(readme): registra customização pt-BR do fork` — cheque 5 inviabilizado por operacional, merge via PR#3.
- `a683b9e docs(task): fecha Phase 3 e decompõe Phase 4 (BLOG-2)` — merge via PR#3.
- `b479f69 docs(task): supersede BLOG-1 Step 6 via BLOG-2 Phase 3 (D-10)` — Phase 4, merge via PR#4 `74b88f2`.
- `341cfa1 docs(task): marca últimos checkboxes abertos da BLOG-2 Fase técnica` — merge via PR#4.

**Gate re-executado independentemente pela verify:**
`docker compose run --rm site bash tools/check.sh` (HEAD `341cfa1`, 2026-10-02):

- validador: **26 runs / 29 assertions / 0 failures / 0 errors / 0 skips**
- htmlproofer: **16 arquivos / 22 links internos / 0 falhas** (`Ran on 16 files!` + `HTML-Proofer finished successfully.`)
- site_test.rb: **22 runs / 54 assertions / 0 failures / 0 errors / 0 skips**

Delta vs baseline `750a3d4` (`22/37/6/0`): 6 falhas curadas, +17 assertions pelas invariantes reescritas. Igualdade estrita do validador e htmlproofer preservada.

**Cross-check independente das tags `# @spec`:**

- `grep -c "# @spec" test/site_test.rb` → 22
- `grep -c "def test_" test/site_test.rb` → 22
- `grep -c "# @spec" test/validate_front_matter_test.rb` → 26 (inalterado desde BLOG-3)
- `grep -nE "RASCUNHO|analise-exploratoria|api-tarefas-ruby|visualizando-pipelines" test/site_test.rb` → saída vazia (slugs mortos exorcizados)
- AC-19.3 somada à tag de `test_post_tecnico_tem_highlight_e_mermaid` (test/site_test.rb:163) — intent BLOG-3 "somar à tag, não substituir" preservado.

**Impacto do diff vs plan Strategy "O que não muda":** zero arquivo em `tools/`, `_config.yml`, `_layouts/`, `_includes/`, `_data/`, `.github/` tocado. Única mudança em `_posts/` é o typo-fix controlado do cheque 4 (`ccb5dd8`, +1/-1 em `_posts/2026-09-29-etl-dados-prf.md:365`), autorizado pelo plan Fase 3. Diff final: `test/site_test.rb` +102/-31; fixtures 2x +1/-1; README +2/-0; `_posts/…etl-dados-prf.md` +1/-1; `spec.md` +1/-1 (frontmatter `phase`); `task.md` +~560 linhas de bookkeeping (Checklist, Deviations, Execution Log, Verification, Wrap up).

### Acceptance criteria

Convenção: **ok** = cheque passou no re-run acima; **ok (external)** = cheque reexecutado contra o site publicado nesta sessão; **deferred** = destino registrado em Coverage como não-testado automatizado com motivo aceito pelo spec; **partial** = provado por evidência indireta com nota explícita.

| AC | Test / check | Command | Result | Asserts the "Then"? |
|---|---|---|---|---|
| AC-4.1 (tempo de leitura visível) | site `test_tempo_de_leitura_visivel_no_post` reescrito (test/site_test.rb:153-161) | `docker compose run --rm site bash tools/check.sh` | ok (22/54/0/0) | yes — `published_posts.find { ... <em>\d+ min</em> ... }` com `refute_nil`; cobre AC-4.1 por invariante sobre qualquer post |
| AC-5.1 (asset local existe) | site `test_imagem_do_post_e_servida_e_referenciada` reescrito como universalmente quantificado (test/site_test.rb:188-205) | gate | ok | partial — asserção é vacuamente verdadeira hoje (nenhum post publicado declara `image.path`); invariante correta e detectará regressão quando post real com imagem for publicado. Deviation 2026-10-02 explica. AC-5.2 (htmlproofer reprova ref quebrada) continua coberto pelo próprio gate falhando se src quebrar — `16 arquivos / 22 links internos / 0 falhas` confirma |
| AC-9.1 (home ordem cronológica decrescente) | site `test_home_lista_posts_em_ordem_cronologica_decrescente` reescrito (test/site_test.rb:110-119) | gate + cheque externo | ok + ok (external) | yes — extrai `<time data-ts="(\d+)">` da home via regex (fonte real do Chirpy, não `datetime=`), asserta `timestamps.sort.reverse == timestamps`. Cheque externo contra `https://ebenezer-dorneles.github.io/` observa o mesmo elemento no HTML servido (confirmado em task.md Phase 3 cheque 3) |
| AC-10.1 (categorias) | site `test_categorias_tem_pagina_por_categoria` (test/site_test.rb:121-127, inalterado desde BLOG-1) | gate | ok | yes — asserta `_site/categories/{desenvolvimento,ciência-de-dados}/index.html` |
| AC-10.2 (tags) | site `test_tags_tem_pagina_por_tag_usada` reescrito (test/site_test.rb:137-151) | gate | ok | yes — deriva tags de `search.json`, asserta existência de `tags/<tag>/index.html` para cada. Cobertura por invariante (não por slug específico) |
| AC-16.1 (`search.json` existe + consistente) | site `test_indice_de_busca_lista_os_tres_posts_ficticios` reescrito (test/site_test.rb:207-217) | gate | ok | yes — asserta `JSON.parse(search.json).size == published_posts.size`. Nome legado do método mantido (follow-up no `plan.md § Deferred`) |
| AC-19.1 (Rouge highlight) | site `test_post_tecnico_tem_highlight_e_mermaid` reescrito (test/site_test.rb:163-186), `find` separado para Rouge | gate | ok | yes — `htmls.find { \|html\| html.include?('class="highlight"') }` com `refute_nil`; cobertura independente de Mermaid |
| AC-19.2 (Mermaid em `post`) | mesmo teste, `find` separado para Mermaid com marcador `mermaid.min.js` (gated por `mermaid: true` via `_includes/js-selector.html` sombreado — D-4) | gate | ok | yes — carregamento de `mermaid.min.js` prova front matter `mermaid: true` ativo (não apenas `language-mermaid` do Rouge). Correção pós-auditoria registrada em Deviations 2026-10-02 |
| AC-19.3 (Mermaid em `project-post`) | mesmo teste, asserção adicional `assert_includes html_mermaid, 'class="project-repo'` (test/site_test.rb:184-185) | gate | ok | yes — prova que o único post publicado com `mermaid.min.js` ativo é `layout: project-post` (post ETL/PRF satisfaz as três capacidades em um só). Promove AC-19.3 de "garantido por D-4 sem teste dedicado" para teste direto |
| AC-6.1 (workflow dispara em push de arquivo do site) | push de `ccb5dd8` (typo-fix em `_posts/`) via PR#2 `f0f0c9c` disparou `pages-deploy.yml`; deploy publicou (confirmado por `article:modified_time: 2026-10-02T20:17:35-03:00` servido ao vivo) | — | ok (external) | yes — observação direta do deploy real; AU-30 (rev 4) tratou o risco de "dispara mas falha" por composição com AC-17.1/18.1 — ambos verdes na mesma Verification |
| AC-6.2 (`paths-ignore` não dispara em README-only) | inspeção textual: `grep -nE "paths-ignore\|branches:" .github/workflows/pages-deploy.yml` → linhas 4,7-10 com `on.push.branches: [main, master]` e `paths-ignore: [.gitignore, README.md, LICENSE]` (confirmado por `sed -n '1,12p'` nesta sessão) | — | partial | partial — prova empírica deferida pela decisão operacional do autor (PR único combinando `README.md` + `docs/task.md`); baseline do deploy capturado em task.md Verification (`last-modified: Fri, 02 Oct 2026 23:47:12 GMT`, ETag home `"6ac04280-2f6b"`) para reabertura futura. Deviation 2026-10-02 registra. Comportamento do `on.push.paths-ignore` do GitHub Actions é documentado; o literal do workflow lista `README.md` |
| AC-7.1 (histórico via git) | inspeção `git log --oneline _posts/2026-09-29-etl-dados-prf.md` mostra 2 commits (`6b16713 feat(content): publica post ETL de dados abertos da PRF` + `ccb5dd8 fix(content): esclarece ...`), cada edição rastreável sem CMS externo | `git log` | ok | yes — propriedade do modelo (regra 6/FR-6); verify por inspeção, aceito pelo spec |
| AC-8.1 (`last_modified_at` em ≥ 2 commits) | `curl -s https://ebenezer-dorneles.github.io/posts/etl-dados-prf/ \| grep -oE 'Atualizado\s*<time[^>]*>[^<]+</time>'` → `Atualizado <time data-ts="1790983055" ...> 02/10/2026 </time>`; `grep '<meta property="article:modified_time"'` → `content="2026-10-02T20:17:35-03:00"` (distinto de `article:published_time="2026-09-29T10:00:00-03:00"`) | curl | ok (external) | yes — label "Atualizado" diferente da data de publicação prova `_plugins/posts-lastmod-hook.rb` executou com git log completo (**confirma `fetch-depth: 0` em `.github/workflows/pages-deploy.yml:33` como invariante operacional em produção**). Deviation 2026-10-02 registra literal pt-BR ("Atualizado", não "Last updated" do plan) |
| AC-8.2 (`last_modified_at` em 1 commit) | implícito: antes do `ccb5dd8`, o post tinha 1 commit (`6b16713`) e o hook renderiza `last_modified_at == date` → tema omite a seção. Observado implicitamente antes de 2026-10-02 e confirmado pela presença da seção **só** depois do segundo commit | — | ok | partial — não há snapshot do estado anterior; o modelo do hook garante por construção. Aceito pelo spec como implícito do AC-8.1 (`plan.md § Coverage`) |
| AC-8.3 (checkout raso quebra) | armadilha documentada no spec | — | deferred | sem teste automatizado (explícito no spec FR-8) |
| AC-14.1 (público sem auth) | todos os 5 cheques externos da Phase 3 (`curl -s` sem credenciais) respondem 200 → nenhum redirect para login observado | curl | ok (external) | yes — implícito (nenhum header `WWW-Authenticate`, nenhum status 401/403). Registrado em plan.md § Coverage como derivável dos cheques |
| AC-17.1 (sitemap.xml 200) | `curl -s -o /dev/null -w '%{http_code}' https://ebenezer-dorneles.github.io/sitemap.xml` → **200**, corpo com `<loc>` do post + lastmod ISO | curl | ok (external) | yes — HTTP 200 + XML bem-formado |
| AC-17.2 (robots.txt 200) | `curl -s -o /dev/null -w '%{http_code}' https://ebenezer-dorneles.github.io/robots.txt` → **200**, corpo = `User-agent: *\nDisallow: /norobots/\nSitemap: ...` | curl | ok (external) | yes — AC só exige existência; indexação é inibida pelo meta robots (AC-18.1) |
| AC-18.1 (`noindex: true` → meta robots) | `curl -s https://ebenezer-dorneles.github.io/ \| grep -c '<meta name="robots" content="noindex, nofollow">'` → **1**; site `test_home_tem_meta_robots_noindex` (test/site_test.rb:35-41) | curl + gate | ok (external) + ok | yes — regex casa o literal no `<head>`; emitido por `_includes/metadata-hook.html` quando `site.noindex: true` |
| AC-18.2 (`noindex: false` → meta ausente) | BLOG-2 Fase de conteúdo (gated no D-11) | — | deferred | pós-flip; prova indireta na Phase 2 (simulação sed throwaway → `test_home_tem_meta_robots_noindex` fica como única falha, comportamento esperado) |
| AC-18.3 (≥ 10 posts reais + repos 200) | **parte "repo HTTP 200"**: `curl -s -o /dev/null -w '%{http_code}' https://github.com/ebenezer-dorneles/etl-prf-data` → **200** (habilitado por D-6, concluído 2026-09-29); parte "≥ 10 posts" é operacional da Fase de conteúdo | curl | ok (external — parcial) | parcial — "repo 200" verde para o único post `project: true` hoje. Contador "≥ 10 posts" deferido à Fase de conteúdo |

### Use cases (MVP, revisitados após BLOG-2 Fase técnica)

| UC | FRs | Delivered? | Notes |
|---|---|---|---|
| UC-1 (autor cria e publica post) | FR-1, FR-2, FR-6, FR-7 | delivered | FR-1 verde (validador 26/29/0/0); FR-2 propriedade nativa; FR-6 AC-6.1 provado por PR#2; FR-7 inspeção git |
| UC-2 (autor publica post de projeto) | FR-3, FR-13 | delivered | FR-3 AC-3.1..3.3 (validador) + AC-3.4 (gate site_test); FR-13 template presente; 5 seções editoriais são AU-32 (manual) |
| UC-3 (autor atualiza post) | FR-8 | delivered | AC-8.1 provado externamente (`article:modified_time` distinto de `published_time`); AC-8.2 implícito; AC-8.3 armadilha documentada |
| UC-4 (imagens/diagramas) | FR-5, FR-19 | delivered | AC-5.1 reescrito como universalmente quantificado (vacuamente verdadeiro hoje; detectará regressão); AC-5.2 htmlproofer verde; AC-19.1/2/3 todos verdes com testes separados para Rouge, Mermaid e `project-post` |
| UC-5 (preview local) | FR-20 | deferred | AC-20.1 manual/visual (AU-32) |
| UC-6 (home) | FR-9, FR-14 | delivered | AC-9.1 reescrito como invariante (`<time data-ts>` em ordem decrescente); AC-14.1 implícito nos 5 cheques externos |
| UC-7 (categoria) | FR-10, FR-11 | delivered | AC-10.1 verde; AC-11.1 verde (parcial, por rejeição) |
| UC-8 (tag) | FR-10 | delivered | AC-10.2 reescrito como invariante (`search.json` → `tags/<tag>/`) |
| UC-9 (busca) | FR-16 | delivered | AC-16.1 reescrito (`search.json.size == publicados.size`); AC-16.2 manual (AU-32) |
| UC-10 (leitor lê post) | FR-4, FR-14, FR-19 | delivered | AC-4.1, AC-19.1/2/3 todos verdes |
| UC-11 (contato) | FR-12 | delivered | AC-12.1 (a)(b)(c) verdes |
| UC-12 (comentário) | FR-15 | later | Fase 2 (fora do MVP) |
| UC-13 (indexação) | FR-17, FR-18 | partial (MVP ok, flip pendente) | AC-17.1/17.2/18.1 verdes externamente; AC-18.2/18.3 gated no D-11 (BLOG-2 Fase de conteúdo) |

### Non-functional requirements

| NFR | How checked | Result |
|---|---|---|
| — | Spec rev 4 não requer `## Non-functional requirements` (AU-25 — dívida legada aceita) | N/A |

### Decisions honored

Decisões do BLOG-2 Fase técnica (D-2, D-3, D-5, D-10) + fatos consumados do BLOG-2 (D-4, D-6, D-7, D-8, D-11). D-1..D-15 narrativas do BLOG-1 cobertas em passes anteriores; D-11, D-12, D-13 continuam gated/satisfeitos conforme fase.

| D | Where in code | Honored? |
|---|---|---|
| D-2 (reescrita invariantes estruturais) | `test/site_test.rb:110-217` (6 testes reescritos + helper `published_posts` em test/site_test.rb:26-28) | yes — 102 linhas tocadas; invariantes capturam a propriedade (ordem decrescente de datas, página por tag/categoria em uso, consistência `search.json`↔posts, `read_time` renderizado, Rouge + Mermaid gated + `project-post`); 0 slugs mortos restantes |
| D-3 (fixtures sem `[RASCUNHO]`) | `test/fixtures/site_posts/2026-01-01-fixture-post-projeto.md:2`, `test/fixtures/site_posts/2026-01-02-fixture-post-comum.md:2` | yes — títulos renomeados; slugs preservados; precondição real do flip provada pela simulação sed throwaway (task.md § Verification Phase 2) |
| D-4 (sombreamento `_includes/js-selector.html`) | fato consumado em `4083351` (fora desta pass); provado funcional pelo `mermaid.min.js` carregado + `project-repo` no post ETL/PRF | yes — asserção adicional em `test_post_tecnico_tem_highlight_e_mermaid` (test/site_test.rb:184-185) promove de "garantido sem teste" para teste direto |
| D-5 (Verification externa pré-flip) | `task.md § Verification → Phase 3 (D-5)` com comando + resultado literal de cada cheque | yes com desvio local — 4 cheques verdes empiricamente (robots.txt, sitemap.xml, meta noindex, `fetch-depth: 0` via "Atualizado"); 1 cheque (`paths-ignore`) satisfeito textualmente com baseline capturado para reabertura. Deviation 2026-10-02 explica |
| D-6 (`etl-prf-data` público) | `_posts/2026-09-29-etl-dados-prf.md:8` resolve para repo que responde 200 (`curl` nesta sessão) | yes — fato consumado 2026-09-29; AC-18.3 "repo 200" verde |
| D-7 (Pages Source = GitHub Actions) | deploy publicado em `https://ebenezer-dorneles.github.io/` (200); `article:modified_time` do post ETL/PRF reflete o merge de PR#2 em `main` | yes — fato consumado 2026-09-29; sem registro automatizado, mas observação direta do deploy ativo |
| D-8 (invariante home via fixtures) | `test_home_lista_posts_em_ordem_cronologica_decrescente` roda contra `_site/` que inclui 2 fixtures symlinkadas + post real → ≥ 3 timestamps ordenáveis no gate local | yes — invariante estrutural robusta contra variação de conteúdo |
| D-10 (supersede Step 6 BLOG-1 em task.md) | `task.md:16-25` nota do topo da Checklist reescrita; `task.md § Wrap up` 3 de 4 checkboxes marcados `[x]` (último é ownership desta skill — `status: implemented`); Phase 4 marcada integralmente | yes — bookkeeping documental sem perda de rastreabilidade (nada apagado; Execution Log do Step 6 preservado como append-only) |
| D-11 (gate de 10 posts para flip) | `_config.yml` continua `noindex: true` (não tocado nesta pass); contador `grep -rL '\[RASCUNHO\]' _posts/*.md \| wc -l` = 1 (só o ETL/PRF) | respeitado — Fase de conteúdo aguarda marco; não é falha, é característica da pass (gated em espera, não em atraso) |

### Audit items

Audit da rev 4 (`spec.md § Audit — rev 4`): 3 achados triados — AU-30 (resolved: composição com AC-17.1/18.1), AU-31 (invalid: placement defensível), AU-32 (resolved: característica aceita do MVP). Nenhum AU-n open em qualquer `## Audit — rev N`. BLOG-2 Fase técnica não introduz nem resolve AU-n novos; executa decisões já tomadas.

| AU | Status in spec | Test / check | Result |
|---|---|---|---|
| AU-17 (rev 1) — categoria de 1 nível | resolved | `test_categoria_de_um_nivel_nao_gera_arvore_quebrada` (test/site_test.rb:129-135) | ok — verde no re-run |
| AU-30 (rev 4) — AC-6.1 só valida gatilho | resolved | composição com AC-17.1 (200 externo) + AC-18.1 (meta no HTML servido) prova que o build/deploy completaram — não apenas dispararam | ok — ambos AC-17.1 e AC-18.1 verdes externamente |
| AU-31 (rev 4) — placement de `Use case coverage` | invalid | — | ok — contract trata como conteúdo obrigatório, não localização |
| AU-32 (rev 4) — ACs manuais/editoriais | accepted-risk | AC-13.2, AC-16.2, AC-19.3 (promovido para automatizado nesta pass), AC-20.1 continuam fora da automação | ok — risco aceito; AC-19.3 ganhou cobertura automatizada bonus nesta pass |

### Impact of the diff

- **Changed areas vs plan Strategy "O que não muda":** `tools/`, `_config.yml`, `_layouts/`, `_includes/`, `_data/`, `.github/` **não tocados**. Fora de `test/` + `docs/specs/`, única mudança foi `+aqui` no `_posts/2026-09-29-etl-dados-prf.md:365` (typo-fix controlado do cheque 4) + 2 linhas em `README.md` (cheque 5). Tudo autorizado pelo plan Fase 3.
- **Untested callers / consumers:** `test/site_test.rb` é consumido apenas por `tools/check.sh:38`; comportamento do consumo (exit code + stdout minitest) não mudou. `test/fixtures/site_posts/*.md` são consumidos por `tools/check.sh:18-25` (symlink efêmero via `trap`); slugs preservados → consumo intacto. Nenhum `_posts/`, `_data/`, `_includes/`, `_layouts/` tocado → zero cadeia nova a conferir.
- **Irreversible side effects touched:** o deploy do site publicado é o único efeito irreversível alcançável a partir do diff (prova intencional de AC-6.1/AC-8.1 via `ccb5dd8`). Reversibilidade: `git revert ccb5dd8` restaura o texto anterior; a prova de AC-8.1 permanece válida (o fato ocorreu). Cache de buscador **não é risco** pois `noindex: true` continua ativo durante toda a pass.
- **Input states not covered:** 3 follow-ups abertos registrados em task.md Wrap up: (a) prova empírica de AC-6.2 adiada; (b) tag com espaço quebraria `test_tags_tem_pagina_por_tag_usada` (FR-1 AC-1.7 proíbe maiúscula/acento, não espaços); (c) rename de método `test_indice_de_busca_lista_os_tres_posts_ficticios` (nome legado contradiz invariante). Nenhum bloqueia validation.

### Artifacts & rollout

- **Site publicado** — `https://ebenezer-dorneles.github.io/` responde 200 com conteúdo esperado: lang pt-BR, home listando o post ETL/PRF, meta robots `noindex, nofollow` ativo, links de contato (GitHub, LinkedIn, mailto), sitemap.xml e robots.txt servidos. Página do post renderiza bloco Rouge (Python), diagrama Mermaid, bloco `project-repo` com link para `etl-prf-data`, metadata "Postado em 29/09/2026" + "Atualizado 02/10/2026".
- **Rollout & rollback:** plan `### Rollout & rollback` prevê rollback por fase via `git revert`. Nenhuma coordenação com deploy necessária — BLOG-2 Fase técnica mantém `noindex: true` ativo. **O flip (BLOG-2 Fase de conteúdo) continua gated no D-11** e ganha plan separado quando o marco de ≥ 10 posts reais for atingido.
- **Dívida de infra do workflow** (passos inline `Build site`/`Test site` do `pages-deploy.yml` × `bash tools/check.sh`): fora do escopo do BLOG-2 (`spec.md § BLOG-2 → Fora do escopo`). Vira issue própria quando o workflow for tocado.

### Result

**pass (issue scope: BLOG-2 Fase técnica)** — D-2, D-3, D-5, D-10 todos entregues e provados. Gate local independente verde (`26/29/0/0`, `16/22/0`, `22/54/0/0`); 5 cheques externos re-executados nesta sessão todos verdes ou provados por inspeção textual com baseline. Reescrita de `test/site_test.rb` curou as 6 falhas herdadas de `686c5c0` sem perder cobertura de nenhum AC previamente coberto; AC-19.3 promovido de "garantido sem teste" para teste direto.

**Feature-level: NOT IMPLEMENTED.** BLOG-2 **Fase de conteúdo** (D-11 gated em ≥ 10 posts reais publicados + flip de `noindex: true → false` + Verification pós-flip) continua em `plan.md § Deferred`. É espera operacional (semanas a meses enquanto o autor publica conteúdo real), não atraso técnico — explicitamente aceito pela decisão D-11 do spec rev 2.

**Next skill:** aguardar marco D-11 (ação do autor, fora do SSD) → quando atingido, **ssd-plan** abre `## Plan — BLOG-2 Fase de conteúdo`; eventualmente **ssd-task** executa; e **ssd-verify** fecha. Para esta pass, `spec.md status` continua `in-progress` e `phase` volta a `validating` (verify passou para BLOG-2 Fase técnica; feature-level aguarda Fase de conteúdo). Imediato: autor pode fazer Wrap up externo (nada mais a fazer no SSD até Fase de conteúdo).

### Change requests

Nenhum. Os desvios registrados em `task.md § Deviations` (literal pt-BR "Atualizado" vs plan "Last updated"; cheque 5 empírico deferido com baseline capturado; AC-5.1 reinterpretado como universalmente quantificado; AC-19 corrigido pós-auditoria com `find`s separados + marcador `mermaid.min.js` + asserção `project-repo`; `<time data-ts>` vs plan `<time datetime>`; padrão PR via web vs plan "autor único, sem PR") foram todos classificados `class: local` e preservam o intent do plan sem tocar o spec. A única deviation `plan-affecting` histórica (2026-09-29, invariante estrita de contagem do BLOG-3) foi absorvida pelo Amendment do próprio plan antes desta pass.
