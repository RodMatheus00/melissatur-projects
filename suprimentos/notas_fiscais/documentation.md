# Documentação do Código SQL - Balancete Contábil

Este código SQL foi desenvolvido para gerar um **balancete contábil** detalhado, com base nos lançamentos contábeis realizados em diversos lotes. O objetivo é sumarizar os débitos e créditos por conta contábil e nível, além de fornecer informações adicionais sobre a empresa e o período de lançamento.

## 1. Estrutura do Código

O código está dividido em duas partes principais:

1. **Subconsulta (CTE - Common Table Expression) "A"**
2. **Consulta Principal**

### 1.1 Subconsulta (CTE - "A")

A CTE "A" é responsável por agregar os dados das tabelas envolvidas e calcular os débitos e créditos para cada conta contábil, considerando diferentes níveis hierárquicos.

#### Tabelas Utilizadas:
- `grupogem.CO_LANCAMENTOS (CL)`: Contém os lançamentos contábeis.
- `grupogem.CONTAS_CONTABEIS (CC)`: Contém as informações sobre as contas contábeis.
- `grupogem.CO_LOTES (L)`: Contém os dados dos lotes de lançamentos.

#### Colunas Selecionadas:
- **Empresa**: ID da empresa associada ao lançamento contábil.
- **Data**: Data do lote.
- **LOTE**: ID do lote.
- **ID_LOTE**: ID do lote no lançamento.
- **NM_LOTE**: Nome do lote.
- **ID_LANCAMENTO**: ID do lançamento contábil.
- **CS_TIPO**: Tipo de lançamento ('D' para débito e 'C' para crédito).
- **Conta_Contabil**: ID da conta contábil.
- **Pai**: ID da conta contábil pai.
- **Nivel_1, Nivel_2, Nivel_3**: Níveis hierárquicos da conta contábil (formatados com base no código da conta contábil).
- **Debito**: Valor total dos débitos.
- **Credito**: Valor total dos créditos.
- **Nivel_5**: Detalhamento adicional da conta contábil.

#### Cálculos e Agrupamentos:
- O código usa **CASE** para calcular os diferentes níveis hierárquicos da conta contábil com base no campo `NR_CONTA_CONTABIL_FORMATADO`.
- A soma dos valores dos débitos e créditos é calculada com base no tipo de lançamento (débito ou crédito).

### 1.2 Consulta Principal

A consulta principal seleciona os dados agregados pela CTE "A" e complementa com informações adicionais, como nome da empresa e descrição das contas contábeis nos diferentes níveis.

#### Tabelas e Junções:
- **A**: Referência à CTE criada anteriormente.
- `grupogem.contas_contabeis (CC, DD, EE, GG)`: Junção das contas contábeis para obter as descrições das contas para cada nível hierárquico.
- `grupogem.Empresas (E)`: Junção para obter o nome da empresa associada ao `ID_Empresa`.

#### Colunas Selecionadas:
- **Empresa**: ID da empresa.
- **Data**: Data do lote.
- **NM_Empresa**: Nome da empresa associada ao lançamento.
- **Mes**: Número do mês extraído da data.
- **Nome_Mes**: Nome do mês (em português) com base no número do mês.
- **Nivel_1, Nivel_2, Nivel_3, Nivel_5**: Níveis hierárquicos de contas contábeis, com suas descrições.
- **Debito**: Soma dos valores de débito.
- **Credito**: Soma dos valores de crédito.
- **CS_tipo**: Tipo de lançamento ('D' ou 'C').

#### Filtros:
- A consulta filtra os registros para excluir os lotes com nome "ENCERRAMENTO".

---

## 2. Objetivo

O objetivo deste código SQL é gerar um **balancete contábil** com as seguintes características:

- Exibir débitos e créditos por conta contábil.
- Apresentar uma hierarquia de contas contábeis (do nível 1 ao nível 5).
- Agrupar os dados por empresa, lote e mês.
- Fornecer informações detalhadas sobre cada lançamento, como o nome da empresa e a descrição das contas contábeis.
