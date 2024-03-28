from flask import Flask, Response
import requests
import subprocess

app = Flask(__name__)

# Замените URL вашим URL для получения данных
DATA_URL = "https://raw.githubusercontent.com/DOUBLE-TOP/checker/main/check_commands.csv"

def fetch_data(url):
    response = requests.get(url)
    response.raise_for_status()  # Проверка на ошибки HTTP
    return response.text

def parse_data(raw_data):
    lines = raw_data.strip().split("\n")
    return [line.split(";") for line in lines]

def check_node(command):
    result = subprocess.run(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    return result.returncode == 0

@app.route('/metrics')
def metrics():
    metrics_output = []
    raw_data = fetch_data(DATA_URL)
    nodes_data = parse_data(raw_data)

    for nodename, command in nodes_data:
        status = check_node(command)
        status_metric = 1 if status else 0
        metrics_output.append(f'node_check_status{{nodename="{nodename}"}} {status_metric}')
    
    return Response("\n".join(metrics_output), mimetype="text/plain")

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=19100)
