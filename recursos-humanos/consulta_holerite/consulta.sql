SELECT
    Est.Empresa,
    Est.CNPJ,
    [Data de Pagamento],
	CONCAT(Colab.Codigo, ' - ', Pessoa.Nome) AS 'Funcionario',
	[Centro Custo],
	Cargo.Cargo,
	EV.Codigo,
	EV.Descricao,
	FM.Valor
FROM FolhaMovimento FM
INNER JOIN (
    SELECT OIDDocumento, Estabelecimento, FORMAT(DTMovimento, 'dd/MM/yyyy') AS 'Data de Pagamento'
    FROM Documento
) Doc ON Doc.OIDDocumento = FM.OIDDocumento
INNER JOIN (
    SELECT OIDFuncionario, OIDColaborador
    FROM Funcionario
) Func ON Func.OIDFuncionario = FM.OIDFuncionario
INNER JOIN (
    SELECT OIDColaborador, OIDPessoa, Codigo
    FROM Colaborador
) Colab ON Colab.OIDColaborador = Func.OIDColaborador
INNER JOIN (
	SELECT OIDPessoa, Nome, CIC AS 'CNPJ'
	FROM Pessoa)
Pessoa ON Pessoa.OIDPessoa = Colab.OIDPessoa
INNER JOIN (
	SELECT OIDEventoFolha, Codigo, Descricao
	FROM EventoFolha)
EV ON EV.OIDEventoFolha = FM.OIDEventoFolha
INNER JOIN (
    SELECT CONCAT(E.Codigo, ' - ', P.Nome) AS Empresa, P.CIC AS CNPJ, E.Codigo
    FROM Estabelecimento E
    INNER JOIN Pessoa P ON P.OIDPessoa = E.OIDPessoa
) Est ON Est.Codigo = Doc.Estabelecimento
INNER JOIN (
	SELECT
		OIDCentroCusto,	CONCAT(Codigo, ' - ', Descricao) AS 'Centro Custo'
	FROM CentroCusto)
Custo ON Custo.OIDCentroCusto = FM.OIDCentroCusto
INNER JOIN (
	SELECT
		vC.Codigo,
		vC.Nome,
		CONCAT(Cargo.Codigo, ' - ', vC.Cargo) AS Cargo
	FROM vColaboradorHistoricoCargoAtividadeEspecifica vC
	INNER JOIN
		Cargo ON Cargo.OIDCargo = vC.OIDCargo
	WHERE 
		DtFimCargo IS NULL)
Cargo ON Cargo.Codigo = Colab.Codigo
WHERE 
	Doc.[Data de Pagamento] >= '01/09/2010'
	AND Doc.[Data de Pagamento] < '01/05/2011'
	AND Pessoa.OIDPessoa = '8C650F77A013'
	AND Est.Codigo IN ('2', '4')