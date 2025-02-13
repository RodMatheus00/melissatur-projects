;WITH A AS(
SELECT 
    B.OIDPlanoContas, 
    B.OIDPlanoContasEstrutura,
    A.Codigo, 
	A.Descricao, 
    B.Codigo AS COD, 
    B.Descricao AS DEC,
    A.Formula
FROM 
    PlanoContasEstrutura A
JOIN 
    PlanoContasEstrutura B ON A.Formula LIKE '%' + B.Codigo + '%'
WHERE 
    A.OIDPlanoContas = '7D3F529E19CD' 
    AND B.OIDPlanoContas = 'C2805353D4C5'
    AND B.Grau = '5'),

B AS (
SELECT
    A.Codigo,
	A.Cod,
	CASE
		WHEN A.Codigo LIKE '01%' THEN '01. .'
		WHEN A.Codigo LIKE '02%' THEN '02. .'
		WHEN A.Codigo LIKE '03%' THEN '03. .'
		WHEN A.Codigo LIKE '04%' THEN '04. .'
		WHEN A.Codigo LIKE '05%' THEN '05. .'
		WHEN A.Codigo LIKE '06%' THEN '06. .'
		WHEN A.Codigo LIKE '07%' THEN '07. .'
		WHEN A.Codigo LIKE '08%' THEN '08. .'
		WHEN A.Codigo LIKE '09%' THEN '09. .'
		WHEN A.Codigo LIKE '10%' THEN '10. .'
		WHEN A.Codigo LIKE '11%' THEN '11. .'
		WHEN A.Codigo LIKE '12%' THEN '12. .'
		WHEN A.Codigo LIKE '13%' THEN '13. .'
	END AS Nivel_1,
	CASE
		WHEN A.Codigo LIKE '01.1%' THEN '01.1.'
		WHEN A.Codigo LIKE '01.2%' THEN '01.2.'
		WHEN A.Codigo LIKE '01.3%' THEN '01.3.'
		WHEN A.Codigo LIKE '01.4%' THEN '01.4.'
		WHEN A.Codigo LIKE '02.1%' THEN '02.1.'
		WHEN A.Codigo LIKE '02.2%' THEN '02.2.'
		WHEN A.Codigo LIKE '03.1%' THEN '03.1.'
		WHEN A.Codigo LIKE '03.2%' THEN '03.2.'
		WHEN A.Codigo LIKE '04.1%' THEN '04.1.'
		WHEN A.Codigo LIKE '04.2%' THEN '04.2.'
		WHEN A.Codigo LIKE '04.3%' THEN '04.3.'
		WHEN A.Codigo LIKE '04.4%' THEN '04.4.'
		WHEN A.Codigo LIKE '04.5%' THEN '04.5.'
		WHEN A.Codigo LIKE '04.6%' THEN '04.6.'
		WHEN A.Codigo LIKE '04.7%' THEN '04.7.'
		WHEN A.Codigo LIKE '04.8%' THEN '04.8.'
		WHEN A.Codigo LIKE '04.9%' THEN '04.9.'
		WHEN A.Codigo LIKE '05.1%' THEN '05.1.'
		WHEN A.Codigo LIKE '05.2%' THEN '05.2.'
		WHEN A.Codigo LIKE '06.1%' THEN '06.1.'
		WHEN A.Codigo LIKE '06.2%' THEN '06.2.'
		WHEN A.Codigo LIKE '06.3%' THEN '06.3.'
		WHEN A.Codigo LIKE '06.4%' THEN '06.4.'
		WHEN A.Codigo LIKE '06.5%' THEN '06.5.'
		WHEN A.Codigo LIKE '06.6%' THEN '06.6.'
		WHEN A.Codigo LIKE '06.7%' THEN '06.7.'
		WHEN A.Codigo LIKE '07.1%' THEN '07.1.'
		WHEN A.Codigo LIKE '07.2%' THEN '07.2.'
		WHEN A.Codigo LIKE '08.1%' THEN '08.1.'
		WHEN A.Codigo LIKE '08.2%' THEN '08.2.'
		WHEN A.Codigo LIKE '09.1%' THEN '09.1.'
		WHEN A.Codigo LIKE '09.2%' THEN '09.2.'
		WHEN A.Codigo LIKE '10.1%' THEN '10.1.'
		WHEN A.Codigo LIKE '10.2%' THEN '10.2.'
		WHEN A.Codigo LIKE '11.1%' THEN '11.1.'
		WHEN A.Codigo LIKE '11.2%' THEN '11.2.'
		WHEN A.Codigo LIKE '12.1%' THEN '12.1.'
		WHEN A.Codigo LIKE '12.2%' THEN '12.2.'
		WHEN A.Codigo LIKE '13.1%' THEN '13.1.'
		WHEN A.Codigo LIKE '13.2%' THEN '13.2.'
	END AS Nivel_2,	
	CONCAT(A.Codigo, ' - ', A.Descricao) AS Nivel_3,
	SUM(CASE WHEN CCM.TipoCD = 'D' THEN CCM.Valor * -1 ELSE 0 END) AS Debitos,
    SUM(CASE WHEN CCM.TipoCD = 'C' THEN CCM.Valor ELSE 0 END) AS Creditos,
	CCM.Estabelecimento,
	CCM.DtMovimento
FROM A
JOIN
    PlanoContasContaContabil PCC ON PCC.OIDPlanoContasEstrutura = A.OIDPlanoContasEstrutura
JOIN
    ContaContabilMov CCM ON CCM.OIDContaContabil = PCC.OIDContaContabil
WHERE 
	CCM.Situacao IS NULL
	AND DtMovimento >= '2020-01-01'
GROUP BY
	A.Codigo,
	A.COD,
	A.Descricao,
	CCM.Estabelecimento,
	CCM.DtMovimento)

SELECT
	CONVERT(DATE, B.DTMovimento) AS Data,
	CONCAT(B.Estabelecimento, ' - ', P.Nome) AS Empresa,
	B.Debitos,
	B.Creditos,
	CONCAT(B.Nivel_1, ' ', Dec1.Descricao) AS Nivel_1,
	CONCAT(B.Nivel_2, ' ', Dec2.Descricao) AS Nivel_2,
	B.Nivel_3
FROM B
JOIN
	PlanoContasEstrutura Dec1 ON Dec1.Codigo = B.Nivel_1
JOIN
	PlanoContasEstrutura Dec2 ON Dec2.Codigo = B.Nivel_2
INNER JOIN
	Estabelecimento E ON E.Codigo = B.Estabelecimento
JOIN
	Pessoa P ON P.OIDPessoa = E.OIDPessoa
WHERE 
	Dec1.OIDPlanoContas = '7D3F529E19CD'
	AND Dec2.OIDPlanoContas = '7D3F529E19CD'