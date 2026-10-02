# frozen_string_literal: true

require "json"
require "minitest/autorun"

# Testes de integração sobre o `_site/` já gerado por `tools/test.sh`
# (`JEKYLL_ENV=production bundle exec jekyll b`). Este arquivo não builda o
# site: só lê o resultado, porque o que ele verifica (noindex, exclude,
# links renderizados) só é observável no HTML final, e o htmlproofer não olha
# para regra de negócio.
class SiteTest < Minitest::Test
  SITE_DIR = File.join(__dir__, "..", "_site")

  def setup
    skip "_site/ não existe — rode antes: bash tools/test.sh" unless Dir.exist?(SITE_DIR)
  end

  def read(relative_path)
    File.read(File.join(SITE_DIR, relative_path))
  end

  def exists?(relative_path)
    File.exist?(File.join(SITE_DIR, relative_path))
  end

  def published_posts
    Dir[File.join(SITE_DIR, "posts", "*", "index.html")].sort
  end

  # @spec (decisão pt-BR)
  def test_home_declara_lang_pt_br
    assert_match(/<html\s[^>]*\blang="pt-BR"/, read("index.html"))
  end

  # @spec FR-18 AC-18.1
  def test_home_tem_meta_robots_noindex
    assert_match(
      /<meta\s+name="robots"\s+content="noindex,\s*nofollow"/,
      read("index.html")
    )
  end

  # @spec FR-17 AC-17.1
  def test_sitemap_existe
    assert exists?("sitemap.xml"), "_site/sitemap.xml não foi gerado"
  end

  # @spec FR-17 AC-17.2
  def test_robots_txt_existe
    assert exists?("robots.txt"), "_site/robots.txt não foi gerado"
  end

  # @spec FR-12 AC-12.1
  def test_home_tem_link_github
    assert_match(%r{href="https://github\.com/ebenezer-dorneles"}, read("index.html"))
  end

  # @spec FR-12 AC-12.1
  def test_home_tem_link_linkedin
    assert_match(%r{href="https://www\.linkedin\.com/in/ebedorneles/?"}, read("index.html"))
  end

  # @spec FR-12 AC-12.1
  def test_home_tem_link_email
    home = read("index.html")
    assert_match(/mailto:/, home)
    assert_match(/ebenezerdorneles/, home)
  end

  # @spec FR-12
  def test_pagina_sobre_existe
    assert exists?("about/index.html"), "_site/about/index.html não foi gerado"
  end

  # @spec (exclude _config.yml)
  def test_diretorio_test_nao_publicado
    refute exists?("test"), "_site/test não deveria existir"
  end

  # @spec AC-2.1 (exclude _config.yml)
  def test_diretorio_draft_nao_publicado
    refute exists?("draft"), "_site/draft não deveria existir"
  end

  # @spec (exclude _config.yml)
  def test_diretorio_docs_nao_publicado
    refute exists?("docs"), "_site/docs não deveria existir"
  end

  # @spec (exclude _config.yml)
  def test_compose_yaml_nao_publicado
    refute exists?("compose.yaml"), "_site/compose.yaml não deveria existir"
  end

  # @spec FR-3 AC-3.4
  def test_post_de_projeto_tem_link_do_repositorio
    post = read("posts/fixture-post-projeto/index.html")
    assert_match(
      %r{href="https://github\.com/ebenezer-dorneles/fixture-exemplo"},
      post
    )
  end

  # @spec FR-3 AC-3.4
  def test_post_comum_nao_tem_bloco_de_repositorio
    post = read("posts/fixture-post-comum/index.html")
    refute_match(/project-repo/, post)
  end

  # @spec FR-9 AC-9.1
  def test_home_lista_posts_em_ordem_cronologica_decrescente
    # Chirpy renderiza <time data-ts="<unix>" data-df="DD/MM/YYYY"> em cada
    # card da home; o rodapé usa <time>2026</time> sem data-ts (ignorado).
    timestamps = read("index.html").scan(/<time\s+data-ts="(\d+)"/).flatten.map(&:to_i)
    assert_operator timestamps.size, :>=, 1,
                    "home deveria listar >= 1 post via <time data-ts=...>"
    assert_equal timestamps.sort.reverse, timestamps,
                 "timestamps dos posts na home fora de ordem decrescente: #{timestamps.inspect}"
  end

  # @spec FR-10 AC-10.1
  def test_categorias_tem_pagina_por_categoria
    assert exists?("categories/desenvolvimento/index.html"),
           "_site/categories/desenvolvimento/ não foi gerado"
    assert exists?("categories/ciência-de-dados/index.html"),
           "_site/categories/ciência-de-dados/ não foi gerado"
  end

  # @spec AU-17 (rev 1)
  def test_categoria_de_um_nivel_nao_gera_arvore_quebrada
    # Chirpy suporta categorias de dois níveis e mostra um trigger de
    # expandir/colapsar para o nível filho. Com um nível só (contrato do
    # spec), o trigger deve ficar desabilitado, não ausente/quebrado.
    assert_match(/category-trigger[^"]*disabled/, read("categories/index.html"))
  end

  # @spec FR-10 AC-10.2
  def test_tags_tem_pagina_por_tag_usada
    # Tags "em uso" derivadas de search.json (que o próprio tema gera a partir
    # dos posts publicados). Invariante: para cada tag usada por algum post,
    # existe a página /tags/<tag>/.
    indice = JSON.parse(read("assets/js/data/search.json"))
    tags_em_uso = indice.flat_map do |post|
      post.fetch("tags", "").split(",").map(&:strip).reject(&:empty?)
    end.uniq
    assert_operator tags_em_uso.size, :>=, 1, "nenhuma tag em uso em posts publicados"
    tags_em_uso.each do |tag|
      assert exists?("tags/#{tag}/index.html"),
             "_site/tags/#{tag}/ ausente para tag '#{tag}' em uso em search.json"
    end
  end

  # @spec FR-4 AC-4.1
  def test_tempo_de_leitura_visivel_no_post
    posts = published_posts
    assert_operator posts.size, :>=, 1, "nenhum post publicado em _site/posts/"
    encontrado = posts.find { |path| File.read(path) =~ %r{<em>\d+\s*min</em>} }
    refute_nil encontrado,
               "nenhum post publicado renderizou indicação 'X min' de tempo de leitura " \
               "(#{posts.map { |p| File.basename(File.dirname(p)) }.inspect})"
  end

  # @spec FR-19 AC-19.1 AC-19.2 AC-19.3
  def test_post_tecnico_tem_highlight_e_mermaid
    # AC-19.1 e AC-19.2 são capacidades independentes: o primeiro post com
    # Rouge pode não ser o primeiro com Mermaid. Dois `find`s separados.
    # Marcador de Mermaid "ativo" é o carregamento de `mermaid.min.js`
    # (gated por `mermaid: true` no front matter via _includes/js-selector.html,
    # D-4) — `language-mermaid` sozinho pode vir do Rouge sem o JS. O post
    # que carrega Mermaid também é `layout: project-post` (marcador
    # `project-repo` do _layouts/project-post.html), provando AC-19.3.
    posts = published_posts
    assert_operator posts.size, :>=, 1, "nenhum post publicado em _site/posts/"
    htmls = posts.map { |p| File.read(p) }

    html_rouge = htmls.find { |html| html.include?('class="highlight"') }
    refute_nil html_rouge, "nenhum post publicado contém bloco Rouge (`class=\"highlight\"`)"

    html_mermaid = htmls.find { |html| html.include?("mermaid.min.js") }
    refute_nil html_mermaid,
               "nenhum post publicado carrega `mermaid.min.js` (front matter sem `mermaid: true` ou js-selector regrediu)"
    assert_includes html_mermaid, "language-mermaid",
                    "post com `mermaid.min.js` carregado não contém bloco `language-mermaid`"
    assert_includes html_mermaid, 'class="project-repo',
                    "post com Mermaid não é `layout: project-post` (AC-19.3 — D-4 sombreamento js-selector regrediu)"
  end

  # @spec FR-5 AC-5.1
  def test_imagem_do_post_e_servida_e_referenciada
    # Invariante universalmente quantificada: para cada post publicado que
    # referencia um asset em /assets/img/posts/<slug>/, o arquivo correspondente
    # existe em _site/. Vacuamente verdadeira enquanto nenhum post declarar
    # `image.path`; o htmlproofer (parte do gate) é o detector direto de
    # referência quebrada (AC-5.2).
    pendentes = published_posts.flat_map do |path|
      File.read(path)
          .scan(%r{src="(/assets/img/posts/[^"]+)"})
          .flatten
          .uniq
          .reject { |rel| exists?(rel.delete_prefix("/")) }
          .map { |rel| "#{File.basename(File.dirname(path))} -> #{rel}" }
    end
    assert_empty pendentes,
                 "posts com referência a asset ausente em _site/: #{pendentes.inspect}"
  end

  # @spec FR-16 AC-16.1
  def test_indice_de_busca_lista_os_tres_posts_ficticios
    # Nome legado preservado (rename é follow-up — plan Deferred). Invariante
    # estrutural: search.json contém uma entrada por post publicado.
    assert exists?("assets/js/data/search.json"), "índice de busca não foi gerado"
    indice = JSON.parse(read("assets/js/data/search.json"))
    publicados = published_posts
    assert_operator publicados.size, :>=, 1, "nenhum post publicado em _site/posts/"
    assert_equal publicados.size, indice.size,
                 "search.json tem #{indice.size} entradas; _site/posts/ tem #{publicados.size} posts"
  end
end
