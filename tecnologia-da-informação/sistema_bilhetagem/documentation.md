# Documentação do Código SQL - Sistema de Bilhetagem

## Bancos de Dados Utilizados

- **TDMax**: O código utiliza o banco de dados TDMax para acessar informações sobre coletas, viagens, anomalias, turnos e cadastros de motoristas.

## 1. Estrutura do Código

O código é dividido em três partes principais, cada uma com um objetivo específico. A primeira parte lida com a última coleta realizada para cada prefixo. A segunda parte calcula anomalias registradas em viagens, e a terceira parte também lida com anomalias, mas com um foco maior nos dados das viagens.

#### Tabelas Utilizadas

- **historicoColetas**: Tabela que armazena as informações sobre coletas, incluindo prefixo e data.
- **viagens_anomalias (VA)**: Tabela que contém as informações sobre as anomalias registradas nas viagens.
- **Turnos (T)**: Tabela que contém os dados dos turnos de transporte.
- **Linhas (L)**: Tabela que contém informações sobre as linhas de transporte.
- **Cadastros (C)**: Tabela que contém informações sobre motoristas.
- **Anomalias (A)**: Tabela que armazena os tipos de anomalias.

#### Colunas Selecionadas

**Historico de Coletas (Primeira parte)**  
- **Prefixo**: Prefixo do veículo.
- **Data**: Data da coleta.
- **Data_Atual**: A data atual (obtida com `GETDATE()`).
- **Data_Ultima_Coleta**: Data da última coleta convertida para o tipo `DATE`.
- **Hora_Ultima_Coleta**: Hora da última coleta formatada como `HH:mm:ss`.

**Anomalias (Segunda e Terceira parte)**  
- **Data**: Data da anomalia registrada.
- **Valor**: Quantidade de anomalias registradas.
- **Descricao**: Descrição da anomalia.
- **Prefixo**: Prefixo do veículo associado ao turno.
- **Nome_Motorista**: Nome do motorista (obtido da tabela `Cadastros`).
- **Codigo**: Código da linha de transporte (obtido da tabela `Linhas`).
- **Nome**: Nome da linha de transporte.
- **DataIni**: Data de início do turno (obtida da tabela `Turnos`).
- **DataFim**: Data de fim do turno (obtida da tabela `Turnos`).

#### Cálculos e Agrupamentos

- **ROW_NUMBER() OVER (PARTITION BY Prefixo ORDER BY Data DESC)**: A função `ROW_NUMBER` é usada para numerar as coletas de cada prefixo, selecionando a última coleta (com a maior data).
- **SUM(DATEDIFF(HOUR, A.Data, A.Data_Atual)) AS Tempo_Sem_Coletar_Horas**: A função `DATEDIFF` calcula a diferença em horas entre a data da última coleta e a data atual, e o `SUM` soma as horas para todos os registros.

### 1.2 Consulta Principal

A consulta principal realiza duas tarefas distintas:

1. Calcula o tempo desde a última coleta de cada prefixo.
2. Exibe informações detalhadas sobre anomalias nas viagens.

#### Tabelas e Junções

- **CTE A**: Contém os dados da última coleta por prefixo.
- **viagens_anomalias VA**: Tabela usada para buscar dados sobre anomalias nas viagens.
- **Turnos T**: Realiza uma junção com a tabela de turnos, associando os turnos da viagem com os dados das anomalias.
- **Linhas L**: Realiza uma junção com a tabela de linhas de transporte, associando as linhas de transporte com os turnos.
- **Cadastros C**: Realiza uma junção com a tabela de motoristas, associando o motorista ao turno.
- **Anomalias A**: Realiza uma junção com a tabela de tipos de anomalias, associando a descrição da anomalia com os dados de viagem.

#### Colunas Selecionadas

- **Prefixo**: Prefixo do veículo.
- **Data_Ultima_Coleta**: Data da última coleta realizada.
- **Hora_Ultima_Coleta**: Hora da última coleta realizada.
- **Tempo_Sem_Coletar_Horas**: Soma das horas desde a última coleta.

- **Data**: Data da anomalia registrada.
- **Horario**: Hora da anomalia registrada.
- **QTD_Anomalias**: Quantidade de anomalias registradas.
- **Descricao**: Descrição da anomalia.
- **Prefixo**: Prefixo do veículo associado ao turno.
- **Nome_Motorista**: Nome do motorista associado ao turno.
- **Codigo**: Código da linha de transporte.
- **Nome**: Nome da linha de transporte.
- **DataIni**: Data de início do turno.
- **DataFim**: Data de fim do turno.

#### Filtros

- **Data >= @Data**: A primeira parte do código filtra as coletas que ocorreram nos últimos 5 dias a partir da data atual.
- **VA.AnomaliaId = '2' OR VA.AnomaliaId = '7'**: A segunda e terceira partes do código filtram as anomalias para incluir apenas as de tipo `2` e `7`.
- **VA.Data >= '20230101'**: Filtra as anomalias ocorridas a partir de 1º de janeiro de 2023.

## 2. Objetivo

Este código SQL tem como objetivo gerar dois relatórios distintos:

1. **Relatório de Coletas**: Mostra o tempo desde a última coleta para cada prefixo de veículo, calculado a partir das coletas realizadas nos últimos 5 dias.
2. **Relatório de Anomalias nas Viagens**: Exibe informações detalhadas sobre as anomalias ocorridas nas viagens, incluindo dados sobre motoristas, turnos, linhas de transporte e os tipos específicos de anomalias.

---

## **Licença**

Este código está disponível para uso interno dentro da organização e para fins de análise e auditoria. A utilização e modificação do código devem ser feitas de acordo com as políticas internas.