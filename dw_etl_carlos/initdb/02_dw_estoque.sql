-- ============================================================
-- DATA WAREHOUSE - ESTOQUE
-- ============================================================

DROP SCHEMA IF EXISTS dw CASCADE;
CREATE SCHEMA dw;

-- DIM_TEMPO
CREATE TABLE dw.dim_tempo (
    sk_tempo        INTEGER PRIMARY KEY,
    data            DATE,
    dia             INTEGER,
    mes             INTEGER,
    nome_mes        VARCHAR(20),
    trimestre       INTEGER,
    ano             INTEGER,
    dia_semana      INTEGER,          
    nome_dia_semana VARCHAR(20),
    fim_de_semana   CHAR(1)           
);

-- DIM_PRODUTO
CREATE SEQUENCE dw.seq_dim_produto START 1;

CREATE TABLE dw.dim_produto (
    sk_produto        INTEGER PRIMARY KEY DEFAULT nextval('dw.seq_dim_produto'),
    nk_produto        INTEGER NOT NULL,
    sku               VARCHAR(30) NOT NULL UNIQUE,
    nome_produto      VARCHAR(160) NOT NULL,
    marca             VARCHAR(80),
    categoria         VARCHAR(100),
    categoria_pai     VARCHAR(100),
    unidade_sigla     VARCHAR(10),
    unidade_descricao VARCHAR(80),
    custo_padrao      NUMERIC(12,2),
    preco_venda       NUMERIC(12,2),
    ativo             BOOLEAN
);

-- DIM_DEPOSITO
CREATE SEQUENCE dw.seq_dim_deposito START 1;

CREATE TABLE dw.dim_deposito (
    sk_deposito   INTEGER PRIMARY KEY DEFAULT nextval('dw.seq_dim_deposito'),
    nk_deposito   INTEGER NOT NULL UNIQUE,
    nome_deposito VARCHAR(120) NOT NULL,
    capacidade_m3 NUMERIC(10,2),
    nome_filial   VARCHAR(120),
    tipo_filial   VARCHAR(20),
    cidade        VARCHAR(120),
    uf            CHAR(2),
    nome_estado   VARCHAR(80),
    regiao        VARCHAR(30)
);

-- DIM_TIPO_MOVIMENTO
CREATE SEQUENCE dw.seq_dim_tipo_movimento START 1;

CREATE TABLE dw.dim_tipo_movimento (
    sk_tipo_movimento INTEGER PRIMARY KEY DEFAULT nextval('dw.seq_dim_tipo_movimento'),
    cd_tipo           VARCHAR(20) NOT NULL UNIQUE,  
    descricao         VARCHAR(60),
    origem            VARCHAR(30),                   
    fator_sinal       INTEGER NOT NULL               
);

-- DIM_LOTE
CREATE SEQUENCE dw.seq_dim_lote START 1;

CREATE TABLE dw.dim_lote (
    sk_lote         INTEGER PRIMARY KEY DEFAULT nextval('dw.seq_dim_lote'),
    nk_lote         INTEGER NOT NULL UNIQUE,
    numero_lote     VARCHAR(40),
    sku_produto     VARCHAR(30),
    data_fabricacao DATE,
    data_validade   DATE
);

INSERT INTO dw.dim_tempo VALUES (-1, NULL, NULL, NULL, 'Não informado', NULL, NULL, NULL, 'Não informado', 'N');
INSERT INTO dw.dim_produto (sk_produto, nk_produto, sku, nome_produto) VALUES (-1, -1, 'N/I', 'Não informado');
INSERT INTO dw.dim_deposito (sk_deposito, nk_deposito, nome_deposito) VALUES (-1, -1, 'Não informado');
INSERT INTO dw.dim_tipo_movimento (sk_tipo_movimento, cd_tipo, descricao, origem, fator_sinal) VALUES (-1, 'N/I', 'Não informado', 'Não informado', 0);
INSERT INTO dw.dim_lote (sk_lote, nk_lote, numero_lote) VALUES (-1, -1, 'Sem lote / lote inválido');

-- FATO_MOVIMENTO_ESTOQUE 1l
CREATE SEQUENCE dw.seq_fato_movimento_estoque START 1;

CREATE TABLE dw.fato_movimento_estoque (
    sk_fato_movimento      INTEGER PRIMARY KEY DEFAULT nextval('dw.seq_fato_movimento_estoque'),
    nk_movimento           INTEGER NOT NULL UNIQUE,  
    sk_tempo               INTEGER NOT NULL REFERENCES dw.dim_tempo(sk_tempo),
    sk_produto             INTEGER NOT NULL REFERENCES dw.dim_produto(sk_produto),
    sk_deposito            INTEGER NOT NULL REFERENCES dw.dim_deposito(sk_deposito),
    sk_tipo_movimento      INTEGER NOT NULL REFERENCES dw.dim_tipo_movimento(sk_tipo_movimento),
    sk_lote                INTEGER NOT NULL REFERENCES dw.dim_lote(sk_lote),
    data_hora_movimento    TIMESTAMP,
    nr_pedido_venda        INTEGER,                   
    nr_pedido_compra       INTEGER,                   
    fl_documento_cancelado CHAR(1),                   
    observacao             VARCHAR(250),
    quantidade             NUMERIC(12,3),             
    qtd_efeito_estoque     NUMERIC(12,3),             
    custo_unitario         NUMERIC(12,2),
    valor_total            NUMERIC(14,2),             
    valor_efeito_estoque   NUMERIC(14,2)              
);
