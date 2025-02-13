WITH ConsultaFinal AS(
SELECT
    NFI.OIDDocumento,
	NF.OIDPessoa,
	D.OIDTipoDocumento,
	D.Estabelecimento,
	CASE
		WHEN D.Estabelecimento = '2' THEN 'Empresa De Ônibus Campo Largo LTDA'
		WHEN D.Estabelecimento = '3' THEN 'Viação Tamandaré LTDA'
		WHEN D.Estabelecimento = '5' THEN 'Auto Viação Antonina LTDA'
		WHEN D.Estabelecimento = '8' THEN 'Melissa Transportes e Turismo LTDA Filial'
		WHEN D.Estabelecimento = '15' THEN 'Instituto de Doenças Cardiovasculares LTDA'
		WHEN D.Estabelecimento = '16' THEN 'Corleto Adm. de Estacionamento LTDA'
		WHEN D.Estabelecimento = '17' THEN 'Viação Tamandaré LTDA Filial'
		WHEN D.Estabelecimento = '23' THEN 'Transpiedade - Transportes Coletivos LTDA'
		WHEN D.Estabelecimento = '26' THEN 'BRT Curitiba - Transportes Coletivos S/A'
		WHEN D.Estabelecimento = '27' THEN 'Transpiedade Filial BC'
		WHEN D.Estabelecimento = '28' THEN 'SPE Via Mobilidade S/A'
		ELSE D.Estabelecimento
	END AS Nome_Estabelecimento,
    CONVERT(DATE, D.DtMovimento) AS Data,
	YEAR(D.DtMovimento) AS Ano,
	MONTH(D.DtMovimento) AS Mes,
	DAY(D.DtMovimento) AS Dia,
	CONVERT(DATE, D.DtEmissao) AS Data_Emissão,
    D.Numero,
    NFI.Quantidade,
	NFI.ValorPropDespesas AS ValorDespesa,
	CONCAT(MD.Codigo, ' - ', MD.Descricao) AS Tipo_NF,
    NFI.Descricao AS Item,
	NFI.ValorIPI,
	NFI.ValorTotal,
    CASE 
        WHEN GID.Descricao IS NULL THEN 'NÃO POSSUI GRUPO'
        ELSE GID.Descricao
    END AS Grupo,
    CASE 
        WHEN ROW_NUMBER() OVER (PARTITION BY NFI.OIDDocumento, GID.Descricao ORDER BY NFI.OIDDocumento) = 1 THEN 1
        ELSE 0
    END AS ContagemPorGrupo,
	CASE
		WHEN ROW_NUMBER() OVER (PARTITION BY NFI.OIDDocumento, MD.Codigo ORDER BY NFI.OIDDocumento) = 1 THEN 1
		ELSE 0
	END AS ContagemPorTipo,
    CASE 
        WHEN ROW_NUMBER() OVER (PARTITION BY NFI.OIDDocumento ORDER BY NFI.OIDDocumento) = 1 THEN 1
        ELSE 0
    END AS ContagemPorDocumento
FROM NotaFiscalItem NFI
INNER JOIN
    Documento D ON D.OIDDocumento = NFI.OIDDocumento
JOIN
	NotaFiscal NF ON NF.OIDDocumento = NFI.OIDDocumento
LEFT JOIN
    ModeloDocumento MD ON MD.OIDModeloDocumento = D.OIDModeloDocumento
INNER JOIN
    Item I ON I.OIDItem = NFI.OIDItem
LEFT JOIN
    GrupoItemDetalhe GID ON GID.OIDGrupoItemDetalhe = I.OIDGrupoItemDetalhe
WHERE 
    MD.Codigo IN ('021', '045', '046', '050', '57', '67', '895', '012')
    AND D.Estabelecimento IN ('2', '3', '5', '8', '15', '16', '17', '23', '26', '27', '28')
    AND D.DtMovimento >= '2023-01-01')

SELECT
	B.OIDDocumento,
	B.OIDTipoDocumento,
	B.OIDPessoa,
	B.Data,
	B.Data_Emissão,
	CONCAT(B.Estabelecimento, ' - ', B.Nome_Estabelecimento) AS Estabelecimento,
	B.Estabelecimento AS Empresa,
	B.Ano,
	B.Mes,
	B.Dia,
	B.Tipo_NF,
	P.Nome AS Fornecedor,
	B.Numero,
	B.Item,
	B.Quantidade,
	B.ValorTotal
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
	+ COALESCE(NF.ValorIPI, 0) AS ValorTotal,
	B.Grupo,
	B.ContagemPorDocumento
FROM ConsultaFinal B
LEFT JOIN(
	SELECT 
		OIDDocumento,
		OIDPessoa,
		NF.ValorCOFINSRetencao,
		NF.ValorINSS,
		NF.ValorICMSST,
		NF.ValorOutrasDespesas,
		NF.ValorIRRF,
		NF.ValorIPI,
		NF.ValorCSLLRetencao,
		NF.ValorISSRetencao,
		NF.ValorPISRetencao,
		NF.ValorDesconto,
		NF.ValorFrete,
		1 AS ContagemGrupo
	FROM NotaFiscal NF) NF ON NF.OIDDocumento = B.OIDDocumento AND NF.ContagemGrupo = B.ContagemPorDocumento
INNER JOIN
	Pessoa P ON P.OIDPessoa = B.OIDPessoa
WHERE
	Data >= '2024-01-01'
	AND B.OIDTipoDocumento = '000000000F9F'
