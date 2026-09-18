#!/usr/bin/env bash
#
# Gate único, igual no local e no CI: valida o front matter, roda os testes
# unitários do validador, builda o site de produção com htmlproofer e roda
# os testes de integração sobre o `_site/` gerado.
#
# Usage: bash tools/check.sh

set -eu

bundle exec ruby tools/validate-front-matter.rb
bundle exec ruby -Itest test/validate_front_matter_test.rb
bash tools/test.sh
bundle exec ruby -Itest test/site_test.rb
