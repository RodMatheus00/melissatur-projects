WITH UltimoAcesso AS (
    SELECT 
        NumSerie,
        DataAcesso,
		Transacao,
        QtdUsada,
        Saldo,
        ValorUsado,
        ROW_NUMBER() OVER (PARTITION BY NumSerie ORDER BY DataAcesso DESC) AS RN
    FROM vwInfoAcessoCartao
)

SELECT
	FORMAT(L.DataCriacao, 'dd/MM/yyyy') AS [Data da Criação],
	L.LoteStr,
	UA.Transacao,
	UA.NumSerie,
	C.CadastroID AS 'Usuário',
	C.DocFederal AS 'Documento',
	UA.DataAcesso AS 'Ultimo Uso',
	CASE 
		WHEN DATEDIFF(MONTH, L.DataCriacao, GETDATE()) <= 12 THEN UA.Saldo
		ELSE 0
	END AS 'Saldo Atual',
	CONVERT(DATE, UA.DataAcesso) AS 'Ultima Utilização',
	P.Descricao AS 'Produtos',
	CASE
    WHEN P.Descricao IN ('Vale Transporte', 'Vale Transporte Rural') THEN 'VALE TRANSPORTE'
		WHEN P.Descricao IN ('Escolar', 'Escolar-Ferraria') THEN 'ESCOLAR'
		WHEN P.Descricao = 'Comum' THEN 'COMUM'
		ELSE 'OUTROS'
	END AS Produtos,
    CASE WHEN P.Descricao = 'Comum' THEN 1 ELSE 0 END AS 'Pagante',
	CASE WHEN P.Descricao IN ('Vale Transporte', 'Vale Transporte Rural') THEN 1 ELSE 0 END AS 'Quantidade VT',
    CASE WHEN P.Descricao IN ('Escolar', 'Escolar-Ferraria') THEN 1 ELSE 0 END AS 'Quantidade Escolar'
FROM UltimoAcesso UA
INNER JOIN
	Cartoes_Donos CD ON CD.NumSerie = UA.NumSerie
INNER JOIN
	Cadastros C ON C.CadastroID = CD.CadastroID
INNER JOIN
	CartoesTransacoes CT ON CT.NumSerie = UA.NumSerie AND CT.Transacao = UA.Transacao
INNER JOIN
	Produtos P ON P.ProdutoID = CT.ProdutoID
JOIN
	Lotes L ON L.LoteID = CT.LoteID
WHERE
	UA.RN = 1
	AND QtdUsada IS NOT NULL
	AND C.PerfilCompraID IS NOT NULL
	AND P.Descricao IN ('COMUM', 'Escolar', 'Escolar-Ferraria', 'Vale Transporte', 'Vale Transporte Rural')