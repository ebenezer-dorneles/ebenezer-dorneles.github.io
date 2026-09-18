# frozen_string_literal: true

require "yaml"
require "date"

# Valida o front matter de posts e rascunhos contra o contrato do spec.
module FrontMatterValidator
  CATEGORIES = ["Ciência de Dados", "Desenvolvimento"].freeze

  FRONT_MATTER_PATTERN = /\A---\s*\n(.*?)\n---\s*\n/m
  POST_FILENAME_PATTERN = /\A\d{4}-\d{2}-\d{2}-/
  REPO_PATTERN = %r{\Ahttps://github\.com/[^/\s]+/[^/\s]+\z}
  ACCENT_PATTERN = /[^\x00-\x7F]/

  # Valida o front matter de um arquivo.
  #
  # path:   caminho do arquivo (para as mensagens de erro e regras de diretório)
  # source: conteúdo bruto do arquivo (front matter + corpo)
  # config: hash do _config.yml (para regras que dependem dele, ex.: noindex)
  #
  # Devolve uma lista de mensagens de erro; vazia quando o front matter é válido.
  def self.validate(path:, source:, config:)
    match = FRONT_MATTER_PATTERN.match(source)
    return ["#{path}: front matter: ausente ou mal formado"] unless match

    begin
      data = YAML.safe_load(match[1], permitted_classes: [Date, Time]) || {}
    rescue Psych::SyntaxError, Psych::DisallowedClass
      return ["#{path}: front matter: YAML inválido"]
    end

    [
      check_title(path, data),
      check_date(path, data),
      check_filename(path),
      check_categories(path, data),
      check_tags(path, data),
      check_project(path, data),
      check_last_modified_at(path, data),
      check_draft_guard(path, data, config)
    ].flatten
  end

  def self.post?(path)
    path.include?("/_posts/") || path.start_with?("_posts/")
  end

  def self.check_title(path, data)
    title = data["title"]
    return ["#{path}: title: ausente"] if title.nil?
    return ["#{path}: title: vazio"] if title.to_s.strip.empty?

    []
  end
  private_class_method :check_title

  def self.check_date(path, data)
    return [] unless post?(path)
    return ["#{path}: date: ausente"] if data["date"].nil?

    []
  end
  private_class_method :check_date

  def self.check_filename(path)
    return [] unless post?(path)
    return [] if POST_FILENAME_PATTERN.match?(File.basename(path))

    ["#{path}: nome do arquivo: falta o prefixo AAAA-MM-DD-"]
  end
  private_class_method :check_filename

  def self.check_categories(path, data)
    categories = data["categories"]
    return ["#{path}: categories: ausente"] if categories.nil?
    return ["#{path}: categories: deve ter exatamente 1 item"] unless categories.is_a?(Array) && categories.size == 1
    return ["#{path}: categories: fora de #{CATEGORIES.join(' | ')}"] unless CATEGORIES.include?(categories.first)

    []
  end
  private_class_method :check_categories

  def self.check_tags(path, data)
    tags = data["tags"]
    return ["#{path}: tags: ausente"] if tags.nil?
    return ["#{path}: tags: vazia"] if !tags.is_a?(Array) || tags.empty?

    tags.filter_map do |tag|
      next "#{path}: tags: '#{tag}' deve ser string" unless tag.is_a?(String)
      next unless tag != tag.downcase || ACCENT_PATTERN.match?(tag)

      "#{path}: tags: '#{tag}' deve ser minúscula e sem acento"
    end
  end
  private_class_method :check_tags

  def self.check_project(path, data)
    return [] unless data["project"] == true

    errors = []
    repo = data["repo"]
    errors << "#{path}: repo: obrigatório quando project: true" if repo.nil?
    if repo && (!repo.is_a?(String) || !REPO_PATTERN.match?(repo))
      errors << "#{path}: repo: fora do formato https://github.com/<owner>/<repo>"
    end
    errors << "#{path}: layout: deve ser project-post quando project: true" if data["layout"] != "project-post"
    errors
  end
  private_class_method :check_project

  def self.check_last_modified_at(path, data)
    return [] if data["last_modified_at"].nil?

    ["#{path}: last_modified_at: não deve ser escrito à mão, é preenchido pelo hook"]
  end
  private_class_method :check_last_modified_at

  def self.check_draft_guard(path, data, config)
    title = data["title"].to_s
    return [] unless title.start_with?("[RASCUNHO]")
    return [] if config["noindex"] == true

    ["#{path}: title: post [RASCUNHO] exige noindex: true em _config.yml"]
  end
  private_class_method :check_draft_guard
end

if $PROGRAM_NAME == __FILE__
  root = "."
  if ARGV[0] == "--root"
    root = ARGV[1]
  end

  config_path = File.join(root, "_config.yml")
  config = File.exist?(config_path) ? (YAML.safe_load_file(config_path, permitted_classes: [Date, Time]) || {}) : {}

  files = Dir.glob(File.join(root, "_posts", "**", "*.md")) + Dir.glob(File.join(root, "_drafts", "**", "*.md"))

  errors = files.sort.flat_map do |file|
    FrontMatterValidator.validate(path: file, source: File.read(file), config: config)
  end

  errors.each { |error| puts error }
  exit(errors.empty? ? 0 : 1)
end
