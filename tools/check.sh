#!/usr/bin/env bash
#
# Gate único, igual no local e no CI: valida o front matter, roda os testes
# unitários do validador, builda o site de produção com htmlproofer e roda
# os testes de integração sobre o `_site/` gerado.
#
# Usage: bash tools/check.sh

set -eu

FIXTURE_POSTS_DIR="test/fixtures/site_posts"
LINKED_FIXTURES=()

# `site_test.rb` precisa de posts renderizados para checar o layout
# `project-post` (regra 3), mas esses posts são exclusivos de teste: nunca
# devem ficar em `_posts/` no commit. Symlink temporário, desfeito pelo trap
# mesmo se um passo anterior falhar.
link_fixture_posts() {
  mkdir -p _posts
  for fixture in "$FIXTURE_POSTS_DIR"/*.md; do
    target="_posts/$(basename "$fixture")"
    ln -s "../$fixture" "$target"
    LINKED_FIXTURES+=("$target")
  done
}

unlink_fixture_posts() {
  for link in "${LINKED_FIXTURES[@]:-}"; do
    [[ -n "$link" ]] && rm -f "$link"
  done
}

trap unlink_fixture_posts EXIT

link_fixture_posts

bundle exec ruby tools/validate-front-matter.rb
bundle exec ruby -Itest test/validate_front_matter_test.rb
bash tools/test.sh
bundle exec ruby -Itest test/site_test.rb
