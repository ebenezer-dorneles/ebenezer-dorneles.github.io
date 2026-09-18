---
title: "[RASCUNHO] Visualizando pipelines de dados com Mermaid"
date: 2026-01-15 10:00:00 -0300
categories: [Ciência de Dados]
tags: [python, visualizacao]
mermaid: true
image:
  path: diagrama.png
  alt: Diagrama do pipeline de dados
media_subpath: /assets/img/posts/visualizando-pipelines/
---
Post fictício de prototipagem do MVP (ver spec.md → Decisions). Exercita
realce de sintaxe (Rouge), diagrama Mermaid e imagem própria em
`assets/img/posts/<slug>/` (regra 5), tudo no mesmo post.

Um pipeline de dados fica mais fácil de explicar com um diagrama do que com
um parágrafo. O trecho abaixo lê um CSV, filtra linhas inválidas e agrega
por categoria:

```python
import pandas as pd

df = pd.read_csv("vendas.csv")
df = df.dropna(subset=["categoria", "valor"])
resumo = df.groupby("categoria")["valor"].sum()
```

E o fluxo das três etapas, em Mermaid:

```mermaid
flowchart LR
    A[Ler CSV] --> B[Filtrar linhas inválidas]
    B --> C[Agregar por categoria]
```

Nenhuma etapa sozinha explica o pipeline todo — é a composição das três que
importa, e é exatamente isso que o diagrama mostra melhor que o código.
