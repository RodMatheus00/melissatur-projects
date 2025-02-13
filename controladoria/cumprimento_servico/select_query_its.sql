SET LANGUAGE 'Portuguese';

WITH A AS (
    SELECT
		CONVERT(date, CS.FimRealizado) AS 'Data',
        CS.FimPrevisto,
        CS.FimRealizado,
        CS.IdLinha,
        CS.Sentido,
        CS.Motorista,
        L.Numero,
        L.Nome,
        C.Prefixo,
        CS.IdTurno,
        CS.IdCarro,
        CS.Viagem,
        CS.InicioPrevisto AS IP,
        CS.InicioRealizado AS IR,
        CS.FimPrevisto AS FP,
        CS.FimRealizado AS FR,
        CS.IdTrajeto,
        CS.IdPI,
        P.Descricao AS 'Ponto Inicial',
        CS.IdPF,
        CS.KmProgramado,
        TM.IdMotorista,
        F.Nome AS 'MotoristaNome'
    FROM CumprimentoServico CS
    INNER JOIN Pontos P ON P.Id = CS.IdPI
    INNER JOIN Carros C ON C.Id = CS.IdCarro
    INNER JOIN Linhas L ON L.Id = CS.IdLinha
    INNER JOIN itsTurnosMotoristas TM ON TM.IdTurno = CS.IdTurno AND TM.IdCarro = CS.IdCarro
    INNER JOIN Funcionarios F ON F.Id = TM.IdMotorista
)

SELECT 
	A.Data,
    DATENAME(dw, CONVERT(date, A.FR)) AS 'Dia da Semana',
    FORMAT(CONVERT(date, A.FR), 'dd/MM/yyyy') AS 'Data Tabela', 
    A.Numero AS 'Linha',
    A.Viagem,
    CASE 
        WHEN Sentido = '1' THEN 'IDA' 
        ELSE 'VOLTA'
    END AS 'Sentido',
    CONVERT(varchar, A.IP, 8) AS IP,
    CONVERT(varchar, A.IR, 8) AS IR,
    CASE
        WHEN IP < DATEADD(MINUTE, -5, IR) THEN 'Atrasado' 
        WHEN IP > DATEADD(MINUTE, 5, IR) THEN 'Adiantado'
        ELSE 'No horário'
    END AS 'Serviço Inicio',
    CASE
        WHEN (CASE WHEN IP < DATEADD(MINUTE, -5, IR) THEN 'Atrasado' WHEN IP > DATEADD(MINUTE, 5, IR) THEN 'Adiantado' ELSE 'No horário' END) = 'Adiantado' THEN 1
        ELSE 0 
    END AS 'Inicio Adiantado',
    CASE
        WHEN (CASE WHEN IP < DATEADD(MINUTE, -5, IR) THEN 'Atrasado' WHEN IP > DATEADD(MINUTE, 5, IR) THEN 'Adiantado' ELSE 'No horário' END) = 'Atrasado' THEN 1
        ELSE 0 
    END AS 'Inicio Atrasado',
    CASE
        WHEN (CASE WHEN IP < DATEADD(MINUTE, -5, IR) THEN 'Atrasado' WHEN IP > DATEADD(MINUTE, 5, IR) THEN 'Adiantado' ELSE 'No horário' END) = 'No horário' THEN 1
        ELSE 0 
    END AS 'Inicio Dentro do Horário',
    CONVERT(varchar, A.FP, 8) AS FP,
    CONVERT(varchar, A.FR, 8) AS FR,
    CASE
        WHEN FP < DATEADD(MINUTE, -5, FR) THEN 'Atrasado' 
        WHEN FP > DATEADD(MINUTE, 5, FR) THEN 'Adiantado'
        ELSE 'No horário'
    END AS 'Serviço Fim',
    CASE
        WHEN (CASE WHEN FP < DATEADD(MINUTE, -5, FR) THEN 'Atrasado' WHEN FP > DATEADD(MINUTE, 1, FR) THEN 'Adiantado' ELSE 'No horário' END) = 'Adiantado' THEN 1
        ELSE 0 
    END AS 'Fim Adiantado',
    CASE
        WHEN (CASE WHEN FP < DATEADD(MINUTE, -5, FR) THEN 'Atrasado' WHEN FP > DATEADD(MINUTE, 1, FR) THEN 'Adiantado' ELSE 'No horário' END) = 'Atrasado' THEN 1
        ELSE 0 
    END AS 'Fim Atrasado',
    CASE
        WHEN (CASE WHEN FP < DATEADD(MINUTE, -5, FR) THEN 'Atrasado' WHEN FP > DATEADD(MINUTE, 1, FR) THEN 'Adiantado' ELSE 'No horário' END) = 'No horário' THEN 1
        ELSE 0 
    END AS 'Fim Dentro do Horário',
    A.Prefixo,
    A.[Ponto Inicial],
    P.Descricao AS 'PontoFinal',
    CONCAT(A.Numero, ' - ', A.Nome) AS 'Trajeto',
    A.MotoristaNome,
    1 AS 'Contagem Viagens'
FROM A
INNER JOIN Pontos P ON P.Id = A.IdPF
WHERE Data >= '20231101'
ORDER BY IP;
