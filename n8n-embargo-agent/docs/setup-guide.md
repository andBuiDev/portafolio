# Guía de Instalación - Agente de Búsqueda de Embargos

Esta guía te ayudará a instalar y configurar el agente de búsqueda de embargos con n8n paso a paso.

## Prerrequisitos

### Software Requerido

- **Node.js** 18.x o superior
- **PostgreSQL** 12.x o superior
- **n8n** 1.0.x o superior
- **Git** para clonar el repositorio

### Verificar Instalaciones

```bash
# Verificar Node.js
node --version

# Verificar PostgreSQL
psql --version

# Verificar n8n (si ya está instalado)
n8n --version
```

## Paso 1: Preparar la Base de Datos

### 1.1 Crear la Base de Datos

```bash
# Conectar a PostgreSQL como superusuario
sudo -u postgres psql

# Crear base de datos y usuario
CREATE DATABASE embargos_db;
CREATE USER embargo_user WITH PASSWORD 'tu_password_seguro';
GRANT ALL PRIVILEGES ON DATABASE embargos_db TO embargo_user;
\q
```

### 1.2 Ejecutar el Schema

```bash
# Navegar al directorio del proyecto
cd n8n-embargo-agent

# Ejecutar el schema
psql -h localhost -U embargo_user -d embargos_db -f database/schema.sql

# Cargar datos de ejemplo
psql -h localhost -U embargo_user -d embargos_db -f database/sample-data.sql
```

### 1.3 Verificar la Instalación

```bash
# Conectar a la base de datos
psql -h localhost -U embargo_user -d embargos_db

# Verificar tablas creadas
\dt

# Verificar datos de ejemplo
SELECT COUNT(*) FROM personas;
SELECT COUNT(*) FROM embargos;
SELECT COUNT(*) FROM alternativas_pago;
\q
```

## Paso 2: Instalar y Configurar n8n

### 2.1 Instalar n8n Globalmente

```bash
# Instalar n8n
npm install -g n8n

# Verificar instalación
n8n --version
```

### 2.2 Configurar Variables de Entorno

Crear archivo `.env` en el directorio raíz:

```bash
# Copiar archivo de ejemplo
cp .env.example .env

# Editar variables
nano .env
```

Contenido del archivo `.env`:

```env
# Base de Datos
DB_HOST=localhost
DB_PORT=5432
DB_NAME=embargos_db
DB_USER=embargo_user
DB_PASSWORD=tu_password_seguro

# n8n Configuration
N8N_HOST=0.0.0.0
N8N_PORT=5678
N8N_PROTOCOL=http
N8N_WEBHOOK_URL=http://localhost:5678

# Autenticación Básica (Opcional)
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=admin_password

# Configuración de Datos
N8N_USER_FOLDER=/home/n8n/.n8n
N8N_LOG_LEVEL=info

# Configuración de Webhook
WEBHOOK_URL=http://localhost:5678/webhook
```

### 2.3 Iniciar n8n

```bash
# Cargar variables de entorno
source .env

# Iniciar n8n
n8n start

# O en modo desarrollo
n8n start --tunnel
```

## Paso 3: Configurar el Workflow

### 3.1 Acceder a la Interfaz Web

Abrir navegador en: `http://localhost:5678`

### 3.2 Crear Credenciales de Base de Datos

1. Ir a **Settings** → **Credentials**
2. Hacer clic en **Add Credential**
3. Seleccionar **Postgres**
4. Configurar:
   - **Name**: `PostgreSQL Embargos`
   - **Host**: `localhost`
   - **Database**: `embargos_db`
   - **User**: `embargo_user`
   - **Password**: `tu_password_seguro`
   - **Port**: `5432`
5. Hacer clic en **Save**

### 3.3 Importar el Workflow

1. Ir a **Workflows** → **Add Workflow**
2. Hacer clic en **Import from File**
3. Seleccionar `workflows/embargo-search-workflow.json`
4. Hacer clic en **Import**

### 3.4 Configurar Nodos

1. Verificar que todos los nodos PostgreSQL tengan asignada la credencial creada
2. Activar el workflow haciendo clic en **Active**

## Paso 4: Probar el Sistema

### 4.1 Obtener URL del Webhook

En el nodo "Webhook - Recibir Búsqueda", copiar la URL del webhook.

### 4.2 Realizar Pruebas

#### Búsqueda por Documento

```bash
curl -X POST http://localhost:5678/webhook/buscar-embargo \
  -H "Content-Type: application/json" \
  -d '{
    "tipo_busqueda": "documento",
    "valor": "12345678"
  }'
```

#### Búsqueda por Nombre

