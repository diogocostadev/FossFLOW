#!/bin/bash

# Script para atualizar FossFLOW com as últimas mudanças do GitHub
# Preserva os dados existentes

echo "=== Atualizando FossFLOW do GitHub ==="
echo ""

COMPOSE_FILE="docker-compose.yml"
CONTAINER_NAME="fossflow"

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 1. Fazer backup dos dados (opcional)
echo -e "${YELLOW}Fazendo backup dos dados...${NC}"
BACKUP_DIR="/opt/fossflow/backups/$(date +%Y%m%d_%H%M%S)"
sudo mkdir -p $BACKUP_DIR
sudo cp -r /opt/fossflow/data/* $BACKUP_DIR/ 2>/dev/null || true
echo -e "${GREEN}✓ Backup salvo em: $BACKUP_DIR${NC}"
echo ""

# 2. Pull das mudanças e rebuild
echo -e "${YELLOW}Baixando atualizações do GitHub...${NC}"
docker-compose -f $COMPOSE_FILE build --pull --no-cache
echo -e "${GREEN}✓ Atualização baixada${NC}"
echo ""

# 3. Reiniciar com zero downtime
echo -e "${YELLOW}Aplicando atualização...${NC}"
docker-compose -f $COMPOSE_FILE up -d --force-recreate
echo -e "${GREEN}✓ FossFLOW atualizado!${NC}"
echo ""

# 4. Limpar imagens antigas
echo -e "${YELLOW}Limpando imagens antigas...${NC}"
docker image prune -f
echo -e "${GREEN}✓ Limpeza concluída${NC}"

echo ""
echo "Atualização completa!"
echo "Verificar logs: docker logs -f $CONTAINER_NAME"