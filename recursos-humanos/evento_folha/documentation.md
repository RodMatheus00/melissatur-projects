# Documentação do Código SQL - "Evento Folha para Recursos Humanos"

## Bancos de Dados Utilizados

- **FolhaMovimento**: Banco de dados utilizado para a tabela `FolhaMovimento`, que registra os valores dos movimentos de folha de pagamento.
- **Documento**: Banco de dados utilizado para a tabela `Documento`, que contém as informações dos documentos relacionados aos movimentos.
- **Funcionario**: Banco de dados utilizado para a tabela `Funcionario`, que contém informações sobre os funcionários.
- **Colaborador**: Banco de dados utilizado para a tabela `Colaborador`, que conecta os colaboradores aos seus respectivos funcionários.
- **Pessoa**: Banco de dados utilizado para a tabela `Pessoa`, que armazena dados pessoais dos colaboradores.
- **EventoFolha**: Banco de dados utilizado para a tabela `EventoFolha`, que contém os códigos dos eventos relacionados aos movimentos de folha de pagamento.

---

## 1. Estrutura do Código

O código é composto por uma consulta principal que retorna informações sobre o movimento de folha de pagamento, detalhando o valor associado aos eventos específicos, o nome do colaborador e o código do evento.

### 1.1 Seleção de Dados

A consulta realiza uma junção de várias tabelas para recuperar as seguintes informações:

- **Ano**: O ano da movimentação, extraído da data do movimento (`DtMovimento`).
- **Mes**: O mês do movimento, formatado como o nome completo do mês em português.
- **Valor**: O valor associado ao movimento na tabela `FolhaMovimento`.
- **Nome**: O nome do colaborador relacionado ao movimento, extraído da tabela `Pessoa`.
- **Codigo**: O código do evento relacionado ao movimento de folha de pagamento, extraído da tabela `EventoFolha`.

#### Tabelas Utilizadas

- **FolhaMovimento** (banco FolhaMovimento): Tabela que contém os valores dos movimentos de folha de pagamento.
- **Documento** (banco Documento): Tabela associada aos documentos que referenciam os movimentos de folha.
- **Funcionario** (banco Funcionario): Tabela com informações dos funcionários envolvidos nos movimentos.
- **Colaborador** (banco Colaborador): Tabela que relaciona o colaborador ao seu funcionário.
- **Pessoa** (banco Pessoa): Tabela que contém dados pessoais do colaborador.
- **EventoFolha** (banco EventoFolha): Tabela que contém os códigos e descrições dos eventos da folha de pagamento.

#### Colunas Selecionadas

- **Ano**: Ano da movimentação de folha.
- **Mes**: Nome completo do mês, formatado para o idioma português.
- **Valor**: Valor associado ao movimento de folha de pagamento.
- **Nome**: Nome do colaborador, extraído da tabela `Pessoa`.
- **Codigo**: Código do evento relacionado ao movimento de folha.

#### Cálculos e Agrupamentos

- **Ano**: Extração do ano a partir da coluna `DtMovimento` da tabela `Documento`.
- **Mes**: Formatação da data de movimento (`DtMovimento`) para o nome do mês completo (em português) usando a função `FORMAT`.

---

### 1.2 Filtros

Os filtros são aplicados de acordo com as seguintes condições:

- **Data >= '2025-01-01'**: A consulta seleciona registros com data de movimento igual ou posterior a **01 de janeiro de 2025**.
- **C.OIDIndicativoSituacao = '4EBAF2137B6F'**: O filtro limita os resultados aos colaboradores com um indicativo de situação específico.
- **EV.Codigo IN (...)**: A consulta seleciona registros com códigos de evento que estão na lista fornecida. Esses códigos representam eventos específicos de folha, como horas extras, bonificações e descontos.

---

## 2. Objetivo

O objetivo principal da consulta é recuperar informações detalhadas sobre os eventos de movimentação de folha de pagamento para os colaboradores, incluindo:

- **Ano e Mês**: Identificação temporal da movimentação.
- **Valor**: Valor associado ao evento de movimentação.
- **Nome**: Nome do colaborador.
- **Codigo**: Código do evento relacionado ao movimento.

Essa consulta é útil para relatórios de folha de pagamento, auditorias ou para fornecer uma visão detalhada dos eventos específicos de folha de pagamento dos colaboradores após **janeiro de 2025**.

---

## **Licença**

Este código está disponível para uso interno dentro da organização, com foco em recursos humanos, e para fins de análise de folha de pagamento e auditoria. A utilização e modificação do código devem seguir as políticas internas de TI e Recursos Humanos.

---
