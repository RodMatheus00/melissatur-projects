# Documentação do Código - Extração de Dados da API e Consultas no Banco de Dados TDMax

## **Bancos de Dados Utilizados**

- **TDmax**

## 1. Estrutura do Código

#### Tabelas Utilizadas

- **CE (Compra Evento)**: Contém informações sobre as compras realizadas.
- **Cadastros (C)**: Tabela com os dados de cadastro, como nome.
- **CEItens (CI)**: Itens das compras, contendo detalhes dos produtos adquiridos.
- **Produtos (P)**: Detalhes sobre os produtos vendidos, incluindo abreviações.

#### Colunas Selecionadas

- **Empresa**: Valor fixo 'Itajai'.
- **Data**: Data da compra.
- **Horario**: Hora da compra.
- **Nome_Mes**: Nome do mês em formato textual.
- **ValorCompra**: Valor total da compra.
- **Tipo_Pagamento**: Tipo de pagamento (Pix ou Boleto).
- **Aplicativo**: Indica se o produto está relacionado a um aplicativo.
- **Web**: Indica se o produto está relacionado à Web.
- **ValorUnitario**: Valor unitário do produto.

#### Cálculos e Agrupamentos

- A consulta SQL usa a função `MONTH()` para calcular o mês da compra.
- Um `CASE` é usado para calcular o nome do mês baseado no número do mês.
- Outro `CASE` determina o tipo de pagamento com base nos códigos de pagamento.
- A coluna `Aplicativo` é calculada com base na abreviação do produto.
- A coluna `Web` indica se o produto está relacionado à Web, com base na abreviação do produto.

### 1.2 Consulta Principal

#### Tabelas e Junções

- **INNER JOIN Cadastros C ON C.CadastroID = CE.CadastroID**: A tabela `Cadastros` é unida à tabela `CE` usando o campo `CadastroID`.
- **INNER JOIN CEItens CI ON CI.CEID = CE.CEID**: A tabela `CEItens` é unida à tabela `CE` através do campo `CEID`.
- **INNER JOIN Produtos P ON P.ProdutoID = CI.ProdutoID**: A tabela `Produtos` é unida à tabela `CEItens` através do campo `ProdutoID`.

#### Colunas Selecionadas

- Já descritas na seção anterior, incluem informações como: empresa, data, valor de compra, tipo de pagamento, entre outras.

#### Filtros

- **CE.ResponsavelId != '0'**: Exclui registros onde o `ResponsavelId` é igual a '0'.
- **(C.Nome = 'Mobilibus desenvolvimento e consultoria de sistema' OR (P.Abreviacao = 'VT' AND CE.Web = '1'))**: Filtra registros onde o nome do cadastro é 'Mobilibus' ou o produto é 'VT' e está relacionado à Web (com `CE.Web = '1'`).
- **CE.Data >= @DataIni**: A data da compra deve ser maior ou igual à data de início (`@DataIni`), definida como '2024-01-01'.
- **CI.ProdutoID IN ('31', '32', '33')**: Filtra registros em que o `ProdutoID` da tabela `CEItens` esteja entre '31', '32', ou '33'.

## 2. Objetivo

#### SQL

O código SQL tem como objetivo gerar um relatório de compras realizadas entre uma data de início (`@DataIni`) e a data atual. O relatório inclui informações sobre a empresa, data e hora da compra, nome do mês, nome do cadastro, valor da compra, tipo de pagamento, categoria do produto (aplicativo ou web) e o valor unitário do produto. 

Além disso, o código filtra as compras com base em determinados critérios como o nome do cadastro (Mobilibus) ou produtos específicos ('VT', '31', '32', '33'), e tipos de pagamento (Pix/Boleto).

#### Python

O código Python realiza o login em uma API externa, obtém uma lista de veículos registrados e consulta as posições dos veículos nos últimos 15 dias. Ele extrai os dados para cada veículo e os organiza em um DataFrame, exibindo o resultado final.

## 3. Integração com Banco de Dados TDMax

Este código não realiza diretamente uma consulta ao banco de dados TDMax, mas pode ser entendido como parte de um processo maior, onde os dados extraídos da API (como as posições dos veículos) poderiam ser armazenados no banco de dados TDMax para análises adicionais ou para fins de monitoramento. O Pandas pode ser usado para manipular os dados antes de enviá-los para o banco.

## 4. Dependências

Este código depende das seguintes bibliotecas:

- `requests` para fazer requisições HTTP.
- `pandas` para manipulação de dados e criação de DataFrame.
- `datetime` para cálculos de datas.

Se necessário, instale as dependências usando o seguinte comando:

```bash
pip install requests pandas

---

## **Licença**

Este código está disponível para uso interno dentro da organização e para fins de análise e auditoria. A utilização e modificação do código devem ser feitas de acordo com as políticas internas.