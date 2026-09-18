#!/usr/bin/env bash
#
# Gate único, igual no local e no CI: valida o front matter, roda os testes
# unitários do validador e (a partir do Step 3) o build de produção mais o
# htmlproofer e os testes de integração do site gerado.
#
# Usage: bash tools/check.sh

set -eu

bundle exec ruby tools/validate-front-matter.rb
bundle exec ruby -Itest test/validate_front_matter_test.rb
