-- ============================================================================
-- SCRIPT DE CONSULTAS: 6 PERGUNTAS DE NEGÓCIO DA CONTROLADORIA
-- ============================================================================

-- ----------------------------------------------------------------------------
-- PERGUNTA 1: Economia global do Poder Público
-- Qual é o percentual e o valor financeiro nominal economizado pelo governo?
-- ----------------------------------------------------------------------------
SELECT
    SUM(CASE WHEN comparavel = 1 THEN valor_total_estimado ELSE 0 END) AS valor_estimado_comparavel,
    SUM(valor_total_homologado) AS volume_homologado,
    SUM(economia_valor) AS economia_nominal,
    ROUND(
        (SUM(economia_valor) / NULLIF(SUM(CASE WHEN comparavel = 1 THEN valor_total_estimado ELSE 0 END), 0)) * 100,
        2
    ) AS economia_percentual
FROM fato_item_contratado;


-- ----------------------------------------------------------------------------
-- PERGUNTA 2: Concentração e risco de fornecedores
-- Quem são os 10 maiores fornecedores em volume e qual % do orçamento concentram?
-- ----------------------------------------------------------------------------
SELECT
    f.ni_fornecedor,
    f.nome_fornecedor,
    SUM(fato.valor_total_homologado) AS volume_homologado,
    ROUND(
        (SUM(fato.valor_total_homologado) / (SELECT SUM(valor_total_homologado) FROM fato_item_contratado)) * 100,
        2
    ) AS participacao_percentual
FROM fato_item_contratado fato
JOIN dim_fornecedor f ON fato.sk_fornecedor = f.sk_fornecedor
GROUP BY f.ni_fornecedor, f.nome_fornecedor
ORDER BY volume_homologado DESC
LIMIT 10;


-- ----------------------------------------------------------------------------
-- PERGUNTA 3: Eficácia por modalidade
-- Quais modalidades trazem maior economia e quais concentram o maior volume?
-- ----------------------------------------------------------------------------
SELECT
    m.nome_modalidade,
    SUM(fato.valor_total_homologado) AS volume_homologado,
    ROUND(
        (SUM(fato.valor_total_homologado) / (SELECT SUM(valor_total_homologado) FROM fato_item_contratado)) * 100,
        2
    ) AS participacao_volume_percentual,
    SUM(fato.economia_valor) AS economia_nominal,
    ROUND(
        (SUM(fato.economia_valor) / NULLIF(SUM(CASE WHEN fato.comparavel = 1 THEN fato.valor_total_estimado ELSE 0 END), 0)) * 100,
        2
    ) AS economia_percentual
FROM fato_item_contratado fato
JOIN dim_modalidade m ON fato.sk_modalidade = m.sk_modalidade
GROUP BY m.modalidade_id, m.nome_modalidade
ORDER BY volume_homologado DESC;


-- ----------------------------------------------------------------------------
-- PERGUNTA 4: Tempo do ciclo de compras
-- Duração média (em dias) entre edital e homologação, por órgão (min. 5 itens com ciclo)
-- ----------------------------------------------------------------------------
SELECT
    o.nome_orgao,
    COUNT(fato.dias_ciclo) AS qtd_itens_com_ciclo,
    COUNT(DISTINCT o.cnpj_orgao) AS qtd_unidades_compradoras,
    ROUND(AVG(fato.dias_ciclo), 1) AS ciclo_medio_dias,
    MAX(fato.dias_ciclo) AS ciclo_maximo_dias
FROM fato_item_contratado fato
JOIN dim_orgao o ON fato.sk_orgao = o.sk_orgao
WHERE fato.dias_ciclo IS NOT NULL
GROUP BY o.nome_orgao
HAVING COUNT(fato.dias_ciclo) >= 5
ORDER BY ciclo_medio_dias DESC;


-- ----------------------------------------------------------------------------
-- PERGUNTA 5: Distribuição regional
-- Despesas e indicadores de desconto por Região e Estado
-- ----------------------------------------------------------------------------
-- 5a. Por Região
SELECT
    l.regiao,
    SUM(fato.valor_total_homologado) AS volume_homologado,
    ROUND(
        (SUM(fato.valor_total_homologado) / (SELECT SUM(valor_total_homologado) FROM fato_item_contratado)) * 100,
        2
    ) AS participacao_volume_percentual,
    ROUND(
        (SUM(fato.economia_valor) / NULLIF(SUM(CASE WHEN fato.comparavel = 1 THEN fato.valor_total_estimado ELSE 0 END), 0)) * 100,
        2
    ) AS economia_percentual
FROM fato_item_contratado fato
JOIN dim_localidade l ON fato.sk_localidade = l.sk_localidade
GROUP BY l.regiao
ORDER BY volume_homologado DESC;

-- 5b. Por UF (Estado)
SELECT
    l.uf_sigla,
    l.uf_nome,
    l.regiao,
    SUM(fato.valor_total_homologado) AS volume_homologado,
    ROUND(
        (SUM(fato.economia_valor) / NULLIF(SUM(CASE WHEN fato.comparavel = 1 THEN fato.valor_total_estimado ELSE 0 END), 0)) * 100,
        2
    ) AS economia_percentual
FROM fato_item_contratado fato
JOIN dim_localidade l ON fato.sk_localidade = l.sk_localidade
GROUP BY l.uf_sigla, l.uf_nome, l.regiao
ORDER BY volume_homologado DESC;


-- ----------------------------------------------------------------------------
-- PERGUNTA 6: Perfil dos gastos
-- Distribuição de recursos entre Bens, Serviços e Obras e engenharia
-- ----------------------------------------------------------------------------
SELECT
    perfil_gasto,
    COUNT(*) AS qtd_itens,
    SUM(valor_total_homologado) AS volume_homologado,
    ROUND(
        (SUM(valor_total_homologado) / (SELECT SUM(valor_total_homologado) FROM fato_item_contratado)) * 100,
        2
    ) AS participacao_volume_percentual,
    ROUND(
        (SUM(economia_valor) / NULLIF(SUM(CASE WHEN comparavel = 1 THEN valor_total_estimado ELSE 0 END), 0)) * 100,
        2
    ) AS economia_percentual
FROM fato_item_contratado
GROUP BY perfil_gasto
ORDER BY volume_homologado DESC;