DECLARE @DataIni AS DATE;
DECLARE @DataFim AS DATE;
DECLARE @Estabelecimento AS VARCHAR(2);

SET @DataIni = '2024-01-01';
SET @DataFim = '2024-10-02';
SET @Estabelecimento = '17';

;WITH A AS (
        SELECT 
            I.Descricao,
            FIM.Estabelecimento,
			FIM.UtilizacaoAnterior,
			FIM.UtilizacaoAtual,
            FIM.OIDBem,
            FIM.DtOperacao,
            SUM(FIM.UtilizacaoAtual - FIM.UtilizacaoAnterior) AS Soma,
            SUM(FIM.Quantidade) AS Quantidade
        FROM vFonteInsumoMovimento FIM
        INNER JOIN 
            FonteInsumo FM ON FM.OIDFonteInsumo = FIM.OIDFonteInsumo
        INNER JOIN
            Insumo I ON I.OIDInsumo = FM.OIDInsumo
        GROUP BY
            I.Descricao,
			FIM.UtilizacaoAnterior,
			FIM.UtilizacaoAtual,
            FIM.Estabelecimento,
            FIM.OIDBem,
            FIM.DtOperacao
),

B AS (
SELECT 
    A.*,
	Veiculo.CategoriaDescricao,
	Veiculo.DescricaoA,
	Veiculo.DescricaoB,
	Veiculo.Identificacao
FROM A
INNER JOIN (
    SELECT
        A.OIDBem,
        A.Descricao AS DescricaoA,
        CASE 
            WHEN B.Descricao IS NULL THEN 'Não Cadastrado'
            ELSE B.Descricao 
        END AS DescricaoB,
        E.Identificacao,
        CE.Descricao AS CategoriaDescricao
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
) Veiculo ON Veiculo.OIDBem = A.OIDBem),

ConsultaFinal AS(
SELECT 
	B.OIDBem,
	B.Estabelecimento,
	CASE	
        WHEN B.Estabelecimento = '2' THEN 'Empresa De Ônibus Campo Largo LTDA'
        WHEN B.Estabelecimento = '3' THEN 'Viação Tamandaré LTDA '
        WHEN B.Estabelecimento = '5' THEN 'Auto Viação Antonina LTDA'
        WHEN B.Estabelecimento = '17' THEN 'Viação Tamandare LTDA Filial'
        WHEN B.Estabelecimento = '23' THEN 'TRANSPIEDADE - Transportes Coletivos LTDA'
        WHEN B.Estabelecimento = '26' THEN 'BRT CURITIBA - Transportes Coletivos S/A'
        WHEN B.Estabelecimento = '27' THEN 'Transpiedade Filial BC'
        WHEN B.Estabelecimento = '28' THEN 'SPE Via Mobilidade S/A'
        ELSE B.Estabelecimento 
    END AS Nome_Empresa,
	CONVERT(DATE, B.DtOperacao) AS Data,
	MONTH(B.DtOperacao) AS Mes,
	YEAR(B.DtOperacao) AS Ano,
	CASE
        WHEN MONTH(B.DtOperacao) = 1 THEN 'JANEIRO'
        WHEN MONTH(B.DtOperacao) = 2 THEN 'FEVEREIRO'
        WHEN MONTH(B.DtOperacao) = 3 THEN 'MARÇO'
        WHEN MONTH(B.DtOperacao) = 4 THEN 'ABRIL'
        WHEN MONTH(B.DtOperacao) = 5 THEN 'MAIO'
        WHEN MONTH(B.DtOperacao) = 6 THEN 'JUNHO'
        WHEN MONTH(B.DtOperacao) = 7 THEN 'JULHO'
        WHEN MONTH(B.DtOperacao) = 8 THEN 'AGOSTO'
        WHEN MONTH(B.DtOperacao) = 9 THEN 'SETEMBRO'
        WHEN MONTH(B.DtOperacao) = 10 THEN 'OUTUBRO'
        WHEN MONTH(B.DtOperacao) = 11 THEN 'NOVEMBRO'
        WHEN MONTH(B.DtOperacao) = 12 THEN 'DEZEMBRO'
    END AS 'Mês Nome',
	B.UtilizacaoAnterior,
	B.UtilizacaoAtual,
	B.Quantidade,
	B.Soma,
	B.Descricao,
	B.CategoriaDescricao,
	B.DescricaoA,
	B.DescricaoB,
	B.Identificacao,
    Media.Media
FROM B
INNER JOIN (
	SELECT
	E.OIDBem,
	ECI.OIDClasseInsumo,
	E.Identificacao,
	ECI.Media,
	CI.Descricao
FROM vEquipamento E
INNER JOIN
	EquipamentoClasseInsumo ECI ON ECI.OIDBem = E.OIDBem
INNER JOIN
	ClasseInsumo CI ON CI.OIDClasseInsumo = ECI.OIDClasseInsumo) Media ON Media.OIDBem = B.OIDBem AND Media.Identificacao = B.Identificacao AND Media.Descricao = B.Descricao)

SELECT 
	C.*
FROM ConsultaFinal AS C
WHERE
	C.Data >= @DataIni