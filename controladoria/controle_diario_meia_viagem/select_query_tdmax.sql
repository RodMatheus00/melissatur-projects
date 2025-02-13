DECLARE @DataIni AS DATETIME;
DECLARE @DataFim AS DATETIME;

SET @DataIni = '2023-01-01';
SET @DataFim = GETDATE();

WITH A AS (
    SELECT
        T.TurnoID,
        V.Data,
		V.KM,
        C.Nome,
        L.Codigo,
        L.Nome AS NomeLinha,
        T.Prefixo,
		VT.Sentido,
		VT.Produtos,
        CASE
            WHEN T.Prefixo = '327' THEN 41
            WHEN T.Prefixo = '458' THEN 70
            WHEN T.Prefixo = '476' THEN 53
            WHEN T.Prefixo = '478' THEN 53
            WHEN T.Prefixo = '488' THEN 73
            WHEN T.Prefixo = '489' THEN 78
            WHEN T.Prefixo = '490' THEN 67
            WHEN T.Prefixo = '651' THEN 90
            WHEN T.Prefixo = '652' THEN 90
            WHEN T.Prefixo = '653' THEN 90
            WHEN T.Prefixo = '655' THEN 82
            WHEN T.Prefixo = '656' THEN 82
            WHEN T.Prefixo = '657' THEN 82
            WHEN T.Prefixo = '658' THEN 90
            WHEN T.Prefixo = '659' THEN 90
            WHEN T.Prefixo = '660' THEN 92
            WHEN T.Prefixo = '661' THEN 92
            WHEN T.Prefixo = '662' THEN 90
            WHEN T.Prefixo = '663' THEN 90
            WHEN T.Prefixo = '686' THEN 92
            WHEN T.Prefixo = '687' THEN 92
            WHEN T.Prefixo = '688' THEN 92
            WHEN T.Prefixo = '6206' THEN 80
            ELSE 0
        END AS Capacidade,
        T.Viagens,
		T.CatracaIni,
		T.CatracaFim,
        TT.Descricao,
        MIN(V.HorarioInicio) AS HoraIni,
        MAX(V.HorarioFim) AS HoraFim,
        V.TempoTrabalhado,
        SUM(VT.Creditos) AS Creditos
    FROM 
        Turnos T
    INNER JOIN (
        SELECT 
            V.TurnoID,
			V.KM,
            V.DataInicio,
            V.DataFim,
            CONVERT(DATE, V.DataInicio) AS Data,
            CONVERT(varchar(8), CONVERT(time, V.DataInicio), 108) AS HorarioInicio,
            CONVERT(varchar(8), CONVERT(time, V.DataFim), 108) AS HorarioFim,
            CONVERT(varchar(8), CONVERT(time, DATEADD(SECOND, DATEDIFF(SECOND, V.DataInicio, V.DataFim), 0)), 108) AS TempoTrabalhado
        FROM 
            Viagens V
    ) V ON V.TurnoID = T.TurnoID
    INNER JOIN 
        Cadastros C ON C.CadastroID = T.MotoristaID
    INNER JOIN
        Linhas L ON L.LinhaID = T.LinhaID
    INNER JOIN 
        TiposTurnos TT ON TT.TipoTurnoID = T.TipoTurnoID
    INNER JOIN (
        SELECT
    VT.TurnoID,
    VT.DataInicio,
    VT.DataFim,
    VT.Sentido,
    CASE
        WHEN Produto IN ('SENIOR 60', 'SENIOR 65', 'PcD.', 'PcD ACOMP') THEN 'Gratuitos'
        WHEN Produto = 'BC BUSS LIVRE EST' THEN 'Escolar'
        WHEN Produto = 'BC BUSS LIVRE' THEN 'Comum'
        WHEN Produto = 'Pagante - Urbano' THEN 'Pagantes'
        WHEN Produto = 'Funcionario' THEN 'Funcionario'
        WHEN Produto = 'Escolar' THEN 'Escolar'
        ELSE Produto
    END AS Produtos,
    SUM(COALESCE(VT.Creditos, 0)) AS Creditos
FROM 
    vwViagensTodas VT
GROUP BY
    VT.TurnoID,
    VT.DataInicio,
    VT.DataFim,
    VT.Sentido,
    VT.Produto) AS VT ON VT.TurnoID = T.TurnoID AND VT.DataInicio = V.DataInicio AND VT.DataFim = V.DataFim		
    WHERE 
        T.TurnoID != '1' 
        AND V.Data >= @DataIni
        AND V.Data != '2070-01-01'
        AND V.Data != '2030-07-15'
    GROUP BY
        T.TurnoID,
		V.KM,
        V.Data,
		VT.Produtos,
        V.TempoTrabalhado,
		T.CatracaIni,
		T.CatracaFim,
        C.Nome,
        L.Codigo,
        L.Nome,
		VT.Sentido,
        T.Prefixo,
        T.Viagens,
        TT.Descricao
),

B AS (
    SELECT
		A.TurnoID,
        A.Data,
        FORMAT(A.Data, 'dddd', 'pt-BR') AS 'Dia Tipo',
        CASE 
            WHEN DATEPART(WEEKDAY, A.Data) IN (1, 7) THEN 'Fim de Semana'
            ELSE 'Dia Útil'
        END AS Semana,
		MONTH(A.Data) AS Mês,
        YEAR(A.Data) AS Ano,
        CONCAT(A.Codigo, A.NomeLinha) AS Linha,
        A.Prefixo AS Carro,
        A.Capacidade,
        A.Viagens,
		CASE 
			WHEN A.Sentido = 'I' THEN 'PT1 - PT2'
			ELSE 'PT2 - PT1'
		END AS Pontos,
		CASE
			WHEN A.Sentido = 'I' THEN 'Ida'
			ELSE 'Volta'
		END AS Sentido,
        A.HoraIni,
        A.HoraFim,
		A.Produtos,
        A.TempoTrabalhado,
		A.KM,
        CASE
            WHEN A.Creditos IS NULL THEN 0 
            ELSE A.Creditos
        END AS Total,
		A.CatracaIni AS 'Catraca Inicial',
		A.CatracaFim as 'Catraca Final'
    FROM A
)

SELECT DISTINCT
	B.TurnoID,
	B.Data,
	B.[Dia Tipo],
	B.Semana,
	B.Mês,
	B.Ano,
	B.Linha,
	B.Carro,
	B.Capacidade,
	B.Viagens,
	B.Pontos,
	B.Sentido,
	LEFT(B.HoraIni, 2) AS Ínicio,
    CONCAT(SUBSTRING(B.HoraIni, 4, 2), ':', SUBSTRING(B.HoraIni, 7, 2)) AS Hora_2,
	B.HoraIni AS Hora_3,
	B.HoraFim AS Fim,
	B.TempoTrabalhado AS Tempo,
	B.KM,
	B.Total,
	FORMAT((CAST(B.Total AS FLOAT) / NULLIF(B.Capacidade, 0)) * 100, '0.00') + '%' AS Taxa,
	B.Total AS Equiv,
	B.Produtos,
	B.[Catraca Inicial],
	B.[Catraca Final]
FROM B
WHERE
	B.Data >= @DataIni;
