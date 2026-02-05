#!/bin/bash
# Script para monitorar a divisão de tráfego do Canary
# Uso: ./watch-traffic.sh

URL="http://localhost:8888"

echo "Iniciando monitoramento de tráfego em $URL..."
echo "Pressione CTRL+C para parar."
echo "---------------------------------------------"

while true; do
  # Faz a requisição e extrai o HTTP Code e o corpo
  response=$(curl -s -w "%{http_code}" $URL)
  http_code=${response: -3}
  body=${response:0:${#response}-3}

  # Data/Hora atual
  timestamp=$(date +"%H:%M:%S")

  if [ "$http_code" -eq 200 ]; then
    # Tenta extrair a versão do JSON (requer jq ou grep simples)
    if command -v jq &> /dev/null; then
      version=$(echo $body | jq -r .version)
    else
      # Fallback simples se não tiver jq
      version=$(echo $body | grep -o '"version":"[^"]*"' | cut -d'"' -f4)
    fi
    
    # Cores baseadas na versão (apenas visual)
    if [[ "$version" == "1.0.0" ]]; then
       COLOR="\033[0;34m" # Blue
    elif [[ "$version" == "2.0.0" ]]; then
       COLOR="\033[0;32m" # Green
    else
       COLOR="\033[0;33m" # Yellow (outras versões)
    fi
    NC="\033[0m" # No Color

    echo -e "[$timestamp] Status: $http_code | Versão: ${COLOR}${version}${NC}"
  else
    echo "[$timestamp] Erro: $http_code"
  fi

  sleep 3
done
