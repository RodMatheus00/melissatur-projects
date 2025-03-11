SELECT DISTINCT
	'Radsystem' AS SERVIDOR,
	UPPER(CONCAT(T.Estabelecimento, ' - ', P.Nome)) AS EMPRESA,
	CASE
		WHEN Pessoa.Nome IS NULL THEN T.DescricaoPessoa
		ELSE Pessoa.Nome
	END AS FORNECEDOR,
	T.DtVencimento AS DATA_VENCIMENTO,
	T.NumDocumento AS DOCUMENTO,
	T.Parcela AS PARCELA,
	T.Valor AS VALOR,
	CASE 
		WHEN Indi.Descricao = 'Liquidado' THEN T.Valor
		ELSE 0
	END AS PAGO,
	Indi.Descricao AS 'SITUACAO'
FROM Titulo T
INNER JOIN
	EspecieTitulo Esp ON Esp.OIDEspecieTitulo = T.OIDEspecieTitulo
INNER JOIN
	Portador Port ON Port.OIDPortador = T.OIDPortador
INNER JOIN
	FormaPagamento Form ON Form.OIDFormaPagamento = T.OIDFormaPagamento
INNER JOIN
	IndicativoSituacao Indi ON Indi.OIDIndicativoSituacao = T.OIDIndicativoSituacao
LEFT JOIN
	Pessoa ON Pessoa.OIDPessoa = T.OIDPessoa
INNER JOIN
	Estabelecimento E ON E.Codigo = T.Estabelecimento
INNER JOIN
	Pessoa P ON P.OIDPessoa = E.OIDPessoa
WHERE 
	T.Estabelecimento IN ('5', '26', '2', '29', '18', '14', '12', '11', '28', '23', '27', '3', '17')
    AND Indi.Descricao IN ('Aguardando Liberação', 'Liberado', 'Aguardando Pagamento ao Fornecedor', 'Liquidado')
	AND Esp.Descricao IN ('Titulo a Pagar')
	AND DtVencimento IS NOT NULL