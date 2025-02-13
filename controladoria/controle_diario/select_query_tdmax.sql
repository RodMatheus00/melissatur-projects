DECLARE @DataInicial DATETIME;
DECLARE @DataFinal DATETIME;
DECLARE @DataAtual DATETIME;

SET @DataInicial = '2023-11-21';
SET @DataFinal = '2024-08-13';
SET @DataAtual = GETDATE();

WITH A AS (
    SELECT
        VR.Data_Turno AS Data,
        VR.Prefixo,
        VR.Linha,
        1 AS Quantidade,
        VR.Descricao AS Produto,
		CASE
			WHEN VR.Descricao = 'Pagantes' THEN 4.50
			ELSE 0
		END AS Valor_Pagantes
	 FROM vwRel0402 VR
	WHERE VR.Descricao != 'Temporal'

    UNION ALL

    SELECT
        CAST(CAST(R.Data AS DATE) AS DATETIME) AS Data,
        R.Prefixo,
        R.Linha,
        1 AS Quantidade,
        P.Abreviacao AS Produto,
		0 AS Valor_Pagantes
    FROM Rel0100 R
    JOIN Produtos P ON P.ProdutoID = R.ProdutoID
    JOIN Cadastros C ON C.CadastroID = R.CadastroID
    WHERE 
		P.Abreviacao IN ('COMUMMES', 'COMUMSEM', 'COMUMDIA')
        AND Prefixo IS NOT NULL
),

B AS (
    SELECT
        CAST(T.Data AS DATE) AS Data,
        T.Prefixo,
        MIN(T.CatracaIni) AS CatracaInicialDoDia,
        MAX(T.CatracaFim) AS CatracaFinalDoDia
    FROM Turnos T
    GROUP BY
        CAST(T.Data AS DATE),
        T.Prefixo
)

SELECT
    CAST(A.Data AS DATE) AS Data,
    A.Prefixo,
    B.CatracaInicialDoDia AS 'Catraca Inicial',
    B.CatracaFinalDoDia AS 'Catraca Final',
    A.Produto,
    SUM(A.Quantidade) AS Quantidade,
	SUM(A.Quantidade * A.Valor_Pagantes) AS Valor_Pagantes
FROM A 
INNER JOIN B ON B.Data = A.Data AND B.Prefixo = A.Prefixo
WHERE A.Data >= @DataInicial 
GROUP BY 
    A.Data,
	A.Valor_Pagantes,
    B.CatracaInicialDoDia,
    B.CatracaFinalDoDia,
    A.Prefixo,
    A.Produto;
