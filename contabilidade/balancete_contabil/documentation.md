# Balancete Contábil

## **Bancos de Dados Utilizados**

- **Transnet**

## 1. Estrutura do Código

O código SQL é estruturado em duas partes principais:

1. **Subconsulta** (`WITH A AS (...)`): Define uma subconsulta que coleta dados de várias tabelas e realiza cálculos importantes para gerar um balancete contábil detalhado.
   
2. **Consulta Principal**: Utiliza a subconsulta `A` e faz junções adicionais para complementar as informações, trazendo dados adicionais, como o nome das empresas e contas contábeis.

---

### 1.1 Subconsulta

A subconsulta busca consolidar dados financeiros das contas contábeis, agrupando e somando débitos e créditos. A subconsulta também cria uma classificação hierárquica das contas contábeis com base no formato do número da conta.

#### Tabelas Utilizadas

- **grupogem.CO_LANCAMENTOS (CL)**: Contém os lançamentos contábeis.
- **grupogem.CONTAS_CONTABEIS (CC)**: Contém as contas contábeis.
- **grupogem.CO_LOTES (L)**: Contém informações sobre lotes de lançamentos contábeis.

#### Colunas Selecionadas

- **Empresa**: ID da empresa.
- **Data**: Data do lote.
- **LOTE**: ID do lote.
- **ID_LANCAMENTO**: ID do lançamento contábil.
- **CS_TIPO**: Tipo de lançamento (Débito ou Crédito).
- **Conta_Contabil**: ID da conta contábil.
- **Pai**: Conta contábil pai.
- **Nivel_1**, **Nivel_2**, **Nivel_3**: Hierarquia das contas contábeis.
- **Debito**: Valor total de débitos.
- **Credito**: Valor total de créditos.
- **Nivel_5**: Último nível da conta contábil (formato completo).

#### Cálculos e Agrupamentos

- **Débito**: Calculado através de uma soma de lançamentos com tipo 'D' (Débito).
- **Crédito**: Calculado através de uma soma de lançamentos com tipo 'C' (Crédito).
- **Níveis**: A estrutura hierárquica das contas contábeis é definida com base em padrões de formatação do número da conta.

---

### 1.2 Consulta Principal

A consulta principal realiza junções com a subconsulta `A` para agregar e exibir os dados consolidados de uma maneira mais compreensível e categorizada.

#### Tabelas e Junções

- **grupogem.contas_contabeis (CC)**: Junta-se com a subconsulta `A` para associar as descrições das contas ao nível de cada conta contábil.
- **grupogem.Empresas (E)**: Junta-se para incluir o nome da empresa correspondente ao ID da empresa.
- **grupogem.contas_contabeis (DD, EE, GG)**: Juntam-se em diferentes níveis para trazer as descrições das contas contábeis em vários níveis (2, 3 e 5).

#### Colunas Selecionadas

- **Empresa**: ID da empresa.
- **Data**: Data do lote.
- **NM_Empresa**: Nome da empresa.
- **Mes**: Mês extraído da data do lote.
- **Nome_Mes**: Nome do mês correspondente ao número do mês.
- **Nivel_1**, **Nivel_2**, **Nivel_3**, **Nivel_5**: Contas contábeis e suas descrições associadas aos diferentes níveis.
- **Debito**: Valor total de débitos da subconsulta.
- **Credito**: Valor total de créditos da subconsulta.

#### Filtros

A consulta principal filtra os registros para garantir que o lote não seja do tipo "ENCERRAMENTO".

- **Filtro de Lote**: `WHERE A.NM_LOTE != 'ENCERRAMENTO'`

---

## 2. Objetivo

Este código SQL tem como objetivo gerar um balancete contábil detalhado para cada empresa. Ele calcula os débitos e créditos das contas contábeis, organizados por níveis hierárquicos e agrupados por lote e data. Além disso, ele associa os dados financeiros com as descrições das contas e o nome da empresa.

---

## **Licença**

Este código está disponível para uso interno dentro da organização e para fins de análise e auditoria. A utilização e modificação do código devem ser feitas de acordo com as políticas internas.
