#!/bin/bash

# FossFLOW Docker Run Script
# Para executar no servidor ou Jenkins

# Configurações
CONTAINER_NAME="fossflow"
IMAGE="stnsmith/fossflow:latest"
PORT="${PORT:-8080}"  # Porta interna - Nginx fará proxy desta porta
DATA_DIR="${DATA_DIR:-/opt/fossflow/data}"
ENABLE_SERVER_STORAGE="${ENABLE_SERVER_STORAGE:-true}"
ENABLE_GIT_BACKUP="${ENABLE_GIT_BACKUP:-false}"

# Para o container se já estiver rodando
echo "Parando container existente..."
docker stop $CONTAINER_NAME 2>/dev/null || true
docker rm $CONTAINER_NAME 2>/dev/null || true

# Cria diretório de dados se não existir
mkdir -p $DATA_DIR

# Atualiza a imagem
echo "Baixando última versão da imagem..."
docker pull $IMAGE

# Executa o container
echo "Iniciando FossFLOW..."
docker run -d \
  --name $CONTAINER_NAME \
  --restart unless-stopped \
  -p $PORT:80 \
  -v $DATA_DIR:/data/diagrams \
  -e NODE_ENV=production \
  -e ENABLE_SERVER_STORAGE=$ENABLE_SERVER_STORAGE \
  -e STORAGE_PATH=/data/diagrams \
  -e ENABLE_GIT_BACKUP=$ENABLE_GIT_BACKUP \
  $IMAGE

# Verifica se iniciou corretamente
sleep 5
if docker ps | grep -q $CONTAINER_NAME; then
    echo "✓ FossFLOW iniciado com sucesso na porta $PORT"
    echo "✓ Dados armazenados em: $DATA_DIR"
    docker logs --tail 20 $CONTAINER_NAME
else
    echo "✗ Erro ao iniciar FossFLOW"
    docker logs $CONTAINER_NAME
    exit 1
fi