SELECT
	'23' AS Empresa,
	M.MovimentoID,
	CONVERT(DATE, RM.DataInicio) AS Data,
	CONVERT(VARCHAR(8), RM.DataInicio, 108) AS Time,
	UPPER(FORMAT(RM.DataInicio, 'MMMM', 'pt-br')) AS Mes,
	UPPER(CA.Nome) AS Usuário,
	UPPER(Produto) AS Produto,
	RM.ValorUnitario,
	RM.Creditos,
	RM.Total
FROM vwRel0577_Movimentos RM 
INNER JOIN
	Movimentos M ON M.DataInicio = RM.DataInicio
INNER JOIN
	Cadastros CA ON CA.CadastroID = M.CadastroId
WHERE RM.DataInicio >= '2024-01-01'

UNION ALL 

SELECT
	'23' AS Empresa,
	0 AS MovimentoID,
	CONVERT(DATE, R.Data) AS Data,
	FORMAT(R.Data, 'HH:MM:ss') AS Time,
	UPPER(FORMAT(R.Data, 'MMMM', 'pt-br')) AS Mes,
	C.Nome AS Usuário,
	UPPER(P.Descricao) AS Produto,
	CAST(R.Saldo / 
	CASE	
		WHEN R.Saldo = 6 THEN 1
		WHEN R.Saldo = 36 THEN 7
		WHEN R.Saldo = 156 THEN 30
		ELSE 0
	END AS DECIMAL(10, 2)) AS 'Valor Unitário',	
    CASE	
		WHEN R.Saldo = 6 THEN 1
		WHEN R.Saldo = 36 THEN 7
		WHEN R.Saldo = 156 THEN 30
		ELSE 0
	END AS Creditos,
	R.Saldo AS Total
FROM Rel0100 R
INNER JOIN
	Cadastros C ON C.CadastroID = R.CadastroID
INNER JOIN
	Produtos P ON P.ProdutoID = R.ProdutoID
WHERE R.ProdutoId IN ('31', '32', '33')
	AND Prefixo is NULL
	AND Qtd > '1'
	AND R.Data >= '2024-01-01'
