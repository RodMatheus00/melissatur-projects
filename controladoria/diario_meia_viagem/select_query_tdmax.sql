
-- Detalhes TDMAX
  SELECT
        T.TurnoID,
        V.Data,
        C.Nome,
        L.Codigo,
        L.Nome AS NomeLinha,
        T.Prefixo,
        T.Viagens,
        TT.Descricao,
        MIN(V.HorarioInicio) AS HoraIni,
        MAX(V.HorarioFim) AS HoraFim,
		V.TempoTrabalhado
    FROM 
        Turnos T
    INNER JOIN (
        SELECT 
            V.TurnoID,    
            CONVERT(DATE, V.DataInicio) AS Data,
            CONVERT(varchar(8), CONVERT(time, V.DataInicio), 108) AS HorarioInicio,
            CONVERT(varchar(8), CONVERT(time, V.DataFim), 108) AS HorarioFim,
            CONVERT(varchar(8), CONVERT(time, DATEADD(SECOND, DATEDIFF(SECOND, DataInicio, V.DataFim), 0)), 108) AS TempoTrabalhado
        FROM 
            Viagens V) V ON V.TurnoID = T.TurnoID
    INNER JOIN 
        Cadastros C ON C.CadastroID = T.MotoristaID
    INNER JOIN
        Linhas L ON L.LinhaID = T.LinhaID
    INNER JOIN 
        TiposTurnos TT ON TT.TipoTurnoID = T.TipoTurnoID
    WHERE 
		T.TurnoID != '1' 
		AND V.Data >= '20230101' 
		AND V.Data != '2070-01-01'
		AND V.Data != '2030-07-15'
    GROUP BY
        T.TurnoID,
        V.Data,
		V.TempoTrabalhado,
        C.Nome,
        L.Codigo,
        L.Nome,
        T.Prefixo,
        T.Viagens,
        TT.Descricao
	ORDER BY
		Data DESC;

    -- RESUMO TDMAX
    WITH A AS (
    SELECT
        V.Data,
        C.Nome,
        MIN(V.HorarioInicio) AS HoraIni,
        MAX(V.HorarioFim) AS HoraFim,
        SUM(DATEDIFF(SECOND, '00:00:00', V.TempoTrabalhado)) AS TempoTrabalhadoSeconds,
        DATEDIFF(SECOND, MIN(V.HorarioInicio), MAX(V.HorarioFim)) AS TempoTotalSeconds
    FROM 
        Turnos T
    INNER JOIN (
        SELECT 
            V.TurnoID,    
            CONVERT(DATE, V.DataInicio) AS Data,
            CONVERT(varchar(8), CONVERT(time, V.DataInicio), 108) AS HorarioInicio,
            CONVERT(varchar(8), CONVERT(time, V.DataFim), 108) AS HorarioFim,
            CONVERT(varchar(8), CONVERT(time, DATEADD(SECOND, DATEDIFF(SECOND, DataInicio, V.DataFim), 0)), 108) AS TempoTrabalhado
        FROM 
            Viagens V
    ) V ON V.TurnoID = T.TurnoID
    INNER JOIN 
        Cadastros C ON C.CadastroID = T.MotoristaID
    INNER JOIN
        Linhas L ON L.LinhaID = T.LinhaID
    GROUP BY
        V.Data,
        C.Nome
)

SELECT 
    Data,
    Nome,
    HoraIni,
    HoraFim,
    CONVERT(VARCHAR, (TempoTotalSeconds / 3600)) + ':' +
    RIGHT('0' + CONVERT(VARCHAR, ((TempoTotalSeconds % 3600) / 60)), 2) + ':' +
    RIGHT('0' + CONVERT(VARCHAR, (TempoTotalSeconds % 60)), 2) AS TempoTotal,
    CONVERT(VARCHAR, (TempoTrabalhadoSeconds / 3600)) + ':' +
    RIGHT('0' + CONVERT(VARCHAR, ((TempoTrabalhadoSeconds % 3600) / 60)), 2) + ':' +
    RIGHT('0' + CONVERT(VARCHAR, (TempoTrabalhadoSeconds % 60)), 2) AS TempoTrabalhado,
    CONVERT(VARCHAR, ((TempoTotalSeconds - TempoTrabalhadoSeconds) / 3600)) + ':' +
    RIGHT('0' + CONVERT(VARCHAR, ((TempoTotalSeconds - TempoTrabalhadoSeconds) % 3600 / 60)), 2) + ':' +
    RIGHT('0' + CONVERT(VARCHAR, ((TempoTotalSeconds - TempoTrabalhadoSeconds) % 60)), 2) AS DiferencaTempo,
    CASE 
        WHEN TempoTotalSeconds > 0 THEN FORMAT((CAST(TempoTotalSeconds - TempoTrabalhadoSeconds AS FLOAT) / TempoTotalSeconds) * 100, 'N2') + '%'
        ELSE 'N/A'
    END AS PorcentagemDiferenca
FROM A
WHERE 
    Data >= '2023-01-01'
    AND Data != '2070-01-01'
    AND Data != '2030-07-15'
ORDER BY
    Data DESC;
