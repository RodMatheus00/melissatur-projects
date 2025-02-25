SELECT 
    CP.ID_EMPRESA AS Empresa,
    CP.DT_VENCIMENTO AS Data_Vencimento,
    TE_RAZAO_SOCIAL AS Fornecedor,
    CP.NR_DOCUMENTO AS Documento,
    CP.NR_PARCELA AS Parcela,
    TD.DS_DOCUMENTO AS Modelo_Documento,
    CASE
        WHEN CP.CS_SITUACAO = 'R' THEN 'Confirmado'
        WHEN CP.CS_SITUACAO = 'P' THEN 'Previsto'
        WHEN CP.CS_SITUACAO = 'S' THEN 'Pago'
        ELSE CP.CS_SITUACAO
    END AS Situacao,
    CP.VL_DOCUMENTO AS Valor,
    CP.VL_MULTA AS Valor_Multa,
    CP.VL_JUROS AS Valor_Juros,
    CP.VL_DESCONTO AS Valor_Desconto,
    CP.VL_PAGO AS Pago
FROM grupogem.contas_a_pagar CP
INNER JOIN
    grupogem.FORNECEDORES F ON F.ID_FORNECEDOR = CP.ID_FORNECEDOR
INNER JOIN
    grupogem.TIPOS_DOCUMENTO TD ON TD.ID_TIPO_DOCUMENTO = CP.ID_TIPO_DOCUMENTO
WHERE 
    CP.DT_VENCIMENTO >= TO_DATE('2025-01-01', 'YYYY-MM-DD')

