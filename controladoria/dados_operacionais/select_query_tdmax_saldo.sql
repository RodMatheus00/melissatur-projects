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
