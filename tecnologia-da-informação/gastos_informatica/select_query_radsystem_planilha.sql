WITH ConsultaFinal AS (
    SELECT
        D.OIDDocumento,
        Forn.Codigo,
        CONCAT(D.Estabelecimento, ' - ', Estabelecimento.Nome) AS Empresa,
        Fornecedor.Nome AS Fornecedor,
        CONVERT(DATE, D.DtMovimento) AS Data,
        D.Numero AS Documento,
		Item.Codigo AS Codigo_Item,
        CONCAT(Item.Codigo, ' - ', NFI.Descricao) AS Item,
        GID.Descricao AS ItemGrupo,
        NFI.Quantidade AS Quantidade,
        NFI.ValorTotal AS Valor,
        
        -- Contagem por grupo
        CASE 
            WHEN ROW_NUMBER() OVER (PARTITION BY NFI.OIDDocumento, GID.Descricao ORDER BY NFI.OIDDocumento) = 1 THEN 1
            ELSE 0
        END AS ContagemPorGrupo,
        
        -- Contagem por tipo de documento
        CASE
            WHEN ROW_NUMBER() OVER (PARTITION BY NFI.OIDDocumento, MD.Codigo ORDER BY NFI.OIDDocumento) = 1 THEN 1
            ELSE 0
        END AS ContagemPorTipo,
        
        -- Contagem por documento (geral)
        CASE 
            WHEN ROW_NUMBER() OVER (PARTITION BY NFI.OIDDocumento ORDER BY NFI.OIDDocumento) = 1 THEN 1
            ELSE 0
        END AS ContagemPorDocumento

    FROM NotaFiscalItem NFI
    INNER JOIN Documento D ON D.OIDDocumento = NFI.OIDDocumento
    INNER JOIN NotaFiscal NF ON NF.OIDDocumento = NFI.OIDDocumento
    LEFT JOIN ModeloDocumento MD ON MD.OIDModeloDocumento = D.OIDModeloDocumento
    INNER JOIN Item ON Item.OIDItem = NFI.OIDItem
    LEFT JOIN GrupoItemDetalhe GID ON GID.OIDGrupoItemDetalhe = Item.OIDGrupoItemDetalhe
    INNER JOIN Pessoa Fornecedor ON Fornecedor.OIDPessoa = NF.OIDPessoa
    INNER JOIN Fornecedor Forn ON Forn.OIDPessoa = NF.OIDPessoa
    INNER JOIN (
        SELECT
            E.Codigo,
            P.Nome
        FROM Estabelecimento E
        INNER JOIN Pessoa P ON P.OIDPessoa = E.OIDPessoa
    ) Estabelecimento ON Estabelecimento.Codigo = D.Estabelecimento

    WHERE
        DtMovimento >= '2020-01-01'
        AND (
            (GID.Descricao IN ('Informatica', 'Bilhetagem') AND MD.Codigo IN ('021', '045'))
            OR Forn.Codigo IN (
				'19861', '29701', '52329', '46523', '48496',
				'27596', '41157', '32972', '25755', '36455',
				'4665',  '39071', '25054', '27766', '41246',
				'43915', '14281', '2871',  '29611', '40649',
				'49093', '10545', '4709',  '30775', '20631', 
				'12335', '52604', '50002', '38131',	'27774',
				'2989',  '40916', '26069', '14931',	'28631',
				'37871', '27871', '32743', '52175', '30961',
				'9458')
        )
),

B AS (
SELECT 
    Data,
    Empresa,
	Codigo,
    Fornecedor,
    Documento,
	Codigo_Item,
    Item,
    CASE
        WHEN Codigo IN ('34819', '47741', '23264', '33261', '30961') THEN 'Administração Geral'
        WHEN ItemGrupo IN ('Bilhetagem', 'Serviços Diversos') THEN 'Bilhetagem'
        ELSE 'Equipamentos Informática'
    END AS [Item Grupo],

    Quantidade,

    -- Cálculo do valor líquido com retenções e acréscimos
    Valor
        - COALESCE(NF.ValorCOFINSRetencao, 0)
        - COALESCE(NF.ValorIRRF, 0)
        - COALESCE(NF.ValorCSLLRetencao, 0)
        - COALESCE(NF.ValorISSRetencao, 0)
        - COALESCE(NF.ValorPISRetencao, 0)
        - COALESCE(NF.ValorDesconto, 0)
        - COALESCE(NF.ValorINSS, 0)
        + COALESCE(NF.ValorFrete, 0)
        + COALESCE(NF.ValorOutrasDespesas, 0)
        + COALESCE(NF.ValorICMSST, 0)
        + COALESCE(NF.ValorIPI, 0) AS ValorTotal

FROM ConsultaFinal

LEFT JOIN (
    SELECT 
        OIDDocumento,
        OIDPessoa,
        ValorCOFINSRetencao,
        ValorINSS,
        ValorICMSST,
        ValorOutrasDespesas,
        ValorIRRF,
        ValorIPI,
        ValorCSLLRetencao,
        ValorISSRetencao,
        ValorPISRetencao,
        ValorDesconto,
        ValorFrete,
        1 AS ContagemGrupo
    FROM NotaFiscal
) NF ON NF.OIDDocumento = ConsultaFinal.OIDDocumento
    AND NF.ContagemGrupo = ConsultaFinal.ContagemPorDocumento

WHERE 
	ItemGrupo NOT IN (
    'Ambiente',
    'Material de Construção',
    'Copa / Cozinha',
    'Outros',
    'Papelaria',
    'Borracharia',
    'Mercedes Benz',
    'Fretes e Carretos')),

C AS (
SELECT
	*,
	CASE 
		WHEN Codigo_Item IN ('3931', '10140') THEN 'Locação Impressoras'
		WHEN Codigo_Item IN ('5233', '91823', '91821', '91822') THEN 'Telefonia e internet'
		WHEN Codigo = '9458' THEN 'Sistemas ERP'
		WHEN Codigo IN ('52604', '35084') OR Codigo_Item = '17249' THEN 'Rastreamento'
		WHEN Codigo IN ('32743') THEN 'Wifi Ônibus'
	ELSE [Item Grupo]
	END AS Item_Grupo_Correto
FROM B)

SELECT 
    UPPER(FORMAT(B.Data, 'MMMM', 'pt-BR')) AS Mes,
    SUM(B.ValorTotal) AS Valor
FROM B
WHERE
    B.Data >= '2025-01-01'
	AND B.Codigo NOT IN ('10545', '14168', '231', '29084', '33073', '38571', '39331', '4709', '9709', '773')
	AND B.Codigo_Item NOT IN ('4422', '18063', '8246', '9105')
GROUP BY
    FORMAT(B.Data, 'MMMM', 'pt-BR'),
    MONTH(B.Data)
ORDER BY
    MONTH(B.Data);