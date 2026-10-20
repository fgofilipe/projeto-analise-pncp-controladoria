-- Criação das Tabelas de Dimensão (Devem ser criadas primeiro devido às Chaves Estrangeiras)

CREATE TABLE dim_orgao (
    sk_orgao INT PRIMARY KEY,
    cnpj_orgao VARCHAR(20) UNIQUE NOT NULL,
    nome_orgao VARCHAR(255),
    poder VARCHAR(50)
);

CREATE TABLE dim_fornecedor (
    sk_fornecedor INT PRIMARY KEY,
    ni_fornecedor VARCHAR(20) UNIQUE NOT NULL,
    nome_fornecedor VARCHAR(255),
    tipo_pessoa VARCHAR(10),
    porte VARCHAR(100)
);

CREATE TABLE dim_modalidade (
    sk_modalidade INT PRIMARY KEY,
    modalidade_id INT UNIQUE NOT NULL,
    nome_modalidade VARCHAR(100)
);

CREATE TABLE dim_localidade (
    sk_localidade INT PRIMARY KEY,
    uf_sigla VARCHAR(2) UNIQUE NOT NULL,
    uf_nome VARCHAR(100),
    regiao VARCHAR(50)
);

-- Criação da Tabela Facto

CREATE TABLE fato_item_contratado (
    sk_fato SERIAL PRIMARY KEY,
    numero_controle_pncp VARCHAR(50) NOT NULL,
    numero_item INT NOT NULL,
    sk_orgao INT REFERENCES dim_orgao(sk_orgao),
    sk_fornecedor INT REFERENCES dim_fornecedor(sk_fornecedor),
    sk_modalidade INT REFERENCES dim_modalidade(sk_modalidade),
    sk_localidade INT REFERENCES dim_localidade(sk_localidade),
    data_publicacao DATE,
    data_homologacao DATE,
    descricao_item TEXT,
    perfil_gasto VARCHAR(50),
    quantidade DECIMAL(18,4) CHECK (quantidade > 0),
    valor_unitario_estimado DECIMAL(18,4),
    valor_unitario_homologado DECIMAL(18,4) CHECK (valor_unitario_homologado >= 0),
    valor_total_estimado DECIMAL(18,2),
    valor_total_homologado DECIMAL(18,2) CHECK (valor_total_homologado >= 0),
    comparavel SMALLINT,
    economia_valor DECIMAL(18,2),
    dias_ciclo INT,
    UNIQUE (numero_controle_pncp, numero_item)
);