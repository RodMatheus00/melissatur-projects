WITH A AS (
    SELECT
        T.OIDDocumento,
        1 AS Quantidade,
        P.Nome,
        B.Descricao AS [Bem],
        T.NumDocumento,
        T.Estabelecimento,
        T.Valor,
        T.ValorSaldo,
        T.DtVencimento,
        T.DtSituacao
    FROM
        Titulo T
        LEFT JOIN Pessoa P ON P.OIDPessoa = T.OIDPessoa
        LEFT JOIN Bem B ON B.OIDBem = T.OIDBem
)

SELECT 
	'RS1' AS Servidor,
    Estabelecimento.Codigo AS [Codigo Empresa],
    Estabelecimento.Nome AS [Estabelecimento],
    A.Nome as 'Bancos',
    A.NumDocumento AS [Numero Documento],
    SUM(A.Quantidade) AS [Quantidade de Parcelas],
    SUM(CASE WHEN A.ValorSaldo = 0 THEN A.Quantidade ELSE 0 END) AS [Quantidade de Parcelas Pagas],
    SUM(A.Quantidade) - SUM(CASE WHEN A.ValorSaldo = 0 THEN A.Quantidade ELSE 0 END) AS [Quantidade de Parcelas Pendentes],
    UPPER(FORMAT(MAX(A.DtVencimento), 'MMMM/yyyy', 'pt-br')) AS [Data Encerramento],

    (
        SELECT TOP 1 CONVERT(date, X.DtVencimento)
        FROM A X
        WHERE
            X.NumDocumento = A.NumDocumento
            AND X.ValorSaldo = 0
        ORDER BY
            X.DtVencimento DESC
    ) AS [Data Vencimento],

    (
        SELECT TOP 1 CONVERT(date, X.DtSituacao)
        FROM A X
        WHERE
            X.NumDocumento = A.NumDocumento
            AND X.ValorSaldo = 0
        ORDER BY
            X.DtVencimento DESC
    ) AS [Data Pagamento],

    SUM(A.Valor) - SUM(A.ValorSaldo) AS [Valor Pago],
    SUM(A.ValorSaldo) AS [Valor Devedor],
    SUM(A.Valor) AS [Valor Total],

	CASE 
		WHEN SUM(A.ValorSaldo) = 0 THEN 'Quitado'
		ELSE 'Pendente'
	END AS Situacao_Conta

FROM
    A
    INNER JOIN (
        SELECT
            E.Codigo,
            P.Nome
        FROM
            Estabelecimento E
            INNER JOIN Pessoa P ON P.OIDPessoa = E.OIDPessoa
    ) Estabelecimento
        ON Estabelecimento.Codigo = A.Estabelecimento
GROUP BY
    Estabelecimento.Codigo,
    Estabelecimento.Nome,
    A.Nome,
    A.NumDocumento

HAVING
    A.Nome LIKE '%banco%'
ORDER BY
	[Numero Documento]