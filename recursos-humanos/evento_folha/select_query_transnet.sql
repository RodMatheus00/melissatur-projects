SELECT
    Folha.DT_PAGAMENTO,
    DS_FOLHA,
    EXTRACT(YEAR FROM Folha.DT_PAGAMENTO) AS Ano,
    UPPER(TO_CHAR(Folha.DT_PAGAMENTO, 'FMMonth', 'NLS_DATE_LANGUAGE=PORTUGUESE')) AS Mes,
    Func.DT_INICIO_ATIVIDADE AS Data_Admissão,
    Func.ID_EMPRESA,
    Func.NM_FUNCIONARIO,
    Func.NR_IDENTIDADE,
    Func.NR_CRACHA,
    Eventos.CD_EVENTO_FOLHA,
    CF.VL_EVENTO,
    CF.QT_EVENTO_EDITADO
FROM grupogem.CALCULOS_FOLHA CF
INNER JOIN
    grupogem.Folhas_Pagamento Folha ON Folha.ID_FOLHA = CF.ID_FOLHA
INNER JOIN
    grupogem.Eventos_folha Eventos ON Eventos.ID_EVENTO_FOLHA = CF.ID_EVENTO_FOLHA
INNER JOIN
    grupogem.Funcionarios Func ON Func.ID_FUNCIONARIO = CF.ID_FUNCIONARIO
WHERE 
    Eventos.CD_EVENTO_FOLHA IN ('0002', '0015', '0019', '82', '0052', '0005', '0006', '0025', '0026', '0032', '0033', '0502', '0610', '5164', '5169', '5170', '5176', '5177', '5242', '5243', '5245', '5260')
    AND Folha.DT_PAGAMENTO >= TO_DATE('2025-01-01', 'YYYY-MM-DD')
    AND Folha.ID_FOLHA_PAGAMENTO = '1'