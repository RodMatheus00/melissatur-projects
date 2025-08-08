WITH A AS (
    SELECT 
        Contas.ID_Empresa,
        Contas.ID_FORNECEDOR,
        Contas.NR_DOCUMENTO,
        Contas.DT_EMISSAO,
        Contas.DT_PREVISAO_PAGAMENTO,
        Contas.NR_PARCELA,
        Contas.VL_DOCUMENTO,
        Contas.NR_TRANSACAO,
        Contas.DT_CADASTRO,
        Contas.DT_VENCIMENTO_DESCONTO,
        Contas.ID_CONDICAO_PAGAMENTO,
        Contas.VL_PAGO
    FROM grupogem.CONTAS_A_PAGAR Contas
    WHERE Contas.NR_DOCUMENTO = '871475'
),
ConsultaFinal AS (
    SELECT
        NR_DOCUMENTO,
        MAX(ID_EMPRESA)    AS ID_EMPRESA,
        MAX(ID_FORNECEDOR) AS ID_FORNECEDOR,
        (SELECT X.NR_PARCELA
         FROM A X
         ORDER BY X.DT_PREVISAO_PAGAMENTO DESC
         FETCH FIRST 1 ROW ONLY) AS Parcela,
        (SELECT X.NR_PARCELA
         FROM A X
         WHERE X.VL_PAGO > 0
         ORDER BY X.DT_PREVISAO_PAGAMENTO DESC
         FETCH FIRST 1 ROW ONLY) AS Parcelas_Pagas,
        MIN(DT_PREVISAO_PAGAMENTO) KEEP (DENSE_RANK FIRST ORDER BY DT_PREVISAO_PAGAMENTO) AS Data_Proximo_Vencimento,
        (SELECT MAX(X.DT_PREVISAO_PAGAMENTO)
         FROM A X
         WHERE X.VL_PAGO = 0) AS Data_Encerramento,
        (SELECT MAX(X.DT_PREVISAO_PAGAMENTO)
         FROM A X
         WHERE X.VL_PAGO > 0) AS Data_Ultimo_Pagamento,
        SUM(VL_DOCUMENTO) AS Valor_Documento,
        SUM(VL_PAGO) AS Valor_Pago
    FROM A
    GROUP BY NR_DOCUMENTO
)
SELECT 
    'TRANSNET' AS "Servidor",
    E.NR_INTERNO_EMPRESA AS "Codigo Empresa",
    E.NM_EMPRESA AS "Estabelecimento",
    F.TE_RAZAO_SOCIAL AS "Bancos",
    C.NR_DOCUMENTO AS "Numero Documento",
    C.Parcela AS "Quantidade de Parcelas",
    C.Parcelas_Pagas AS "Quantidade de Parcelas Pagas",
    (C.Parcela - C.Parcelas_Pagas) AS "Quantidade de Parcelas Pendentes",
    C.Data_Encerramento AS "Data Encerramento",
    C.Data_Proximo_Vencimento AS "Data Vencimento",
    C.Data_Ultimo_Pagamento AS "Data Pagamento",
    C.Valor_Pago AS "Valor Pago",
    (C.Valor_Documento - C.Valor_Pago) AS "Valor Devedor",
    C.Valor_Documento AS "Valor Total",
    CASE 
        WHEN C.Valor_Pago >= C.Valor_Documento THEN 'Quitado'
        ELSE 'Pendente'
    END AS Situacao_Conta
FROM ConsultaFinal C
INNER JOIN grupogem.Fornecedores F 
    ON F.ID_FORNECEDOR = C.ID_FORNECEDOR
INNER JOIN grupogem.Empresas E
    ON E.ID_EMPRESA = C.ID_EMPRESA