SELECT
	ContaMov.DtMovimento,
	ContaMov.Estabelecimento,
	PlanoContasEstrutura.Codigo,
	PlanoContasEstrutura.Descricao,
	ContaMov.TipoCD,
	ContaMov.Valor,
	ContaContabil.CodigoReduzido,
	ContaContabil.Descricao
FROM PlanoContasContaContabil PCC
INNER JOIN
	ContaContabil ON ContaContabil.OIDContaContabil = PCC.OIDContaContabil
INNER JOIN
	ContaContabilMov ContaMov ON ContaMov.OIDContaContabil = ContaContabil.OIDContaContabil
INNER JOIN
	PlanoContasEstrutura ON PlanoContasEstrutura.OIDPlanoContasEstrutura = PCC.OIDPlanoContasEstrutura
WHERE 
	Codigo LIKE '1.1.5%'
	AND Estabelecimento	= '17'