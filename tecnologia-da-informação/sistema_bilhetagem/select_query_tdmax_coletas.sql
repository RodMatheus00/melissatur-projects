DECLARE @Data AS DATE;
SET @Data = DATEADD(day, -5, GETDATE());

WITH A AS(
    SELECT 
        S.Prefixo,
        S.Data,
        GETDATE() AS Data_Atual,
        CONVERT(DATE, S.Data) AS Data_Ultima_Coleta,
        FORMAT(S.Data, 'HH:mm:ss') AS Hora_Ultima_Coleta
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY Prefixo ORDER BY Data DESC) AS rn
        FROM historicoColetas
        WHERE Data >= @Data
    ) AS S
    WHERE S.rn = 1
)

SELECT
    '007' AS Numero_Empresa,
    'Melissatur Campo Mourão' AS Empresa,
    A.Prefixo,
    A.Data_Ultima_Coleta,
    A.Hora_Ultima_Coleta,
    SUM(DATEDIFF(HOUR, A.Data, A.Data_Atual)) AS Tempo_Sem_Coletar_Horas
FROM A
GROUP BY
    A.Prefixo,
    A.Data_Ultima_Coleta,
    A.Hora_Ultima_Coleta

-- Anomalias TDMAX
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
