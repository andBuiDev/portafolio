# Agente de Búsqueda de Embargos con n8n

Este proyecto implementa un agente automatizado que utiliza n8n para buscar personas por nombre o documento en una base de datos y verificar si tienen embargos activos.

## Características

- 🔍 Búsqueda por nombre completo o número de documento
- 💰 Verificación de embargos activos
- 📊 Información detallada del monto embargado
- 🔄 Alternativas automáticas para casos embargados
- 📱 API REST para integración con otros sistemas
- 🔔 Notificaciones automáticas

## Estructura del Proyecto

```
n8n-embargo-agent/
├── workflows/
│   └── embargo-search-workflow.json
├── database/
│   ├── schema.sql
│   └── sample-data.sql
├── config/
│   └── n8n-config.json
├── docs/
│   ├── setup-guide.md
│   └── api-documentation.md
└── README.md
```

## Requisitos Previos

- n8n instalado (versión 1.0+)
- Base de datos PostgreSQL o MySQL
- Node.js 18+
- Docker (opcional)

## Instalación

### 1. Clonar el repositorio
```bash
git clone <repository-url>
cd n8n-embargo-agent
```

### 2. Configurar la base de datos
```bash
# Crear la base de datos
createdb embargos_db

# Ejecutar el schema
psql embargos_db < database/schema.sql

# Cargar datos de ejemplo
psql embargos_db < database/sample-data.sql
```

### 3. Configurar n8n
```bash
# Instalar n8n si no está instalado
npm install -g n8n

# Importar el workflow
# Copiar el contenido de workflows/embargo-search-workflow.json
# e importarlo en la interfaz de n8n
```

## Uso

### API Endpoints

#### Búsqueda por Documento
```http
POST /webhook/buscar-embargo
Content-Type: application/json

{
  "tipo_busqueda": "documento",
  "valor": "12345678"
}
```

#### Búsqueda por Nombre
```http
POST /webhook/buscar-embargo
Content-Type: application/json

{
  "tipo_busqueda": "nombre",
  "valor": "Juan Pérez"
}
```

### Respuesta de Ejemplo

```json
{
  "encontrado": true,
  "persona": {
    "id": 1,
    "nombre": "Juan Pérez García",
    "documento": "12345678",
    "tipo_documento": "CC"
  },
  "embargo": {
    "activo": true,
    "monto": 5000000,
    "fecha_inicio": "2023-01-15",
    "entidad": "DIAN",
    "tipo": "Tributario"
  },
  "alternativas": [
    {
      "tipo": "plan_pagos",
      "descripcion": "Plan de pagos a 12 meses",
      "monto_inicial": 500000,
      "cuota_mensual": 416667
    },
    {
      "tipo": "descuento",
      "descripcion": "Descuento por pronto pago (15%)",
      "monto_final": 4250000
    }
  ]
}
```

## Configuración

### Variables de Entorno

Crear un archivo `.env` con las siguientes variables:

```env
DB_HOST=localhost
DB_PORT=5432
DB_NAME=embargos_db
DB_USER=postgres
DB_PASSWORD=your_password
N8N_WEBHOOK_URL=http://localhost:5678
```

## Contribución

1. Fork el proyecto
2. Crear una rama para tu feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit tus cambios (`git commit -am 'Agregar nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Crear un Pull Request

## Licencia

MIT License - ver el archivo LICENSE para más detalles.