import os
import shutil
import datetime
import re
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from dotenv import load_dotenv

load_dotenv()

SENDER_EMAIL = os.getenv('SENDER_EMAIL')
EMAIL_PASSWORD = os.getenv('EMAIL_PASSWORD')
RECIPIENT_EMAILS = os.getenv('RECIPIENT_EMAILS').split(',')
SMTP_SERVER = os.getenv('SMTP_SERVER')
SMTP_PORT = int(os.getenv('SMTP_PORT'))

backup_path = r'\\AS6104\Public\BackupRS\RadSystem'
date_pattern = re.compile(r'(\d{4})_(\d{2})_(\d{2})')

month_names = {
    1: "Janeiro", 2: "Fevereiro", 3: "Março", 4: "Abril",
    5: "Maio", 6: "Junho", 7: "Julho", 8: "Agosto",
    9: "Setembro", 10: "Outubro", 11: "Novembro", 12: "Dezembro"
}

today = datetime.date.today()
yesterday = today - datetime.timedelta(days=1)

end_of_month_backups = {}
backups = []
kept_report = []
deleted_report = []

for item_name in os.listdir(backup_path):
    match = date_pattern.search(item_name)
    if match:
        year, month, day = map(int, match.groups())
        date = datetime.date(year, month, day)
        backups.append((date, item_name))

        month_key = f"{year}-{month:02d}"
        if month_key not in end_of_month_backups or date > end_of_month_backups[month_key][0]:
            end_of_month_backups[month_key] = (date, item_name)

has_today_backup = any(date == today for (date, _) in backups)
tem_backup_recente = False
files_to_keep = set()
kept_dates = set()

if has_today_backup:
    tem_backup_recente = True
    for date, name in backups:
        if date == today:
            files_to_keep.add(name)
            if date not in kept_dates:
                kept_report.append(f"Mantido: {date} (hoje)")
                kept_dates.add(date)
else:
    for date, name in backups:
        if date == yesterday:
            tem_backup_recente = True
            files_to_keep.add(name)
            if date not in kept_dates:
                kept_report.append(f"Mantido: {date} (ontem - substituto)")
                kept_dates.add(date)

for date, name in end_of_month_backups.values():
    files_to_keep.add(name)
    if date not in kept_dates:
        month_name = month_names[date.month]
        kept_report.append(f"Mantido: {date} (último de {month_name})")
        kept_dates.add(date)

# Remove backups que não precisam ser mantidos
for date, item_name in backups:
    if item_name not in files_to_keep:
        full_path = os.path.join(backup_path, item_name)
        try:
            if os.path.isdir(full_path):
                shutil.rmtree(full_path)
            else:
                os.remove(full_path)
            deleted_report.append(f"Excluído: {date} - {item_name}")
        except PermissionError:
            deleted_report.append(f"❌ Acesso negado: {date} - {item_name}")
        except Exception as e:
            deleted_report.append(f"❌ Erro: {date} - {item_name}: {str(e)}")

# Monta o relatório em português
report = "\n📦 RELATÓRIO DE VERIFICAÇÃO DE BACKUP - RADSYSTEM\n\n"

if not tem_backup_recente:
    report += "⚠️ *ATENÇÃO: Nenhum backup encontrado para hoje ou ontem!*\n\n"

if kept_report:
    report += "✅ BACKUPS MANTIDOS:\n" + "\n".join(kept_report) + "\n\n"
else:
    report += "⚠️ Nenhum backup foi mantido.\n\n"

if deleted_report:
    report += "🗑️ BACKUPS EXCLUÍDOS:\n" + "\n".join(deleted_report) + "\n\n"
else:
    report += "✅ Nenhum backup foi excluído.\n\n"

report += "✔️ Verificação concluída."

print(report)

# Função para enviar e-mail
def send_email(report):
    msg = MIMEMultipart()
    msg['From'] = SENDER_EMAIL
    msg['To'] = ', '.join(RECIPIENT_EMAILS)
    msg['Subject'] = '📢 Relatório de Verificação de Backup'

    body = MIMEText(report, 'plain')
    msg.attach(body)

    try:
        server = smtplib.SMTP(SMTP_SERVER, SMTP_PORT)
        server.starttls()
        server.login(SENDER_EMAIL, EMAIL_PASSWORD)
        server.sendmail(SENDER_EMAIL, RECIPIENT_EMAILS, msg.as_string())
        server.quit()
        print("📧 E-mail enviado com sucesso!")
    except Exception as e:
        print(f"❌ Erro ao enviar e-mail: {str(e)}")

# Envia o e-mail com o relatório
send_email(report)
