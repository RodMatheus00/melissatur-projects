SELECT
	T.LoteID AS 'Lote ID',
	FORMAT(L.DataCriacao, 'dd/MM/yyyy') AS [Data da Criação],
	T.LoteStr,
	Cadastros.Nome AS 'Usuário',
	CS.DocumentoFederal AS 'Documento',
	CS.SaldoTotal AS 'Saldo Atual',
	CS.UltimaTransacao,
	FORMAT(CS.UltimaTransacao, 'dd/MM/yyyy') AS [UltimaTransacao],
	CT.Descricao AS 'Produto',
	CASE WHEN CT.Descricao = 'Comum' THEN 1 ELSE 0 END AS 'Pagante',
	CASE WHEN CT.Descricao = 'Gratuito' THEN 1 ELSE 0 END AS 'Gratuitos',
	CASE WHEN CT.Descricao = 'Estudante' THEN 1 ELSE 0 END AS 'Estudante'
FROM vw_dbaCartoesSaldos CS
INNER JOIN Cadastros ON Cadastros.DocFederal = CS.DocumentoFederal
INNER JOIN CadastrosTipos CT ON CT.CadastroTipoID = Cadastros.CadastroTipoID
OUTER APPLY (
	SELECT TOP 1 
		CTT.LoteID,
		L.Lotestr,
		ISNULL(CONVERT(VARCHAR, L.DataCriacao, 120), 'Não possui') AS DataCriacao
	FROM CartoesTransacoes CTT
	LEFT JOIN Lotes L ON L.LoteID = CTT.LoteID
	WHERE CTT.CadastroID = Cadastros.CadastroID
	ORDER BY CTT.LoteID DESC
) T
INNER JOIN Lotes L ON L.loteId = T.LoteID
WHERE
	Cadastros.PerfilCompraID IS NOT NULL
	AND CT.CadastroTipoID IN ('1', '3', '5')
	AND CS.UltimaTransacao IS NOT NULL
        AND CS.UltimaTransacao >= '2025-01-01'
        AND T.DataCriacao >= '2025-01-01'