DECLARE @DataIni DATE;
DECLARE @DataFim DATE;

SET @DataIni = '2024-01-01';
SET @DataFim = GETDATE();

SELECT DISTINCT	
	'Itajai' AS Empresa,
	1 AS Total_Compras,
	CONVERT(DATE, CE.Data) AS Data,
	FORMAT(CE.Data, 'HH:mm') AS Horario,
	MONTH(CE.Data) AS Mes,
	CASE 
		WHEN MONTH(CE.Data) = 1 THEN 'JANEIRO'
		WHEN MONTH(CE.Data) = 2 THEN 'FEVEREIRO'
		WHEN MONTH(CE.Data) = 3 THEN 'MARÇO'
		WHEN MONTH(CE.Data) = 4 THEN 'ABRIL'
		WHEN MONTH(CE.Data) = 5 THEN 'MAIO'
		WHEN MONTH(CE.Data) = 6 THEN 'JUNHO'
		WHEN MONTH(CE.Data) = 7 THEN 'JULHO'
		WHEN MONTH(CE.Data) = 8 THEN 'AGOSTO'
		WHEN MONTH(CE.Data) = 9 THEN 'SETEMBRO'
		WHEN MONTH(CE.Data) = 10 THEN 'OUTUBRO'
		WHEN MONTH(CE.Data) = 11 THEN 'NOVEMBRO'
		WHEN MONTH(CE.Data) = 12 THEN 'DEZEMBRO'
		ELSE 'Faltou'
	END AS Nome_Mes,
	C.Nome,
	CE.ValorCompra,
	P.Abreviacao,
	CASE 
		WHEN CE.TipoPagtoID = '20' THEN 'Pix'
		WHEN CE.TipoPagtoID = '11' THEN 'Pix'
		WHEN CE.TipoPagtoID = '1' THEN 'Boleto'
		ELSE 'Pix/Boleto'
	END AS Tipo_Pagamento,
	CASE 
		WHEN P.Abreviacao IN ('ESCOLAR', 'COMUM', 'COMUMDIA', 'COMUMSEM', 'COMUMMES') THEN 1
		ELSE 0
	END AS Aplicativo,
	CASE 
		WHEN P.Abreviacao = 'VT' THEN 1
		ELSE 0 
	END AS Web,
	CI.ValorUnitario
FROM CE
INNER JOIN Cadastros C ON C.CadastroID = CE.CadastroID
INNER JOIN CEItens CI ON CI.CEID = CE.CEID
INNER JOIN Produtos P ON P.ProdutoID = CI.ProdutoID
WHERE CE.ResponsavelId != '0' 
    AND (C.Nome = 'Mobilibus desenvolvimento e consultoria de sistema' 
         OR (P.Abreviacao = 'VT' AND CE.Web = '1'))
    AND CE.Data >= @DataIni
	OR CI.ProdutoID IN ('31', '32', '33')