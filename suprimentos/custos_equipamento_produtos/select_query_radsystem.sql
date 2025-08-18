WITH A AS (
	SELECT 
        ME.DtMovimento,
        ME.Estabelecimento,
        ESI.Identificacao AS Veiculo,
        Equipamento.Categoria,
        Equipamento.Chassi,
        Equipamento.[Modelo Chassis],
        ME.Custo,
        FC.Descricao AS FamiliaCompra,
		ME.DescricaoItem
    FROM VMovimentoEstoque ME
LEFT JOIN
    vEquipamentoSomenteIdentificacao ESI ON ESI.OIDBem = ME.OIDBem
LEFT JOIN
    vOrdemExecucao OE ON OE.OIDDocumento = ME.OIDDocumentoDebito
LEFT JOIN
    Item I ON I.OIDItem = ME.OIDItem
LEFT JOIN
	FamiliaCompra FC ON FC.OIDFamiliaCompra = I.OIDFamiliaCompra
JOIN (
        SELECT
            A.OIDBem,
            A.Descricao AS Chassi,
            CASE 
                WHEN B.Descricao IS NULL THEN 'Não Cadastrado'
                ELSE B.Descricao 
            END AS 'Modelo Chassis',
            E.Identificacao,
            CE.Descricao AS Categoria
        FROM (
            SELECT
                Bem1.OIDBem,
                Bem2.Descricao
            FROM
                BemModelo Bem1
            INNER JOIN
                ModeloBem Bem2 ON Bem2.OIDModeloBem = Bem1.OIDModeloBem
            WHERE
                Bem2.OIDTipoModeloBem IN ('A67B0B5EDFB1', '7B4EF5232002')
        ) A
        LEFT JOIN (
            SELECT
                Bem1.OIDBem,
                Bem2.Descricao
            FROM
                BemModelo Bem1
            INNER JOIN
                ModeloBem Bem2 ON Bem2.OIDModeloBem = Bem1.OIDModeloBem
            WHERE
                Bem2.OIDTipoModeloBem = '7365C41016CC'
        ) B ON B.OIDBem = A.OIDBem
        INNER JOIN vEquipamento E ON E.OIDBem = A.OIDBem
        INNER JOIN CategoriaEquipamento CE ON CE.OIDCategoriaEquipamento = E.OIDCategoriaEquipamento
    ) Equipamento ON Equipamento.OIDBem = ME.OIDBem 
),

ConsultaFinal AS (
SELECT
	A.DescricaoItem,
    A.Estabelecimento,
    CONVERT(DATE, A.DtMovimento) AS Data,
    A.Veiculo AS Equipamento,
    A.[Modelo Chassis],
    A.Chassi,
    A.Categoria,
	0 AS 'KM Rodado',
    ROUND(SUM(CASE WHEN FamiliaCompra = 'Administração' THEN Custo ELSE 0 END), 2) AS Administração,
    ROUND(SUM(CASE WHEN FamiliaCompra = 'Combustivel' THEN Custo ELSE 0 END), 2) AS Combustivel,
    ROUND(SUM(CASE WHEN FamiliaCompra = 'Servicos Manutencao Frota' THEN Custo ELSE 0 END), 2) AS Servicos,    
    ROUND(SUM(CASE WHEN FamiliaCompra = 'Pecas E Acessorios' OR FamiliaCompra = 'Geral' THEN Custo ELSE 0 END), 2) AS 'Peças e Acessorios',
    ROUND(SUM(CASE WHEN FamiliaCompra = 'Lubrificante' THEN Custo ELSE 0 END), 2) AS Lubrificante,
    ROUND(SUM(CASE WHEN FamiliaCompra = 'Rodagem' THEN Custo ELSE 0 END), 2) AS Pneus
FROM A
GROUP BY
	A.DescricaoItem,
    A.Estabelecimento,
    A.Veiculo,
	A.[Modelo Chassis],
    A.Chassi,
    A.Categoria,
    A.DtMovimento

UNION ALL

SELECT
	NULL AS DescricaoItem,
	E.Estabelecimento,
	CONVERT(DATE, EU.DtMovimento) AS Data,
	EQ.Identificacao AS Equipamento,
	Equipamento.[Modelo Chassis],
	Equipamento.Chassi,
	Equipamento.Categoria,
	EU.ValorReal -	EU.UtilizacaoAnterior AS 'KM Rodado',
    0 AS Administração,
	0 AS Combustivel,
	0 AS Servicos,
	0 AS 'Peças e Acessorios',
	0 AS Lubrificante,
	0 AS Pneus
FROM vEquipamentoUtilizacao EU
INNER JOIN
	vEquipamentoSomenteIdentificacao EQ ON EQ.OIDBem = EU.OIDBem
JOIN (
        SELECT
            A.OIDBem,
            A.Descricao AS Chassi,
            CASE 
                WHEN B.Descricao IS NULL THEN 'Não Cadastrado'
                ELSE B.Descricao 
            END AS 'Modelo Chassis',
            E.Identificacao,
            CE.Descricao AS Categoria
        FROM (
            SELECT
                Bem1.OIDBem,
                Bem2.Descricao
            FROM
                BemModelo Bem1
            INNER JOIN
                ModeloBem Bem2 ON Bem2.OIDModeloBem = Bem1.OIDModeloBem
            WHERE
                Bem2.OIDTipoModeloBem IN ('A67B0B5EDFB1', '7B4EF5232002')
        ) A
        LEFT JOIN (
            SELECT
                Bem1.OIDBem,
                Bem2.Descricao
            FROM
                BemModelo Bem1
            INNER JOIN
                ModeloBem Bem2 ON Bem2.OIDModeloBem = Bem1.OIDModeloBem
            WHERE
                Bem2.OIDTipoModeloBem = '7365C41016CC'
        ) B ON B.OIDBem = A.OIDBem
        INNER JOIN vEquipamento E ON E.OIDBem = A.OIDBem
        INNER JOIN CategoriaEquipamento CE ON CE.OIDCategoriaEquipamento = E.OIDCategoriaEquipamento
    ) Equipamento ON Equipamento.OIDBem = EQ.OIDBem
	INNER JOIN
		vEquipamentoSomenteIdentificacaoEstabelecimento E ON E.OIDBem = EU.OIDBem
WHERE
	E.Estabelecimento IN ('17', '2', '23', '26', '27', '28', '3', '5', '31', '32', '33', '34', '35'))

SELECT DISTINCT
	CF.Estabelecimento,
	CF.Data,
	CF.Equipamento,
	CF.[Modelo Chassis],
	CF.Chassi,
	CF.Categoria,
	COALESCE(CF.DescricaoItem, 'Não se aplica') AS DescricaoItem,
	SUM(CF.[KM Rodado]) AS 'KM Rodado',
	SUM(CF.Administração) AS Administração,
	SUM(CF.Combustivel) AS Combustivel,
	SUM(CF.Servicos) AS Servicos,
	SUM(CF.[Peças e Acessorios]) AS 'Peças e Acessorios',
	SUM(CF.Lubrificante) AS Lubrificante,
	SUM(CF.Pneus) AS Pneus
FROM ConsultaFinal CF
WHERE 
	CF.Data >= '2025-01-01'
GROUP BY
	CF.Estabelecimento,
	CF.Data,
	CF.Equipamento,
	CF.[Modelo Chassis],
	CF.Chassi,
	CF.Categoria,
	CF.DescricaoItem