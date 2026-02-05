#!/bin/bash
# Script para monitorar a divisão de tráfego do Canary

echo "Iniciando monitoramento via pod temporário no cluster (kubectl)..."
echo "Pressione CTRL+C para parar."
echo "---------------------------------------------"

trap "sudo kubectl delete pod tester --ignore-not-found=true > /dev/null 2>&1; exit" SIGINT SIGTERM

sudo kubectl delete pod tester --ignore-not-found=true > /dev/null 2>&1

sudo kubectl run --attach --quiet --rm --restart=Never \
    --image=curlimages/curl tester -- \
    sh -c '
        while true; do 
            curl -s http://argo-canary/ | grep version; 
            sleep 0.2; 
        done
    ' 2>/dev/null | {
  
  declare -A VERSION_COLORS
  COLORS=("\033[0;34m" "\033[0;32m" "\033[0;33m" "\033[0;35m" "\033[0;36m")
  COLOR_IDX=0
  NC="\033[0m"
  
  # Variável para rastrear a última versão vista
  LAST_VERSION=""

  while read -r line; do
    timestamp=$(date +"%H:%M:%S")
    version=$(echo "$line" | grep -o '"version":"[^"]*"' | cut -d'"' -f4)
    
    if [[ -z "$version" ]]; then
       continue
    fi

    # --- LÓGICA DE QUEBRA DE LINHA ---
    # Se já houve uma versão anterior e ela é diferente da atual
    if [[ -n "$LAST_VERSION" && "$version" != "$LAST_VERSION" ]]; then
         echo "---------------------------------------------" # Ou apenas echo ""
    fi
    LAST_VERSION="$version"
    # ---------------------------------

    if [[ -z "${VERSION_COLORS[$version]}" ]]; then
         VERSION_COLORS[$version]="${COLORS[$COLOR_IDX]}"
         COLOR_IDX=$(( (COLOR_IDX + 1) % ${#COLORS[@]} ))
    fi

    COLOR="${VERSION_COLORS[$version]}"
    echo -e "[$timestamp] Versão: ${COLOR}${version}${NC}"
  done
}