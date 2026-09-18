# frozen_string_literal: true

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

  def test_home_declara_lang_pt_br
    assert_match(/<html\s[^>]*\blang="pt-BR"/, read("index.html"))
  end

  def test_home_tem_meta_robots_noindex
    assert_match(
      /<meta\s+name="robots"\s+content="noindex,\s*nofollow"/,
      read("index.html")
    )
  end

  def test_sitemap_existe
    assert exists?("sitemap.xml"), "_site/sitemap.xml não foi gerado"
  end

  def test_robots_txt_existe
    assert exists?("robots.txt"), "_site/robots.txt não foi gerado"
  end

  def test_home_tem_link_github
    assert_match(%r{href="https://github\.com/ebenezer-dorneles"}, read("index.html"))
  end

  def test_home_tem_link_linkedin
    assert_match(%r{href="https://www\.linkedin\.com/in/ebedorneles/?"}, read("index.html"))
  end

  def test_home_tem_link_email
    home = read("index.html")
    assert_match(/mailto:/, home)
    assert_match(/ebenezerdorneles/, home)
  end

  def test_pagina_sobre_existe
    assert exists?("about/index.html"), "_site/about/index.html não foi gerado"
  end

  def test_diretorio_test_nao_publicado
    refute exists?("test"), "_site/test não deveria existir"
  end

  def test_diretorio_draft_nao_publicado
    refute exists?("draft"), "_site/draft não deveria existir"
  end

  def test_diretorio_docs_nao_publicado
    refute exists?("docs"), "_site/docs não deveria existir"
  end

  def test_compose_yaml_nao_publicado
    refute exists?("compose.yaml"), "_site/compose.yaml não deveria existir"
  end

  def test_post_de_projeto_tem_link_do_repositorio
    post = read("posts/fixture-post-projeto/index.html")
    assert_match(
      %r{href="https://github\.com/ebenezer-dorneles/fixture-exemplo"},
      post
    )
  end

  def test_post_comum_nao_tem_bloco_de_repositorio
    post = read("posts/fixture-post-comum/index.html")
    refute_match(/project-repo/, post)
  end

  def test_home_lista_posts_em_ordem_cronologica_decrescente
    home = read("index.html")
    posicoes = [
      "/posts/visualizando-pipelines/",
      "/posts/api-tarefas-ruby/",
      "/posts/analise-exploratoria-vendas/"
    ].map { |url| home.index(%(href="#{url}")) }

    posicoes.each { |posicao| refute_nil posicao, "post ausente da home" }
    assert_equal posicoes, posicoes.sort, "posts fora de ordem cronológica decrescente"
  end

  def test_categorias_tem_pagina_por_categoria
    assert exists?("categories/desenvolvimento/index.html"),
           "_site/categories/desenvolvimento/ não foi gerado"
    assert exists?("categories/ciência-de-dados/index.html"),
           "_site/categories/ciência-de-dados/ não foi gerado"
  end

  def test_categoria_de_um_nivel_nao_gera_arvore_quebrada
    # Chirpy suporta categorias de dois níveis e mostra um trigger de
    # expandir/colapsar para o nível filho. Com um nível só (contrato do
    # spec), o trigger deve ficar desabilitado, não ausente/quebrado.
    assert_match(/category-trigger[^"]*disabled/, read("categories/index.html"))
  end

  def test_tags_tem_pagina_por_tag_usada
    %w[python dados ruby jekyll visualizacao].each do |tag|
      assert exists?("tags/#{tag}/index.html"), "_site/tags/#{tag}/ não foi gerado"
    end
  end

  def test_tempo_de_leitura_visivel_no_post
    assert exists?("posts/api-tarefas-ruby/index.html"), "post não foi gerado"
    assert_match(%r{<em>\d+ min</em>}, read("posts/api-tarefas-ruby/index.html"))
  end

  def test_post_tecnico_tem_highlight_e_mermaid
    assert exists?("posts/visualizando-pipelines/index.html"), "post não foi gerado"
    post = read("posts/visualizando-pipelines/index.html")
    assert_match(/class="highlight"/, post)
    assert_match(/language-mermaid/, post)
  end

  def test_imagem_do_post_e_servida_e_referenciada
    assert exists?("posts/visualizando-pipelines/index.html"), "post não foi gerado"
    post = read("posts/visualizando-pipelines/index.html")
    assert_match(%r{src="/assets/img/posts/visualizando-pipelines/diagrama\.png"}, post)
    assert exists?("assets/img/posts/visualizando-pipelines/diagrama.png"),
           "imagem não foi copiada para _site/"
  end

  def test_indice_de_busca_lista_os_tres_posts_ficticios
    assert exists?("assets/js/data/search.json"), "índice de busca não foi gerado"
    indice = read("assets/js/data/search.json")
    [
      "/posts/analise-exploratoria-vendas/",
      "/posts/api-tarefas-ruby/",
      "/posts/visualizando-pipelines/"
    ].each { |url| assert_includes indice, url }
  end
end
