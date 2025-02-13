DECLARE @DataIni AS DATE;
DECLARE @DataFim AS DATE;

SET @DataIni = '2023-01-01'
SET @DataFim = GETDATE();

WITH A AS (
SELECT
	CONVERT(DATE, R.Data_Turno) AS Data,
	R.Codigo,
	R.Linha,
	R.Prefixo,
	R.Cobrador AS Motorista,
	R.Nome AS Usuario,
	R.Descricao AS Produto,
	1 AS Quantidade
FROM vwRel0402 R
WHERE Descricao = 'Gratuitos'),

B AS(
SELECT 
	A.Data,
	A.Codigo,
	A.Linha,
	A.Prefixo,
	A.Motorista,
	A.Usuario,
	SUM(A.Quantidade) AS Uso
FROM A
WHERE Data >= @DataIni
GROUP BY
	A.Data,
	A.Codigo,
	A.Linha,
	A.Prefixo,
	A.Motorista,
	A.Usuario)

SELECT DISTINCT
	'008' AS Numero,
	'Expresso Presidente - Gaspar' AS Empresa,
	*,
	CASE
		WHEN Uso <= 5 THEN 'Normal'
		ELSE 'Alerta'
	END AS Situação
FROM B;
