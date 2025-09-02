WITH ConsultaFinal AS (
    SELECT
		NFI.OIDNaturezaOperacao,
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
        NFI.ValorTotal AS Valor     
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
				'9458', '35084')
        )
),

B AS (
SELECT 
	OIDNaturezaOperacao,
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
	Valor AS 'ValorTotal'

FROM ConsultaFinal

WHERE 
	ItemGrupo NOT IN (
    'Ambiente',
    'Material de Construção',
    'Copa / Cozinha',
    'Outros',
    'Papelaria',
    'Borracharia',
    'Mercedes Benz',
    'Fretes e Carretos'))

SELECT
	B.*,
	CASE 
		WHEN Codigo_Item = '3931' THEN 'Locação Impressoras'
		WHEN Codigo_Item = '5233' THEN 'Telefonia e internet'
		WHEN Codigo = '9458' THEN 'Sistemas ERP'
		WHEN Codigo IN ('52604', '35084') THEN 'Rastreamento'
		WHEN Codigo IN ('32743') THEN 'Wifi Ônibus'
	ELSE [Item Grupo]
	END AS Item_Grupo_Correto
FROM B
INNER JOIN
	NaturezaOperacao ON NaturezaOperacao.OIDNaturezaOperacao = B.OIDNaturezaOperacao
WHERE
	NaturezaOperacao.IndGeraTitulo = 'S'
    AND Item NOT LIKE '7002%'