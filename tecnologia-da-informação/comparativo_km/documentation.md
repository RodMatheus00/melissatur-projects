# Documentação do Código SQL - "Comparativo KM e Equipamento Utilização"

## Bancos de Dados Utilizados

- **ITS**: Banco de dados utilizado para a tabela `Turnos` e o CTE relacionado ao comparativo de quilometragem.
- **Radsystem**: Banco de dados utilizado para as tabelas `EquipamentoUtilizacao` e `vEquipamento` relacionadas ao movimento e utilização de equipamentos.

---

## 1. Estrutura do Código

O código é composto por duas partes principais:

1. **Comparativo de Quilometragem (KM)** - Consulta que agrupa e calcula o total de quilometragem por prefixo e data.
2. **Utilização de Equipamentos** - Consulta que retorna os detalhes de utilização dos equipamentos, filtrados por identificações e data.

---

### 1.1 Comparativo de Quilometragem (KM)

A primeira parte do código utiliza uma **subconsulta** (CTE) chamada `A`, que realiza a conversão de dados da tabela `Turnos`. Em seguida, a consulta principal agrega os valores de quilometragem.

#### Tabelas Utilizadas

- **Turnos** (banco ITS): Tabela utilizada para registrar as informações de turnos de operação, incluindo a quilometragem.

#### Colunas Selecionadas

- **DataAbertura**: A data de abertura do turno, convertida para o formato `DATE` e renomeada como `Data`.
- **Prefixo**: O prefixo associado ao turno de operação.
- **IdLinha**: O identificador da linha do turno (não utilizado na consulta principal).
- **KmTotal**: A quilometragem total registrada para o turno.

#### Cálculos e Agrupamentos

- **Soma das quilometragens**: A consulta principal soma a quilometragem total por `Prefixo` e `Data`, tratando valores nulos como zero.

#### Filtros

- **Data >= '2024-11-01'**: A consulta seleciona apenas registros com data igual ou posterior a `2024-11-01`.

---

### 1.2 Utilização de Equipamentos

A segunda parte do código utiliza a **subconsulta** (CTE) `ConsultaFinal`, que filtra dados das tabelas `EquipamentoUtilizacao` e `vEquipamento`. A consulta principal seleciona e organiza as informações filtradas.

#### Tabelas Utilizadas

- **EquipamentoUtilizacao** (banco Radsystem): Tabela que armazena os dados de utilização de equipamentos.
- **vEquipamento** (banco Radsystem): Visão que contém as informações dos equipamentos, incluindo suas identificações.

#### Colunas Selecionadas

- **OIDBem**: Identificador único do bem.
- **Identificacao**: Identificação do veículo, renomeada para `Veiculo` na consulta principal.
- **DtMovimento**: Data do movimento de utilização.
- **CONVERT(DATE, DtMovimento) AS DataSemHorario**: A data do movimento convertida para o formato `DATE`, sem o horário.
- **Valor**: O valor associado à utilização do equipamento.

#### Filtros

- **EU.DtOperacao >= '2024-11-01'**: O filtro seleciona registros com data de operação igual ou posterior a `2024-11-01`.
- **EI.Identificacao IN (...)**: O filtro seleciona registros com a identificação do veículo pertencente a um conjunto específico de valores.

---

## 2. Objetivo

### Comparativo de Quilometragem (KM)

O objetivo da primeira consulta é calcular o total de quilometragem por **Prefixo** e **Data** para o período a partir de **novembro de 2024**. A consulta agrupa as informações por `Prefixo` e `Data`, tratando valores nulos de quilometragem como zero.

### Utilização de Equipamentos

O objetivo da segunda consulta é recuperar informações detalhadas sobre a utilização de equipamentos (ou veículos), incluindo o **OIDBem**, **Identificação** (renomeada como `Veiculo`), **Data** do movimento, e **Valor** da operação. A data do movimento é exibida tanto com horário completo quanto sem o horário. A consulta filtra os dados por um intervalo de data a partir de **novembro de 2024** e por um conjunto específico de identificações de equipamentos.

---

## **Licença**

Este código está disponível para uso interno dentro da organização e para fins de análise e auditoria. A utilização e modificação do código devem ser feitas de acordo com as políticas internas.