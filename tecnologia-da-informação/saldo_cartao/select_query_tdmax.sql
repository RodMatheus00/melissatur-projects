WITH Subconsulta AS (
SELECT
	Cadastros.Nome,
	Cadastros.CartaoEntregue,
	CS.DocumentoFederal,
	CS.SaldoTotal,
	CS.UltimaTransacao,
	CT.Descricao,
	CASE 
		WHEN CT.Descricao = 'Comum' THEN 1
		ELSE 0
	END AS 'Pagante',
	CASE 
		WHEN CT.Descricao = 'Gratuito' THEN 1
		ELSE 0
	END AS 'Gratuitos',
	CASE
		WHEN CT.Descricao = 'Estudante' THEN 1
		ELSE 0
	END AS 'Estudante'
FROM vw_dbaCartoesSaldos CS
INNER JOIN
	Cadastros ON Cadastros.DocFederal = CS.DocumentoFederal
INNER JOIN
	CadastrosTipos CT ON CT.CadastroTipoID = Cadastros.CadastroTipoID
WHERE
	PerfilCompraID IS NOT NULL
	AND CT.CadastroTipoID IN ('1', '3', '5')
	AND CS.UltimaTransacao IS NOT NULL)

SELECT 
	SUM(Pagante) AS Pagante,
	SUM(Gratuitos) AS Gratuitos,
	SUM(Estudante) AS Estudante
FROM Subconsulta


