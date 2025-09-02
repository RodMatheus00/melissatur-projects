With Firstconsultation AS(
SELECT
	Item.OIDFamiliaCompra,
	NFI.OIDNaturezaOperacao,
    D.OIDDocumento,
    Forn.Codigo,
    CONCAT(D.Estabelecimento, ' - ', Estabelecimento.Nome) AS Empresa,
    Fornecedor.Nome AS Fornecedor,
    CONVERT(DATE, D.DtMovimento) AS Data,
    D.Numero AS Documento,
	CI.Descricao AS SubGrupo,
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
INNER JOIN ClasseItem CI ON CI.OIDClasseItem = Item.OIDClasseItem
WHERE
	D.Estabelecimento IN ('17', '28', '35', '27', '32', '3', '5', '31', '26', '2', '23')
	AND D.OIDModeloDocumento != '326F63670AD4')

SELECT 
	Data,
	FirstConsultation.Empresa,
	Codigo,
	Fornecedor,
	Documento,
	FamiliaCompra.Descricao AS Grupo,
	Codigo_Item,
	Item,
	SubGrupo,
	Quantidade,
	Valor
FROM Firstconsultation
LEFT JOIN
	FamiliaCompra ON FamiliaCompra.OIDFamiliaCompra = Firstconsultation.OIDFamiliaCompra
INNER JOIN
	NaturezaOperacao ON NaturezaOperacao.OIDNaturezaOperacao = Firstconsultation.OIDNaturezaOperacao
WHERE
	Data >= '2025-01-01'
	AND FamiliaCompra.Descricao != 'Administração'
	AND NaturezaOperacao.IndGeraTitulo = 'S'
    AND Item NOT LIKE '7002%'