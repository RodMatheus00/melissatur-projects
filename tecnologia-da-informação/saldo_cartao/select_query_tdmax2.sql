SELECT
    T.LoteID AS 'Lote ID',
    FORMAT(T.DataCriacao, 'dd/MM/yyyy') AS [Data da Criação],
    T.LoteStr,
    T.Transacao,
    T.NumSerie,
    Cadastros.Nome AS 'Usuário',
    CS.DocumentoFederal AS 'Documento',
    CS.UltimaTransacao AS 'Ultimo uso',
    CA.Saldo AS 'Saldo Atual',
    CA.ValorUsado AS 'Passagem',
    FORMAT(CS.UltimaTransacao, 'dd/MM/yyyy') AS 'Ultima Utilização',
    CT.Descricao AS 'Produto',
    CASE WHEN CT.Descricao = 'Comum' THEN 1 ELSE 0 END AS 'Pagante',
    CASE WHEN CT.Descricao = 'Gratuito' THEN 1 ELSE 0 END AS 'Gratuitos',
    CASE WHEN CT.Descricao = 'Estudante' THEN 1 ELSE 0 END AS 'Estudante'
FROM vw_dbaCartoesSaldos CS
INNER JOIN Cadastros ON Cadastros.DocFederal = CS.DocumentoFederal
INNER JOIN CadastrosTipos CT ON CT.CadastroTipoID = Cadastros.CadastroTipoID
INNER JOIN (
    SELECT
        CT.Data,
        CT.NumSerie,
        CT.Transacao,
        CT.LoteID,
        CT.CadastroID,
        CS.Saldo,
        L.DataCriacao,
        L.LoteStr
    FROM CartoesTransacoes CT
    INNER JOIN CartoesSaldos CS ON CS.NumSerie = CT.NumSerie AND CS.Transacao = CT.Transacao
    INNER JOIN (
        SELECT 
            Lotes.DataCriacao,
            Lotes.LoteID,
            Lotes.LoteStr
        FROM Lotes
    ) L ON L.LoteID = CT.LoteID
) T ON T.Data = CS.UltimaTransacao AND T.CadastroID = Cadastros.CadastroID
INNER JOIN CartoesAcessos CA ON CA.NumSerie = T.NumSerie AND CA.Transacao = T.Transacao
WHERE
    Cadastros.PerfilCompraID IS NOT NULL
    AND CT.CadastroTipoID IN ('1', '3', '5')
    AND T.DataCriacao >= '2024-09-30'
