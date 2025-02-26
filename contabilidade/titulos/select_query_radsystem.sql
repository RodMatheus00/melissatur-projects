SELECT DISTINCT
	T.OIDTitulo,
	T.Estabelecimento,
	CONCAT(T.Empresa, '/', T.Estabelecimento) AS 'Emp/Est',
	Esp.Descricao AS EspecieTitulo,
	CASE
		WHEN Pessoa.Nome IS NULL THEN T.DescricaoPessoa
		ELSE Pessoa.Nome
	END AS Pessoa,
	T.DtEmissao,
	T.DtVencimento,
	T.NumDocumento AS Documento,
	T.Parcela,
	T.Valor,
	T.ValorSaldo AS Pagar,
	Port.Descricao AS Portador,
	T.DtPrevQuitacao,
	Indi.Descricao AS 'Situação'
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
WHERE 
    T.DtVencimento >= '2025-01-01'
    AND T.Estabelecimento IN ('5', '26', '2', '29', '18', '14', '12', '11', '28', '23', '27', '3', '17')
    AND Indi.Descricao IN ('Aguardando Liberação', 'Liberado', 'Aguardando Pagamento ao Fornecedor')
	AND Esp.Descricao IN ('Titulo a Pagar', 'Adiantamento a Fornecedores')