SELECT
	Lotes.LoteId,
	Lotes.LoteStr AS Lote,
	Lotes.DataCriacao,
	FORMAT(Lotes.DataCriacao, 'dd/MM/yyyy') AS [Data da Criação],
	FORMAT(CAST(Lotes.DataCriacao AS DATE), 'MM/yyyy') AS 'Início Vigência',
	'12/' + CAST(YEAR(Lotes.DataCriacao) AS VARCHAR) AS [Fim Vigência],
	COALESCE(Lancamento.CreditoM2, 0) AS 'Gerado',
	COALESCE(Lancamento.DebitoM2, 0) - COALESCE(Lancamento.Circulante, 0) AS 'Expurgo de M2',
	COALESCE(Lancamento.CreditoM2, 0) - COALESCE(Lancamento.DebitoM2, 0) AS 'Pendente de Venda',
	COALESCE(Lancamento.Circulante, 0) AS 'Vendas',
	COALESCE(Expurgado.ValorExpurgado, 0) AS Expurgos,
	COALESCE(Acesso.ValorAcesso, 0) AS 'Utilizados', 
	COALESCE(Lancamento.Circulante, 0) - COALESCE(Acesso.ValorAcesso, 0) AS 'Passivos'
FROM Lotes
LEFT JOIN (
	SELECT
		LoteId,
		SUM(DebitoM2) AS DebitoM2,
		SUM(CreditoM2) AS CreditoM2,
		SUM(Circulante) AS Circulante
	FROM vwLancamentosLotesMx
	GROUP BY LoteID
) Lancamento ON Lancamento.LoteID = Lotes.LoteID
LEFT JOIN (
	SELECT
		LoteId,
		SUM(ValorExpurgado) AS ValorExpurgado
	FROM vw_Lotes_Expurgados
	GROUP BY LoteId
) Expurgado ON Expurgado.LoteId = Lotes.loteId
LEFT JOIN (
	SELECT
		LoteID,
		SUM(ValorAcesso) AS ValorAcesso
	FROM vw_Lotes_DebidoMifareEmbarcado
	GROUP BY LoteID
) Acesso ON Acesso.loteId = Lotes.loteId
WHERE 
	Lotes.DataCriacao >= '2025-01-01'
