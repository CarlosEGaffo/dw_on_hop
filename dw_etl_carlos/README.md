# Trabalho ETL – DW de Estoque (Apache Hop)

Ambiente pronto com 3 containers:

| Serviço    | Endereço no navegador / porta      | Login                    |
|------------|------------------------------------|--------------------------|
| PostgreSQL | localhost:5432                     | postgres / postgres      |
| pgAdmin    | http://localhost:5050              | sem login (já conectado) |
| Apache Hop | http://localhost:8080/ui           | –                        |

Na primeira subida o PostgreSQL cria a database **erp** e roda, em ordem:

1. `initdb/01_erp.sql` – schema `erp` com os dados de exemplo do professor.
2. `initdb/02_dw_estoque.sql` – schema `dw` com `dim_tempo`, `dim_produto`, `dim_deposito`,
   `dim_tipo_movimento`, `dim_lote` e `fato_movimento_estoque` (vazias, só com a linha -1).

## Como usar

```bash
docker compose up -d          # sobe tudo
docker compose ps             # confere se está "healthy"
docker compose logs postgres  # vê a carga dos scripts
docker compose down           # para (mantém os dados)
docker compose down -v        # para e APAGA o banco (os scripts rodam de novo na próxima subida)
```

> Os scripts de `initdb/` só rodam quando o volume do banco é criado.
> Se mudar algum `.sql`, rode `docker compose down -v` e suba de novo.

## Conexões no Apache Hop

O host muda conforme onde o Hop está rodando:

| Campo           | Hop do container (localhost:8080/ui) | Hop instalado no PC (Hop GUI) |
|-----------------|--------------------------------------|-------------------------------|
| Connection type | PostgreSQL                           | PostgreSQL                    |
| Server host     | **postgres**                         | **localhost**                 |
| Port            | 5432                                 | valor de `PG_PORT` (5432)     |
| Database name   | erp                                  | erp                           |
| Username / Pass | postgres / postgres                  | postgres / postgres           |

Crie duas conexões com esses dados: **ERP-ORIGEM** e **DW-DESTINO**
(Opção A dos slides: o DW fica no schema `dw` da mesma database).

No Hop web, crie o projeto apontando para a pasta **/files** — ela é a pasta `hop/`
deste diretório, então os pipelines ficam salvos no seu computador.

## Problemas comuns

- **Porta 5432 ocupada** (PostgreSQL já instalado no PC): mude `PG_PORT=5433` no `.env`.
- **Porta 8080 ocupada**: mude `HOP_PORT` no `.env`.
- **Tabelas do dw não aparecem**: o volume já existia antes; rode `docker compose down -v` e suba de novo.

## Observação sobre o 01_erp.sql

O arquivo de exemplo recebido estava cortado no fim da tabela `conta_receber`
(última linha incompleta). O script foi fechado na última linha completa
(162 contas a receber). Isso não afeta o DW de estoque, que usa
`movimento_estoque` (768 linhas), `produto`, `lote_produto`, `deposito`,
`filial`, `cidade`, `estado`, `pedido_venda` e `pedido_compra`.
Se tiver o arquivo original completo do Drive, basta substituir `initdb/01_erp.sql` por ele.
