SELECT
	D.DtMovimento,
	YEAR(D.DTMovimento) AS Ano,
	UPPER(FORMAT(D.DtMovimento, 'MMMM', 'pt-BR')) AS Mes,
	FM.Valor,
    FM.Valor AS Total,
	P.Nome,
	C.CQCracha,
	C.Estabelecimento,
	F.DtAdmissao,
	P.CIC AS CPF,
	EV.Codigo
FROM FolhaMovimento FM
INNER JOIN
	Documento D ON D.OIDDocumento = FM.OIDDocumento
INNER JOIN
	Funcionario F ON F.OIDFuncionario = FM.OIDFuncionario
INNER JOIN
	Colaborador C ON C.OIDColaborador = F.OIDColaborador
INNER JOIN
	Pessoa P ON P.OIDPessoa = C.OIDPessoa
INNER JOIN
	EventoFolha EV ON EV.OIDEventoFolha = FM.OIDEventoFolha
WHERE
	DtMovimento >= '2025-01-01'
	AND C.OIDIndicativoSituacao = '4EBAF2137B6F'
	AND EV.Codigo IN ('0001', '0024', '0025', '0004', '0007', '0065', '5500', '5509', '8996', '5160', '5162', '5164', '5165', '5176', '5177', '5183', '5186', '5187', '5236', '5237', '5242', '5243', '5245', '5252', '5260', '5300', '5301', '5310', '5320')