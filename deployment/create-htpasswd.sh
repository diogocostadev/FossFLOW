#!/bin/bash

# Script para criar arquivo .htpasswd para autenticação básica

echo "=== Criando autenticação para FossFLOW ==="

# Verifica se htpasswd está instalado
if ! command -v htpasswd &> /dev/null; then
    echo "htpasswd não encontrado. Instalando..."
    
    # Detecta o sistema operacional
    if [ -f /etc/debian_version ]; then
        sudo apt-get update && sudo apt-get install -y apache2-utils
    elif [ -f /etc/redhat-release ]; then
        sudo yum install -y httpd-tools
    else
        echo "Sistema não suportado. Instale apache2-utils ou httpd-tools manualmente."
        exit 1
    fi
fi

# Cria o arquivo .htpasswd
echo "Criando usuário para acesso ao FossFLOW..."
read -p "Digite o nome de usuário: " USERNAME

if [ -f .htpasswd ]; then
    echo "Adicionando usuário ao arquivo existente..."
    htpasswd .htpasswd $USERNAME
else
    echo "Criando novo arquivo .htpasswd..."
    htpasswd -c .htpasswd $USERNAME
fi

echo ""
echo "✓ Arquivo .htpasswd criado/atualizado com sucesso!"
echo ""
echo "Para adicionar mais usuários, execute:"
echo "  htpasswd .htpasswd novo_usuario"
echo ""
echo "Para remover um usuário:"
echo "  htpasswd -D .htpasswd usuario_a_remover"