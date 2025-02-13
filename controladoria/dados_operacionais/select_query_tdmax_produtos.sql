DECLARE @Data AS DATE;
SET @Data = '2024-01-01';

SELECT 
    '27' AS Empresa,
	CONVERT(DATE, R.DataHoraAcesso) AS Data,
	MONTH(R.DataHoraAcesso) AS Mes,
	YEAR(R.DataHoraAcesso) AS Ano,
	CONVERT(VARCHAR(8), R.DataHoraAcesso, 108) AS Time,
	R.Codigo AS Codigo_Linha,
	R.Linha,
	R.Prefixo AS Veiculo,
	UPPER(R.Cobrador) AS Cobrador,
	UPPER(R.Nome) AS Usuario,
  R.Descricao AS Produto,
	1 AS Quantidade
FROM vwRel0402 R
WHERE R.DataHoraAcesso >= @Data