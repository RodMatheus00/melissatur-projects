DECLARE @Data AS Date;
SET @Data = '2024-01-01';

WITH Temp AS (
    SELECT 
        Rel.DataHoraAcesso,
        Rel.Prefixo,
        Rel.Cobrador,
        Rel.Nome,
        Rel.Descricao,
        Rel.Codigo,
        Rel.Linha
    FROM vwRel0402 Rel
    WHERE Rel.Descricao = 'Temporal'
),
Uni AS (
    SELECT
        T.DataHoraAcesso,
        T.Prefixo,
        T.Cobrador,
        T.Nome,
        Prod.Descricao,
        T.Codigo,
        T.Linha,
        Prod.Quantidade_Comprada,
        Prod.Quantidade_Integracao,
        1 AS Quantidade
    FROM Temp T
    INNER JOIN (
        SELECT
            R.Prefixo,
            R.Linha,
            R.Data,
            CASE WHEN R.Qtd > 1 THEN 1 ELSE 0 END AS Quantidade_Comprada,
            CASE WHEN R.Qtd <= 1 THEN 1 ELSE 0 END AS Quantidade_Integracao,
            P.Descricao
        FROM Rel0100 R
        INNER JOIN Produtos P ON P.ProdutoID = R.ProdutoID
        WHERE R.ProdutoID IN ('33', '32', '31')
          AND R.Prefixo IS NOT NULL
          AND EventoID NOT IN ('5', '7')
    ) Prod ON Prod.Data = T.DataHoraAcesso AND Prod.Prefixo = T.Prefixo

    UNION ALL

    SELECT 
        Rel.DataHoraAcesso,
        Rel.Prefixo,
        Rel.Cobrador,
        Rel.Nome,
        Rel.Descricao,
        Rel.Codigo,
        Rel.Linha,
        0 AS Quantidade_Comprada,
        0 AS Quantidade_Integracao,
        1 AS Quantidade
    FROM vwRel0402 Rel
    WHERE Rel.Descricao != 'Temporal'
)

SELECT
    '23' AS Empresa,
    CONVERT(DATE, Uni.DataHoraAcesso) AS Data,
    MONTH(Uni.DataHoraAcesso) AS Mes,
    YEAR(Uni.DataHoraAcesso) AS Ano,
    CONVERT(VARCHAR(8), Uni.DataHoraAcesso, 108) AS Time,
    Uni.Codigo AS Codigo_Linha,
    Uni.Linha,
    Uni.Prefixo AS Veiculo,
    UPPER(Uni.Cobrador) AS Cobrador,
    UPPER(Uni.Nome) AS Usuario,
	CASE 
		WHEN Uni.Descricao = 'COMUM DIARIO' AND Quantidade_Integracao = 1 THEN 'Diária Integração'
		WHEN Uni.Descricao = 'COMUM SEMANAL' AND Quantidade_Integracao = 1 THEN 'Semanal Integração'
		WHEN Uni.Descricao = 'COMUM MENSAL' AND Quantidade_Integracao = 1 THEN 'Mensal Integração'
		ELSE Uni.Descricao
	END AS Produto,
    Uni.Quantidade
FROM Uni
WHERE Uni.DataHoraAcesso >= @Data;
