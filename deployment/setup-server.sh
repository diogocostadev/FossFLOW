#!/bin/bash

# Script de configuração do FossFLOW no servidor
# Este script configura apenas o Nginx existente para fazer proxy do container

echo "=== Configuração do FossFLOW no Servidor ==="
echo ""

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configurações
NGINX_SITE_NAME="fossflow"
CONTAINER_PORT="8080"
FOSSFLOW_DATA_DIR="/opt/fossflow/data"

# 1. Criar diretório de dados
echo -e "${YELLOW}1. Criando diretório de dados...${NC}"
sudo mkdir -p $FOSSFLOW_DATA_DIR
sudo chmod 755 $FOSSFLOW_DATA_DIR
echo -e "${GREEN}✓ Diretório criado: $FOSSFLOW_DATA_DIR${NC}"
echo ""

# 2. Configurar autenticação (opcional)
echo -e "${YELLOW}2. Configurar autenticação básica?${NC}"
read -p "Deseja configurar autenticação? (s/n): " SETUP_AUTH

if [ "$SETUP_AUTH" = "s" ] || [ "$SETUP_AUTH" = "S" ]; then
    echo "Criando arquivo de senhas..."
    read -p "Digite o nome de usuário: " USERNAME
    sudo htpasswd -c /etc/nginx/.fossflow_htpasswd $USERNAME
    echo -e "${GREEN}✓ Autenticação configurada${NC}"
else
    echo -e "${YELLOW}⚠ Autenticação não configurada${NC}"
    echo "Remova as linhas auth_basic do arquivo fossflow.conf"
fi
echo ""

# 3. Copiar configuração do Nginx
echo -e "${YELLOW}3. Configurando Nginx...${NC}"
read -p "Digite o domínio ou subdomínio (ex: fossflow.exemplo.com.br): " DOMAIN

# Copiar e ajustar configuração
sudo cp fossflow.conf /etc/nginx/sites-available/$NGINX_SITE_NAME
sudo sed -i "s/fossflow.seudominio.com.br/$DOMAIN/g" /etc/nginx/sites-available/$NGINX_SITE_NAME

# Se não quiser autenticação, remover as linhas
if [ "$SETUP_AUTH" != "s" ] && [ "$SETUP_AUTH" != "S" ]; then
    sudo sed -i '/auth_basic/d' /etc/nginx/sites-available/$NGINX_SITE_NAME
fi

# Ativar site
sudo ln -sf /etc/nginx/sites-available/$NGINX_SITE_NAME /etc/nginx/sites-enabled/

# Testar configuração
sudo nginx -t
if [ $? -eq 0 ]; then
    sudo systemctl reload nginx
    echo -e "${GREEN}✓ Nginx configurado com sucesso${NC}"
else
    echo -e "${RED}✗ Erro na configuração do Nginx${NC}"
    exit 1
fi
echo ""

# 4. Instruções para iniciar o container
echo -e "${YELLOW}4. Instruções para iniciar o FossFLOW:${NC}"
echo ""
echo "Execute o seguinte comando Docker:"
echo ""
echo -e "${GREEN}docker run -d \\"
echo "  --name fossflow \\"
echo "  --restart unless-stopped \\"
echo "  -p $CONTAINER_PORT:80 \\"
echo "  -v $FOSSFLOW_DATA_DIR:/data/diagrams \\"
echo "  -e NODE_ENV=production \\"
echo "  -e ENABLE_SERVER_STORAGE=true \\"
echo "  -e STORAGE_PATH=/data/diagrams \\"
echo "  stnsmith/fossflow:latest${NC}"
echo ""
echo "Ou use o script docker-run.sh incluído nesta pasta"
echo ""

# 5. Configurar SSL (opcional)
echo -e "${YELLOW}5. Configurar SSL com Let's Encrypt?${NC}"
read -p "Deseja configurar HTTPS agora? (s/n): " SETUP_SSL

if [ "$SETUP_SSL" = "s" ] || [ "$SETUP_SSL" = "S" ]; then
    sudo certbot --nginx -d $DOMAIN
    echo -e "${GREEN}✓ SSL configurado${NC}"
else
    echo ""
    echo "Para configurar SSL mais tarde, execute:"
    echo "sudo certbot --nginx -d $DOMAIN"
fi

echo ""
echo -e "${GREEN}=== Configuração Concluída ===${NC}"
echo ""
echo "Próximos passos:"
echo "1. Inicie o container: ./docker-run.sh"
echo "2. Acesse: http://$DOMAIN"
echo ""
echo "Comandos úteis:"
echo "- Ver logs: docker logs fossflow"
echo "- Parar: docker stop fossflow"
echo "- Reiniciar: docker restart fossflow"