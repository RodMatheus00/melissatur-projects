WITH ConsultaFinal AS(
	SELECT
    EU.OIDBem,
    EI.Identificacao,
    EU.DtMovimento,
    EU.Valor
FROM EquipamentoUtilizacao EU
INNER JOIN vEquipamento EI 
    ON EI.OIDBem = EU.OIDBem
WHERE 
    EU.DtOperacao >= '2024-11-01'
	AND EI.Identificacao IN ('1050', '1052', '1051', '1053', '655', '656', '1266', '652', '687', '657', '688', '1262', '663', '651', '653', '658', '659', '1054', '12', '90')
	)

SELECT
	OIDBem,
	Identificacao AS Veiculo,
	DtMovimento AS Data,
	CONVERT(DATE, DtMovimento) AS DataSemHorario,
	Valor
FROM ConsultaFinal
ORDER BY
	DtMovimento
