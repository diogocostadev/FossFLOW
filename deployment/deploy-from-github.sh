#!/bin/bash

# Script para deploy direto do GitHub
# Atualiza automaticamente quando houver mudanças no repositório

echo "=== FossFLOW Deploy from GitHub ==="
echo ""

# Configurações
GITHUB_REPO="https://github.com/diogocostadev/FossFLOW.git"
COMPOSE_FILE="docker-compose.yml"
CONTAINER_NAME="fossflow"
DATA_DIR="/opt/fossflow/data"

# Cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# 1. Criar diretório de dados se não existir
echo -e "${YELLOW}Preparando diretórios...${NC}"
sudo mkdir -p $DATA_DIR
sudo chmod 755 $DATA_DIR
echo -e "${GREEN}✓ Diretório de dados: $DATA_DIR${NC}"
echo ""

# 2. Parar container existente se houver
if docker ps -a | grep -q $CONTAINER_NAME; then
    echo -e "${YELLOW}Parando container existente...${NC}"
    docker-compose -f $COMPOSE_FILE down
    echo -e "${GREEN}✓ Container parado${NC}"
fi

# 3. Limpar cache de build para forçar atualização
echo -e "${YELLOW}Limpando cache de build...${NC}"
docker-compose -f $COMPOSE_FILE build --no-cache --pull
echo -e "${GREEN}✓ Nova imagem construída do GitHub${NC}"
echo ""

# 4. Iniciar serviço
echo -e "${YELLOW}Iniciando FossFLOW...${NC}"
docker-compose -f $COMPOSE_FILE up -d

# 5. Verificar se iniciou corretamente
sleep 5
if docker ps | grep -q $CONTAINER_NAME; then
    echo ""
    echo -e "${GREEN}=== FossFLOW iniciado com sucesso! ===${NC}"
    echo ""
    echo "Informações:"
    echo "- URL: http://localhost:8080"
    echo "- Dados: $DATA_DIR"
    echo "- Container: $CONTAINER_NAME"
    echo "- Fonte: $GITHUB_REPO"
    echo ""
    echo "Logs recentes:"
    docker logs --tail 10 $CONTAINER_NAME
else
    echo -e "${RED}✗ Erro ao iniciar FossFLOW${NC}"
    echo "Verifique os logs:"
    docker logs $CONTAINER_NAME
    exit 1
fi

echo ""
echo "Comandos úteis:"
echo "- Ver logs: docker logs -f $CONTAINER_NAME"
echo "- Parar: docker-compose down"
echo "- Atualizar: ./deploy-from-github.sh"
echo "- Status: docker ps | grep $CONTAINER_NAME"