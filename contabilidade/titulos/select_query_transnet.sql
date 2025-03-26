SELECT 
    'Transnet' AS Servidor,
    CP.ID_EMPRESA || ' - ' || E.NM_EMPRESA AS Empresa,
    TE_RAZAO_SOCIAL AS Fornecedor,
    CP.DT_VENCIMENTO AS Data_Vencimento,
    CP.NR_DOCUMENTO AS Documento,
    CP.NR_PARCELA AS Parcela,
    CP.VL_PAGO AS Pago,
    CP.VL_DOCUMENTO - CP.VL_DESCONTO AS Valor,
    CASE
        WHEN CP.CS_SITUACAO = 'R' THEN 'Liberado'
        WHEN CP.CS_SITUACAO = 'P' THEN 'Aguardando Liberação'
        WHEN CP.CS_SITUACAO = 'S' THEN 'Liquidado'
        ELSE CP.CS_SITUACAO
    END AS Situacao
FROM grupogem.contas_a_pagar CP
INNER JOIN
    grupogem.FORNECEDORES F ON F.ID_FORNECEDOR = CP.ID_FORNECEDOR
INNER JOIN
    grupogem.TIPOS_DOCUMENTO TD ON TD.ID_TIPO_DOCUMENTO = CP.ID_TIPO_DOCUMENTO
INNER JOIN
    grupogem.EMPRESAS E ON E.ID_EMPRESA = CP.ID_EMPRESA
WHERE  
    CP.CS_SITUACAO != 'B'

