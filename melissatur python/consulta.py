import pyodbc
import matplotlib.pyplot as plt
import numpy as np
import tkinter as tk
from tkinter import messagebox

# Configuração da conexão
conn = pyodbc.connect(
    'DRIVER={SQL Server};'
    'SERVER=;'  # IP do servidor
    'DATABASE=;'  # Substitua pelo nome do banco de dados
    'UID=;'  # Login
    'PWD='  # Senha
)

# Criação do cursor
cursor = conn.cursor()

# Definir a consulta SQL
query = """
SELECT DISTINCT
    T.OIDTitulo,
    T.Estabelecimento,
    CONCAT(T.Empresa, '/', T.Estabelecimento) AS 'Emp/Est',
    Esp.Descricao AS EspecieTitulo,
    CASE
        WHEN Pessoa.Nome IS NULL THEN T.DescricaoPessoa
        ELSE Pessoa.Nome
    END AS Pessoa,
    T.DtEmissao,
    T.DtVencimento,
    T.NumDocumento AS Documento,
    T.Parcela,
    T.Valor,
    T.ValorSaldo AS Pagar,
    Port.Descricao AS Portador,
    T.DtPrevQuitacao,
    Indi.Descricao AS 'Situação'
FROM Titulo T
INNER JOIN
    EspecieTitulo Esp ON Esp.OIDEspecieTitulo = T.OIDEspecieTitulo
INNER JOIN
    Portador Port ON Port.OIDPortador = T.OIDPortador
INNER JOIN
    FormaPagamento Form ON Form.OIDFormaPagamento = T.OIDFormaPagamento
INNER JOIN
    IndicativoSituacao Indi ON Indi.OIDIndicativoSituacao = T.OIDIndicativoSituacao
LEFT JOIN
    Pessoa ON Pessoa.OIDPessoa = T.OIDPessoa
WHERE 
    T.DtVencimento >= '2025-01-01'
    AND T.Estabelecimento IN ('5', '26', '2', '29', '18', '14', '12', '11', '28', '23', '27', '3', '17')
    AND Indi.Descricao IN ('Aguardando Liberação', 'Liberado', 'Liquidado', 'Aguardando Pagamento ao Fornecedor', 'Substituído')
    AND Esp.Descricao IN ('Titulo a Pagar', 'Adiantamento a Fornecedores', 'Títulos a Receber', 'Adiantamento de Clientes')
"""

# Executar a consulta
cursor.execute(query)

# Recuperar os resultados
rows = cursor.fetchall()

# Fechar a conexão
cursor.close()
conn.close()

# Processar os dados para criar um gráfico
estabelecimentos = {}
for row in rows:
    estabelecimento = row.Estabelecimento
    valor = row.Valor
    if estabelecimento not in estabelecimentos:
        estabelecimentos[estabelecimento] = 0
    estabelecimentos[estabelecimento] += valor

# Preparar dados para o gráfico
estabelecimentos_list = list(estabelecimentos.keys())
valores_list = list(estabelecimentos.values())

# Função para exibir o gráfico e a tabela
def exibir_grafico():
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Gráfico de barras
    ax1.bar(estabelecimentos_list, valores_list, color='skyblue')
    ax1.set_xlabel('Estabelecimento')
    ax1.set_ylabel('Valor Total (R$)')
    ax1.set_title('Valor Total por Estabelecimento')
    ax1.set_xticklabels(estabelecimentos_list, rotation=50, ha='right')

    # Tabela com o relatório
    table_data = [list(estabelecimentos.items())]
    table_data = np.array(table_data).reshape(len(estabelecimentos), 2)

    # Adiciona a tabela ao gráfico
    ax2.axis('off')
    ax2.table(cellText=table_data, colLabels=['Estabelecimento', 'Valor Total (R$)'], 
              loc='center', cellLoc='center', colLoc='center', bbox=[0, -0.5, 1, 1])

    # Ajusta o layout
    plt.tight_layout()
    plt.show()

# Criar a janela principal do Tkinter
root = tk.Tk()
root.title("Visualizar Tabela e Gráfico")

# Tamanho da janela
root.geometry("300x150")

# Criar um botão (ícone) para exibir o gráfico
btn_exibir_grafico = tk.Button(root, text="Exibir Gráfico e Tabela", command=exibir_grafico)
btn_exibir_grafico.pack(pady=50)

# Iniciar o loop da interface gráfica
root.mainloop()
