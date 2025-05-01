#!/bin/bash

# Configurações
REPO_DIR="."                  # Caminho para o diretório do repositório
APP_NAME="api.b3erp.com.br"   # Nome da aplicação no PM2
DEPLOY_DIR="../nodepapp"      # Caminho para o diretório de deploy

# Navega até o diretório do repositório
cd "$REPO_DIR" || { echo "Diretório $REPO_DIR não encontrado."; exit 1; }

# Atualiza o repositório
echo "Atualizando repositório..."
git pull origin main || { echo "Falha ao atualizar o repositório."; exit 1; }

# Instala dependências
echo "Instalando dependências..."
npm install || { echo "Falha ao instalar dependências."; exit 1; }

# Compila a aplicação
echo "Compilando a aplicação..."
npm run build || { echo "Falha na compilação da aplicação."; exit 1; }

# Para a aplicação no PM2
echo "Parando a aplicação no PM2..."
pm2 stop "$APP_NAME" || echo "Aplicação não estava em execução."

# Remove diretórios e arquivos antigos
echo "Removendo arquivos antigos..."
rm -rf "$DEPLOY_DIR/dist" "$DEPLOY_DIR/node_modules" \
       "$DEPLOY_DIR/package.json" "$DEPLOY_DIR/package-lock.json"

# Copia os novos arquivos e pastas para o diretório de deploy
echo "Copiando arquivos atualizados para o diretório de deploy..."
cp -r "$REPO_DIR/dist" "$REPO_DIR/node_modules" "$REPO_DIR/package.json" "$REPO_DIR/package-lock.json" "$DEPLOY_DIR/"

# Inicia a aplicação no PM2
echo "Iniciando a aplicação no PM2..."
pm2 restart "$APP_NAME" || echo { echo "Falha ao iniciar a aplicação no PM2."; exit 1; }

echo "Deploy concluído com sucesso!"
