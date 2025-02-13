# **Relatório de Lançamentos Contábeis**

## **Descrição**

Este projeto contém consultas SQL que geram relatórios detalhados de lançamentos contábeis, com informações sobre os valores de débito e crédito, discriminados por níveis hierárquicos de contas contábeis, empresas, e lotes. Através dessas consultas, conseguimos organizar e sumarizar os lançamentos, considerando o tipo de movimentação (D - Débito, C - Crédito) e o formato das contas contábeis.

## **Bancos de Dados Utilizados**

- **Transnet**
- **Radsystem**

## **Consultas SQL**

As consultas são estruturadas de forma a extrair dados detalhados de lançamentos contábeis, com base nas seguintes tabelas principais:

- **grupogem.CO_LANCAMENTOS (CL)**: Contém os lançamentos contábeis.
- **grupogem.CONTAS_CONTABEIS (CC)**: Contém as informações sobre as contas contábeis.
- **grupogem.CO_LOTES (L)**: Informações sobre os lotes de lançamentos.
- **grupogem.Empresas (E)**: Informações sobre as empresas.

## **Objetivo do Relatório**

O relatório tem como objetivo apresentar um detalhamento completo dos lançamentos contábeis com as seguintes informações:

- **Empresa**: ID e Nome da empresa.
- **Data**: Data do lote.
- **LOTE**: Identificação do lote.
- **Nome do Mês**: Nome completo do mês do lançamento.
- **Níveis de Conta Contábil**: Apresentação dos diferentes níveis de contas contábeis (1 a 5), com suas respectivas descrições.
- **Débito**: Total de débito relacionado ao lançamento.
- **Crédito**: Total de crédito relacionado ao lançamento.

### **Consultas Detalhadas**

#### 1. **Primeira Consulta SQL - Resumo de Lançamentos Contábeis**

Esta consulta tem como objetivo agrupar e organizar os lançamentos contábeis, somando os valores de débito e crédito para cada lançamento, e organizando as contas contábeis em diferentes níveis hierárquicos. A consulta usa as funções `CASE` para verificar o formato da conta contábil e categorizar os diferentes níveis (1, 2, 3, 4, 5).

**Exemplo de Resultado:**
- Empresa: ID da empresa
- Data: Data do lançamento
- Lote: Identificação do lote
- Débito: Valor total dos débitos
- Crédito: Valor total dos créditos
- Níveis 1 a 5: Contas contábeis divididas pelos níveis hierárquicos

#### 2. **Segunda Consulta SQL - Relatório Detalhado com Níveis de Contas e Empresa**

Após a criação da CTE `A`, que agrupa os dados dos lançamentos, a consulta principal busca os dados detalhados de cada lançamento, associando o nome das contas contábeis e o nome da empresa. A consulta também converte o número do mês para seu nome correspondente.

**Exemplo de Resultado:**
- Empresa: ID da empresa
- Nome da Empresa: Nome completo da empresa
- Mês: Nome do mês do lançamento
- Níveis 1 a 5: Níveis de contas contábeis, com os nomes das contas.
- Débito e Crédito: Valores totais de débito e crédito de cada lançamento.

## **Estrutura do Banco de Dados**

As consultas são executadas em dois bancos de dados:

- **Transnet**: Contém dados financeiros e contábeis.
- **Radsystem**: Sistema complementar utilizado para validar as contas e dados financeiros.

As tabelas principais incluem:
- **grupogem.CO_LANCAMENTOS**: Tabela de lançamentos contábeis.
- **grupogem.CONTAS_CONTABEIS**: Tabela de contas contábeis e hierarquia.
- **grupogem.CO_LOTES**: Tabela de lotes de lançamentos.
- **grupogem.Empresas**: Tabela de empresas.

## **Exemplo de Uso**

As consultas podem ser executadas no banco de dados para gerar relatórios mensais de lançamentos contábeis. Os resultados podem ser usados para análise contábil, auditoria e relatórios financeiros.

### **Execução**

Para gerar o relatório:

1. Conecte-se ao banco de dados **Transnet** ou **Radsystem**.
2. Execute a primeira consulta para agrupar e organizar os dados de lançamentos.
3. Execute a segunda consulta para obter o relatório detalhado, com informações adicionais sobre a empresa e os níveis de contas contábeis.
4. Filtre os dados conforme necessário (por exemplo, para considerar lançamentos a partir de 2020).

---

## **Licença**

Este código está disponível para uso interno dentro da organização e para fins de análise e auditoria. A utilização e modificação do código devem ser feitas de acordo com as políticas internas.