```bash
curl -X POST http://localhost:5678/webhook/buscar-embargo \
  -H "Content-Type: application/json" \
  -d '{
    "tipo_busqueda": "nombre",
    "valor": "Juan Pérez"
  }'
```

### 4.3 Verificar Respuestas

**Persona con Embargo:**
```json
{
  "encontrado": true,
  "persona": {
    "id": 1,
    "nombre": "Juan Carlos Pérez García",
    "documento": "12345678",
    "tipo_documento": "CC"
  },
  "embargo": {
    "activo": true,
    "monto_total": 5000000,
    "cantidad": 1
  },
  "alternativas": [
    {
      "tipo": "plan_pagos",
      "descripcion": "Plan de pagos a 12 meses con 10% de descuento",
      "monto_final": 4500000,
      "cuota_mensual": 375000
    }
  ]
}
```

## Paso 5: Configuración de Producción

### 5.1 Usar PM2 para Proceso en Background

```bash
# Instalar PM2
npm install -g pm2

# Crear archivo de configuración
cat > ecosystem.config.js << EOF
module.exports = {
  apps: [{
    name: 'n8n-embargo-agent',
    script: 'n8n',
    args: 'start',
    env: {
      NODE_ENV: 'production',
      N8N_HOST: '0.0.0.0',
      N8N_PORT: 5678,
      DB_HOST: 'localhost',
      DB_NAME: 'embargos_db',
      DB_USER: 'embargo_user',
      DB_PASSWORD: 'tu_password_seguro'
    }
  }]
}
EOF

# Iniciar con PM2
pm2 start ecosystem.config.js

# Configurar inicio automático
pm2 startup
pm2 save
```

### 5.2 Configurar Nginx (Opcional)

```bash
# Instalar Nginx
sudo apt install nginx

# Crear configuración
sudo nano /etc/nginx/sites-available/embargo-agent
```

Contenido del archivo de configuración:

```nginx
server {
    listen 80;
    server_name tu-dominio.com;

    location / {
        proxy_pass http://localhost:5678;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

```bash
# Habilitar sitio
sudo ln -s /etc/nginx/sites-available/embargo-agent /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

## Paso 6: Monitoreo y Logs

### 6.1 Verificar Logs de n8n

```bash
# Ver logs en tiempo real
pm2 logs n8n-embargo-agent

# Ver logs de base de datos
sudo tail -f /var/log/postgresql/postgresql-*.log
```

### 6.2 Configurar Alertas

Crear script de monitoreo:

```bash
#!/bin/bash
# monitor-embargo-agent.sh

# Verificar si n8n está corriendo
if ! pm2 describe n8n-embargo-agent > /dev/null 2>&1; then
    echo "ALERTA: n8n-embargo-agent no está corriendo"
    pm2 restart n8n-embargo-agent
fi

# Verificar conectividad de base de datos
if ! pg_isready -h localhost -p 5432 -d embargos_db -U embargo_user; then
    echo "ALERTA: Base de datos no disponible"
fi

# Verificar endpoint
if ! curl -f http://localhost:5678/health > /dev/null 2>&1; then
    echo "ALERTA: Endpoint no responde"
fi
```

```bash
# Hacer ejecutable
chmod +x monitor-embargo-agent.sh

# Agregar a crontab (cada 5 minutos)
crontab -e
# Agregar: */5 * * * * /path/to/monitor-embargo-agent.sh
```

## Troubleshooting

### Problemas Comunes

#### Error de Conexión a Base de Datos

```bash
# Verificar estado de PostgreSQL
sudo systemctl status postgresql

# Verificar configuración de conexión
psql -h localhost -U embargo_user -d embargos_db -c "SELECT 1;"
```

#### n8n No Inicia

```bash
# Verificar puerto disponible
netstat -tulpn | grep :5678

# Verificar logs
pm2 logs n8n-embargo-agent --lines 100
```

#### Webhook No Responde

1. Verificar que el workflow esté activo
2. Verificar URL del webhook en la interfaz de n8n
3. Verificar logs de ejecución en n8n

### Comandos Útiles

```bash
# Reiniciar servicios
pm2 restart n8n-embargo-agent
sudo systemctl restart postgresql

# Verificar estado
pm2 status
sudo systemctl status postgresql

# Limpiar logs
pm2 flush n8n-embargo-agent

# Backup de base de datos
pg_dump -h localhost -U embargo_user embargos_db > backup_$(date +%Y%m%d).sql
```

## Soporte

Para obtener ayuda adicional:

1. Revisar logs detallados
2. Consultar documentación oficial de n8n
3. Verificar configuración de base de datos
4. Revisar variables de entorno

---

¡El agente de búsqueda de embargos está listo para usar! 🎉