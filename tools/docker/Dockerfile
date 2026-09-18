# Runtime local igual ao do CI (ruby/setup-ruby com ruby-version: 3.4).
# Só para desenvolvimento: o workflow do Actions não usa esta imagem.
# Ao mudar a versão do Ruby, mudar junto: .ruby-version e .github/workflows/pages-deploy.yml.
FROM ruby:3.4

ARG UID=1000
ARG GID=1000

# Usuário com o mesmo UID do dono do repositório: arquivos gerados no bind mount
# (Gemfile.lock, _site/) não nascem com dono root, e o git não recusa o repositório.
RUN groupadd --gid "$GID" dev \
 && useradd --uid "$UID" --gid "$GID" --create-home dev \
 && git config --system --add safe.directory /srv/site

USER dev
WORKDIR /srv/site
