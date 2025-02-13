WITH A AS(
	SELECT
	CONVERT(DATE, DataAbertura) AS Data,	
	Prefixo,
	IdLinha,
	KmTotal
FROM Turnos)

SELECT
	A.Data,
	A.Prefixo,
	SUM(
		CASE
			WHEN A.KMTotal IS NULL THEN 0
			ELSE A.KMTotal
		END
	) AS Km
FROM A
WHERE
	Data >= '2024-11-01'
GROUP BY
	A.Data,
	A.Prefixo
