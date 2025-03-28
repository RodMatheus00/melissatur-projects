def parse_txt_line(line):
    matricula = line[0:9]
    tipo_registro = line[9]
    data_raw = line[10:18]
    hora_raw = line[18:22]
    pis = line[23:]  # pulando o caractere na posição 22

    # Formatando data e hora
    data_formatada = f"{data_raw[:2]}/{data_raw[2:4]}/{data_raw[4:]}"
    hora_formatada = f"{hora_raw[:2]}:{hora_raw[2:]}"

    return {
        "matricula": matricula,
        "tipo_registro": tipo_registro,
        "data": data_formatada,
        "hora": hora_formatada,
        "pis": pis
    }

def ler_arquivo_txt(caminho):
    registros = []
    with open(caminho, 'r') as arquivo:
        for linha in arquivo:
            linha = linha.strip()
            if linha:
                registros.append(parse_txt_line(linha))
    return registros

# Exemplo de uso
import pandas as pd

caminho_arquivo = 'Ponto.txt'  # substitua pelo seu caminho real
dados = ler_arquivo_txt(caminho_arquivo)

df = pd.DataFrame(dados)
print(df)

# Exportar se quiser
df.to_excel('registros_separados.xlsx', index=False)
