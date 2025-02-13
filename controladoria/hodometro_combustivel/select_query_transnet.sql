-- Hometro e Combustivel TRANSNET
WITH B AS (
    SELECT 
        E.ID_Equipamento,
        EM.NM_Empresa AS Empresa,
        REGEXP_REPLACE(EM.NR_CGC, '(\d{2})(\d{3})(\d{3})(\d{4})(\d)', '\1.\2.\3/\4-\5') AS CNPJ,
        E.NR_Ordem AS Veiculo,
        TRUNC(A.HR_Abastecimento) + CASE 
            WHEN TO_CHAR(A.HR_Abastecimento, 'HH24:MI:SS') BETWEEN '00:00:00' AND '01:00:00' THEN -1 
            ELSE 0 
        END AS Data,
        TO_CHAR(A.HR_Abastecimento, 'HH24:MI:SS') AS Horario,
        LAG(A.NR_Hodometro) OVER (PARTITION BY E.NR_Ordem ORDER BY A.HR_Abastecimento) AS Hodometro_Inicial,
        A.NR_Hodometro AS Hodometro_Final,
        (A.NR_Hodometro - LAG(A.NR_Hodometro) OVER (PARTITION BY E.NR_Ordem ORDER BY A.HR_Abastecimento)) AS Diferença_Hodometro,
        DA.QT_Combustivel AS Quantidade_Combustivel
    FROM 
        grupogem.abastecimentos A
    INNER JOIN 
        grupogem.Equipamentos E ON E.ID_Equipamento = A.ID_Equipamento
    INNER JOIN
        grupogem.Empresas EM ON EM.ID_Empresa = E.ID_Empresa
    INNER JOIN
        grupogem.Detalhes_Abastecimentos DA ON DA.ID_Abastecimento = A.ID_Abastecimento
    WHERE
        EM.NR_CGC = '80858053000420'
    ORDER BY 
        A.HR_Abastecimento
)
SELECT
    B.Empresa,
    B.Veiculo,
    B.Data,
    TO_CHAR(B.Data, 'MM') AS Month,
    CASE
        WHEN TO_CHAR(B.Data, 'MM') = 1 THEN 'JANEIRO'
        WHEN TO_CHAR(B.Data, 'MM') = 2 THEN 'FEVEREIRO'
        WHEN TO_CHAR(B.Data, 'MM') = 3 THEN 'MARÇO'
        WHEN TO_CHAR(B.Data, 'MM') = 4 THEN 'ABRIL'
        WHEN TO_CHAR(B.Data, 'MM') = 5 THEN 'MAIO'
        WHEN TO_CHAR(B.Data, 'MM') = 6 THEN 'JUNHO'
        WHEN TO_CHAR(B.Data, 'MM') = 7 THEN 'JULHO'
        WHEN TO_CHAR(B.Data, 'MM') = 8 THEN 'AGOSTO'
        WHEN TO_CHAR(B.Data, 'MM') = 9 THEN 'SETEMBRO'
        WHEN TO_CHAR(B.Data, 'MM') = 10 THEN 'OUTUBRO'
        WHEN TO_CHAR(B.Data, 'MM') = 11 THEN 'NOVEMBRO'
        WHEN TO_CHAR(B.Data, 'MM') = 12 THEN 'DEZEMBRO'
        ELSE TO_CHAR(B.Data, 'MM')
    end AS MONTH_FORMAT,
    TO_CHAR(B.Data, 'YYYY') AS Year,
    B.Horario,
    NVL(B.Hodometro_Inicial, 0) AS Hodometro_Inicial,
    NVL(B.Hodometro_Final, 0) AS Hodometro_Final,
    NVL(B.Diferença_Hodometro, 0) AS Diferença_Hodometro,
    NVL(B.Quantidade_Combustivel, 0) AS Quantidade_Combustivel,
    CASE 
        WHEN NVL(B.Quantidade_Combustivel, 0) > 0 THEN 
            TO_CHAR((NVL(B.Diferença_Hodometro, 0) / NVL(B.Quantidade_Combustivel, 0)), 'FM999990.00') || '%'
        ELSE 
            '0%'
    END AS Porcentagem_Hodometro_Combustivel,
    TV.DS_TIPO_VEICULO
FROM B
INNER JOIN
    grupogem.Historico_Equipamentos EQ ON EQ.ID_Equipamento = B.ID_Equipamento
INNER JOIN
    (
        SELECT 
            TV.ID_TIPO_VEICULO,
            TV.DS_TIPO_VEICULO
        FROM grupogem.tipos_veiculo TV
        ) TV ON TV.ID_TIPO_VEICULO = EQ.ID_TIPO_VEICULO          
WHERE 
    B.Data >= TO_DATE('2023-01-01', 'YYYY-MM-DD')
ORDER BY
    B.Veiculo
