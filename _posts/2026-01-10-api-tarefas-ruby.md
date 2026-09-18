---
title: "[RASCUNHO] API de tarefas em Ruby"
date: 2026-01-10 10:00:00 -0300
categories: [Desenvolvimento]
tags: [ruby, jekyll]
project: true
layout: project-post
repo: https://github.com/ebenezer-dorneles/api-tarefas-exemplo
---
Post fictício de prototipagem do MVP (ver spec.md → Decisions). Exercita o
layout `project-post` (regra 3) com um post real, não só a fixture de teste
da Etapa 4, e a categoria "Desenvolvimento".

## Contexto

Uma API mínima de lista de tarefas, para exercitar a estrutura de post de
projeto (regra 13) com um exemplo pequeno e completo.

## Stack técnica

Ruby puro, sem framework: `WEBrick` para o servidor HTTP e um array em
memória como armazenamento, propositalmente sem banco de dados — o foco é a
estrutura da API, não a persistência.

## Processo

Três rotas (`GET /tarefas`, `POST /tarefas`, `DELETE /tarefas/:id`), cada uma
com um teste de integração via `Net::HTTP` contra o servidor rodando numa
porta de teste.

## Resultado

API funcional, com os três endpoints cobertos por teste automatizado e sem
dependência externa além da stdlib do Ruby.

## Aprendizados

`WEBrick` sozinho não escala além de um exemplo didático — falta pool de
conexões e roteamento de verdade. Para algo real, a escolha seria Sinatra ou
Rails API.
