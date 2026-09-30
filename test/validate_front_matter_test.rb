# frozen_string_literal: true

require "minitest/autorun"
require_relative "../tools/validate-front-matter"

class ValidateFrontMatterTest < Minitest::Test
  VALID_CONFIG = { "noindex" => true }.freeze

  VALID_POST = <<~YAML
    ---
    title: "Um post válido"
    date: 2026-01-01 10:00:00 +0000
    categories: [Desenvolvimento]
    tags: [ruby, jekyll]
    ---
    Corpo do post.
  YAML

  def validate(source, path: "_posts/2026-01-01-um-post.md", config: VALID_CONFIG)
    FrontMatterValidator.validate(path: path, source: source, config: config)
  end

  # @spec FR-1 AC-11.1
  def test_valid_post_has_no_errors
    assert_empty validate(VALID_POST)
  end

  # @spec FR-1 AC-1.1
  def test_title_ausente
    source = VALID_POST.sub(/title: .*\n/, "")
    errors = validate(source)
    assert(errors.any? { |e| e.include?("title") }, errors.inspect)
  end

  # @spec FR-1 AC-1.1
  def test_title_vazio
    source = VALID_POST.sub(/title: .*/, 'title: ""')
    errors = validate(source)
    assert(errors.any? { |e| e.include?("title") }, errors.inspect)
  end

  # @spec FR-1 AC-1.2
  def test_date_ausente_em_posts
    source = VALID_POST.sub(/date: .*\n/, "")
    errors = validate(source, path: "_posts/2026-01-01-um-post.md")
    assert(errors.any? { |e| e.include?("date") }, errors.inspect)
  end

  # @spec FR-1 AC-1.8
  def test_date_ausente_em_drafts_eh_aceito
    source = VALID_POST.sub(/date: .*\n/, "")
    errors = validate(source, path: "_drafts/um-post.md")
    refute(errors.any? { |e| e.include?("date") }, errors.inspect)
  end

  # @spec FR-1 AC-1.3
  def test_arquivo_em_posts_sem_prefixo_de_data
    errors = validate(VALID_POST, path: "_posts/um-post.md")
    assert(errors.any? { |e| e.include?("nome do arquivo") || e.include?("prefixo") }, errors.inspect)
  end

  # @spec FR-1 AC-1.4
  def test_categories_ausente
    source = VALID_POST.sub(/categories: .*\n/, "")
    errors = validate(source)
    assert(errors.any? { |e| e.include?("categories") }, errors.inspect)
  end

  # @spec FR-1 AC-1.4
  def test_categories_com_zero_itens
    source = VALID_POST.sub(/categories: .*/, "categories: []")
    errors = validate(source)
    assert(errors.any? { |e| e.include?("categories") }, errors.inspect)
  end

  # @spec FR-1 AC-1.4
  def test_categories_com_dois_itens
    source = VALID_POST.sub(/categories: .*/, "categories: [Desenvolvimento, Ciência de Dados]")
    errors = validate(source)
    assert(errors.any? { |e| e.include?("categories") }, errors.inspect)
  end

  # @spec FR-1 AC-1.5 AC-11.1
  def test_categories_fora_da_lista_fixa
    source = VALID_POST.sub(/categories: .*/, "categories: [Culinária]")
    errors = validate(source)
    assert(errors.any? { |e| e.include?("categories") }, errors.inspect)
  end

  # @spec FR-1 AC-1.6
  def test_tags_ausente
    source = VALID_POST.sub(/tags: .*\n/, "")
    errors = validate(source)
    assert(errors.any? { |e| e.include?("tags") }, errors.inspect)
  end

  # @spec FR-1 AC-1.6
  def test_tags_vazia
    source = VALID_POST.sub(/tags: .*/, "tags: []")
    errors = validate(source)
    assert(errors.any? { |e| e.include?("tags") }, errors.inspect)
  end

  # @spec FR-1 AC-1.7
  def test_tag_com_maiuscula
    source = VALID_POST.sub(/tags: .*/, "tags: [Ruby]")
    errors = validate(source)
    assert(errors.any? { |e| e.include?("tags") }, errors.inspect)
  end

  # @spec FR-1 AC-1.7
  def test_tag_com_acento
    source = VALID_POST.sub(/tags: .*/, "tags: [código]")
    errors = validate(source)
    assert(errors.any? { |e| e.include?("tags") }, errors.inspect)
  end

  # @spec AC-1.6 (auditoria-de-impacto)
  def test_tag_nao_string_nao_derruba_o_validador
    source = VALID_POST.sub(/tags: .*/, "tags: [42]")
    errors = validate(source)
    assert(errors.any? { |e| e.include?("tags") }, errors.inspect)
  end

  # @spec AC-3.2 (auditoria-de-impacto)
  def test_repo_nao_string_nao_derruba_o_validador
    source = VALID_POST.sub(
      /\ntags:/,
      "\nproject: true\nlayout: project-post\nrepo: 12345\ntags:"
    )
    errors = validate(source)
    assert(errors.any? { |e| e.include?("repo") }, errors.inspect)
  end

  # @spec FR-3 AC-3.1
  def test_project_true_sem_repo
    source = VALID_POST.sub(/\ntags:/, "\nproject: true\nlayout: project-post\ntags:")
    errors = validate(source)
    assert(errors.any? { |e| e.include?("repo") }, errors.inspect)
  end

  # @spec FR-3 AC-3.2
  def test_repo_fora_do_formato_github
    source = VALID_POST.sub(
      /\ntags:/,
      "\nproject: true\nlayout: project-post\nrepo: \"https://gitlab.com/owner/repo\"\ntags:"
    )
    errors = validate(source)
    assert(errors.any? { |e| e.include?("repo") }, errors.inspect)
  end

  # @spec FR-3 AC-3.3
  def test_project_true_sem_layout_project_post
    source = VALID_POST.sub(
      /\ntags:/,
      "\nproject: true\nrepo: \"https://github.com/owner/repo\"\ntags:"
    )
    errors = validate(source)
    assert(errors.any? { |e| e.include?("layout") }, errors.inspect)
  end

  # @spec FR-8
  def test_last_modified_at_escrito_a_mao
    source = VALID_POST.sub(/\ntags:/, "\nlast_modified_at: 2026-01-02 10:00:00 +0000\ntags:")
    errors = validate(source)
    assert(errors.any? { |e| e.include?("last_modified_at") }, errors.inspect)
  end

  # @spec FR-1
  def test_arquivo_sem_front_matter
    errors = validate("Só corpo, sem front matter.\n")
    assert(errors.any? { |e| e.include?("front matter") }, errors.inspect)
  end

  # @spec FR-1
  def test_yaml_invalido
    source = "---\ntitle: [não fecha a lista\n---\nCorpo.\n"
    errors = validate(source)
    assert(errors.any? { |e| e.include?("front matter") || e.include?("YAML") }, errors.inspect)
  end

  # @spec FR-18 AC-18.1
  def test_titulo_rascunho_sem_noindex_no_config
    source = VALID_POST.sub(/title: .*/, 'title: "[RASCUNHO] Um post"')
    errors = validate(source, config: { "noindex" => false })
    assert(errors.any? { |e| e.include?("noindex") || e.include?("RASCUNHO") }, errors.inspect)
  end

  # @spec FR-18 AC-18.1
  def test_titulo_rascunho_com_noindex_no_config_eh_aceito
    source = VALID_POST.sub(/title: .*/, 'title: "[RASCUNHO] Um post"')
    errors = validate(source, config: { "noindex" => true })
    assert(errors.none? { |e| e.include?("noindex") || e.include?("RASCUNHO") }, errors.inspect)
  end
end

class ValidateFrontMatterCliTest < Minitest::Test
  require "open3"

  ROOT = File.expand_path("../..", __FILE__)
  SCRIPT = File.join(ROOT, "tools", "validate-front-matter.rb")

  def run_cli(root)
    Open3.capture3("ruby", SCRIPT, "--root", root)
  end

  # @spec FR-1 (CLI)
  def test_cli_exit_0_em_fixture_valida
    stdout, _stderr, status = run_cli(File.join(ROOT, "test/fixtures/front_matter/valid"))
    assert status.success?, stdout
  end

  # @spec FR-1 (CLI)
  def test_cli_exit_1_em_fixture_invalida
    stdout, _stderr, status = run_cli(File.join(ROOT, "test/fixtures/front_matter/invalid"))
    refute status.success?, stdout
    refute_empty stdout
  end
end
