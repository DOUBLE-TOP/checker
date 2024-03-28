#!/bin/bash 

function src_git_repo {
  #check if directory exists
  if [ -d "$HOME/checker" ]; then
    echo "checker exists, pulling latest changes"
    cd $HOME/checker
    git pull
  else
    echo "checker does not exist, cloning repo"
    git clone https://github.com/DOUBLE-TOP/checker/ $HOME/checker
    cd $HOME/checker
  fi

}

function prepare_python_env {
  if [ -d "$HOME/checker/venv" ]; then
    echo "venv exists, it's ok"
    return
  else
    echo "venv does not exist, installing requirements"
    sudo apt-get install python3-venv -y
    python3 -m venv venv
    source venv/bin/activate
    pip3 install -r requirements.txt
  fi

}

function create_systemd {
  sudo tee <<EOF >/dev/null /etc/systemd/system/checker.service
[Unit]
Description=Avail Node
After=network-online.target
StartLimitIntervalSec=0
[Service]
User=$USER
Restart=always
RestartSec=3
LimitNOFILE=65535
ExecStart=$HOME/checker/venv/bin/python3 $HOME/checker/checker.py
WorkingDirectory=$HOME/checker
[Install]
WantedBy=multi-user.target
EOF

  sudo systemctl daemon-reload
  sudo systemctl enable checker
  sudo systemctl restart checker
}

function prepare_prometheus {
  CONFIG_FILE="/etc/prometheus/prometheus.yml"

  SCRAPE_CONFIG='
  - job_name: "nodes_ckecker"
    scrape_interval: 30s
    static_configs:
      - targets: ["localhost:19100"]
        labels:
          job: "nodes_ckecker"
'
  #check if configuration already exists
  if grep -q "nodes_ckecker" $CONFIG_FILE; then
      echo "Configuration already exists in $CONFIG_FILE"
      return
  else
    if [ -f "$CONFIG_FILE" ]; then
        echo "  $SCRAPE_CONFIG" >> $CONFIG_FILE
        echo "Configuration added to $CONFIG_FILE"
    else
        echo "Configuration file not found: $CONFIG_FILE"
    fi
  fi

  sudo systemctl restart vmagent
}

function main {
  src_git_repo
  prepare_python_env
  create_systemd
  prepare_prometheus
}

main
