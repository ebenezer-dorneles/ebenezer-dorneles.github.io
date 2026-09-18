---
title: "[RASCUNHO] Análise exploratória de dados de vendas"
date: 2026-01-05 10:00:00 -0300
categories: [Ciência de Dados]
tags: [python, dados]
---
Post fictício de prototipagem do MVP (ver spec.md → Decisions). Exercita a
categoria "Ciência de Dados" e a listagem cronológica da home.

Uma análise exploratória começa quase sempre pela mesma pergunta: os dados
batem com o que o negócio espera? Antes de qualquer modelo, vale olhar a
distribuição das variáveis, procurar valores fora da curva e confirmar que
não há duplicatas escondidas atrás de um `join` mal feito.

Neste projeto fictício, a base de vendas tinha uma coluna de datas em dois
formatos diferentes — herança de duas planilhas que nunca deveriam ter sido
unidas sem normalização prévia. O primeiro passo real de qualquer análise
é sempre esse: desconfiar do dado antes de confiar no gráfico.
