SELECT
    '10' AS Numero_Empresa,  
'Expresso Presidente - Mafra' AS Empresa,
    CONVERT(DATE, VA.Data) AS Data,
    FORMAT(VA.Data, 'HH:mm:ss') AS Horario,
    VA.Valor AS QTD_Anomalias,
    VA.Descricao,
    T.Prefixo,
    C.Nome AS Nome_Motorista,
    L.Codigo,
    L.Nome,
    T.DataIni,
    T.DataFim,
    A.Descricao
FROM viagens_anomalias VA
INNER JOIN Turnos T ON T.TurnoID = VA.TurnoId 
INNER JOIN Linhas L ON L.LinhaID = T.LinhaID
INNER JOIN Cadastros C ON C.CadastroID = T.MotoristaID
JOIN anomalias A ON A.AnomaliaId = VA.AnomaliaId
WHERE (VA.AnomaliaId = '2' OR VA.AnomaliaId = '7') AND VA.Data >= '20230101';
