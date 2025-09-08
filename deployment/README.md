# FossFLOW - Deploy no Servidor

## Arquivos

- `docker-run.sh` - Script para rodar o container Docker (imagem pronta)
- `docker-compose.yml` - Build direto do GitHub
- `deploy-from-github.sh` - Deploy automático do GitHub
- `update-from-github.sh` - Atualizar com últimas mudanças
- `fossflow.conf` - Configuração do Nginx (proxy reverso)
- `setup-server.sh` - Script de configuração automática
- `create-htpasswd.sh` - Criar usuários para autenticação

## Opção 1: Deploy Direto do GitHub (Recomendado)

Builda direto do seu fork no GitHub:

```bash
cd deployment
chmod +x *.sh

# Configurar Nginx
sudo ./setup-server.sh

# Deploy do GitHub
./deploy-from-github.sh
```

Para atualizar com mudanças do GitHub:
```bash
./update-from-github.sh
```

## Opção 2: Usando Docker Compose

```bash
# Build e iniciar direto do GitHub
docker-compose up -d --build

# Ou em desenvolvimento
docker-compose -f docker-compose-dev.yml up -d
```

## Opção 3: Instalação com Imagem Pronta

```bash
# 1. No servidor, execute:
cd deployment
chmod +x *.sh

# 2. Configurar Nginx (já existente no servidor):
sudo ./setup-server.sh

# 3. Iniciar FossFLOW:
./docker-run.sh
```

## Configuração Manual do Nginx

1. Copie a configuração:
```bash
sudo cp fossflow.conf /etc/nginx/sites-available/fossflow
```

2. Ajuste o domínio:
```bash
sudo nano /etc/nginx/sites-available/fossflow
# Trocar fossflow.seudominio.com.br pelo seu domínio
```

3. Ative o site:
```bash
sudo ln -s /etc/nginx/sites-available/fossflow /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

4. (Opcional) Criar autenticação:
```bash
sudo htpasswd -c /etc/nginx/.fossflow_htpasswd usuario
```

## Jenkins - Configuração

### Para build do GitHub (recomendado):
```bash
#!/bin/bash
cd /caminho/para/deployment
./deploy-from-github.sh
```

### Para atualização periódica:
```bash
#!/bin/bash
cd /caminho/para/deployment
./update-from-github.sh
```

### Para imagem pronta:
```bash
#!/bin/bash
cd /caminho/para/deployment
./docker-run.sh
```

## Variáveis de Ambiente

No `docker-run.sh` você pode configurar:

- `PORT=8080` - Porta interna do container (Nginx fará proxy)
- `DATA_DIR=/opt/fossflow/data` - Onde salvar os diagramas
- `ENABLE_SERVER_STORAGE=true` - Habilitar salvamento no servidor
- `ENABLE_GIT_BACKUP=false` - Backup via Git

## SSL/HTTPS

Para adicionar certificado SSL:

```bash
sudo certbot --nginx -d seu-dominio.com.br
```

## Comandos Úteis

```bash
# Ver logs
docker logs -f fossflow

# Status
docker ps | grep fossflow

# Parar
docker stop fossflow

# Reiniciar
docker restart fossflow

# Remover
docker rm fossflow
```

## Estrutura

```
Nginx (porta 80/443) 
    ↓ proxy_pass
Docker Container (porta 8080)
    ↓ volume mount
/opt/fossflow/data (persistência)
```