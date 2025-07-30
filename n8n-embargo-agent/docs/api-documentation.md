# Documentación de API - Agente de Búsqueda de Embargos

Esta documentación describe la API REST del agente de búsqueda de embargos implementado con n8n.

## Información General

- **URL Base**: `http://localhost:5678/webhook`
- **Formato**: JSON
- **Método**: POST
- **Content-Type**: `application/json`

## Endpoints

### Búsqueda de Embargos

**Endpoint**: `/buscar-embargo`

**Método**: `POST`

**Descripción**: Busca una persona por documento o nombre y verifica si tiene embargos activos.

#### Request

**Headers**:
```http
Content-Type: application/json
```

**Body**:
```json
{
  "tipo_busqueda": "documento|nombre",
  "valor": "string"
}
```

**Parámetros**:

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `tipo_busqueda` | string | Sí | Tipo de búsqueda: "documento" o "nombre" |
| `valor` | string | Sí | Valor a buscar (número de documento o nombre) |

#### Responses

##### 200 OK - Persona Encontrada Sin Embargo

```json
{
  "encontrado": true,
  "persona": {
    "id": 2,
    "nombre": "María Elena González López",
    "documento": "87654321",
    "tipo_documento": "CC",
    "telefono": "3009876543",
    "email": "maria.gonzalez@email.com",
    "ciudad": "Medellín"
  },
  "embargo": {
    "activo": false,
    "cantidad": 0,
    "monto_total": 0,
    "embargos": []
  },
  "alternativas": [],
  "resumen": {
    "tiene_embargos": false,
    "monto_total": 0,
    "cantidad_embargos": 0,
    "alternativas_disponibles": 0,
    "mejor_descuento": 0
  },
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

##### 200 OK - Persona Encontrada Con Embargo

```json
{
  "encontrado": true,
  "persona": {
    "id": 1,
    "nombre": "Juan Carlos Pérez García",
    "documento": "12345678",
    "tipo_documento": "CC",
    "telefono": "3001234567",
    "email": "juan.perez@email.com",
    "ciudad": "Bogotá"
  },
  "embargo": {
    "activo": true,
    "cantidad": 1,
    "monto_total": 5000000,
    "embargos": [
      {
        "id": 1,
        "monto": 5000000,
        "monto_original": 5000000,
        "fecha_inicio": "2023-01-15",
        "fecha_vencimiento": "2025-01-15",
        "entidad": "DIAN",
        "tipo": "Tributario",
        "descripcion": "Deuda por impuestos no pagados período 2022",
        "numero_proceso": "DIAN-2023-001",
        "juzgado": "Juzgado Administrativo de Bogotá"
      }
    ]
  },
  "alternativas": [
    {
      "id": 1,
      "embargo_id": 1,
      "tipo": "plan_pagos",
      "descripcion": "Plan de pagos a 12 meses con 10% de descuento",
      "monto_inicial": 450000,
      "monto_final": 4500000,
      "cuota_mensual": 375000,
      "numero_cuotas": 12,
      "descuento_porcentaje": 10,
      "fecha_limite": "2024-12-31"
    },
    {
      "id": 2,
      "embargo_id": 1,
      "tipo": "descuento_pronto_pago",
      "descripcion": "Descuento por pronto pago (20%)",
      "monto_inicial": null,
      "monto_final": 4000000,
      "cuota_mensual": null,
      "numero_cuotas": null,
      "descuento_porcentaje": 20,
      "fecha_limite": "2024-06-30"
    }
  ],
  "resumen": {
    "tiene_embargos": true,
    "monto_total": 5000000,
    "cantidad_embargos": 1,
    "alternativas_disponibles": 2,
    "mejor_descuento": 20
  },
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

##### 200 OK - Múltiples Personas Encontradas

```json
{
  "encontrado": true,
  "multiple": true,
  "mensaje": "Se encontraron 3 personas que coinciden con la búsqueda",
  "personas": [
    {
      "id": 1,
      "nombre": "Juan Carlos Pérez García",
      "documento": "12345678",
      "tipo_documento": "CC"
    },
    {
      "id": 8,
      "nombre": "Juan Manuel Pérez Rodríguez",
      "documento": "99887755",
      "tipo_documento": "CC"
    }
  ],
  "busqueda": {
    "tipo_busqueda": "nombre",
    "valor": "Juan Pérez",
    "ip_origen": "192.168.1.100",
    "timestamp": "2024-01-15T10:30:00.000Z"
  },
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

##### 200 OK - Persona No Encontrada

```json
{
  "encontrado": false,
  "mensaje": "No se encontraron registros con los criterios de búsqueda",
  "busqueda": {
    "tipo_busqueda": "documento",
    "valor": "99999999",
    "ip_origen": "192.168.1.100",
    "timestamp": "2024-01-15T10:30:00.000Z"
  },
  "personas": [],
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

##### 400 Bad Request - Error de Validación

```json
{
  "error": true,
  "mensaje": "Faltan campos requeridos: tipo_busqueda y valor",
  "codigo": "INVALID_INPUT"
}
```

```json
{
  "error": true,
  "mensaje": "tipo_busqueda debe ser 'documento' o 'nombre'",
  "codigo": "INVALID_SEARCH_TYPE"
}
```

```json
{
  "error": true,
  "mensaje": "El documento debe tener al menos 6 dígitos",
  "codigo": "INVALID_DOCUMENT"
}
```

```json
{
  "error": true,
  "mensaje": "El nombre debe tener al menos 3 caracteres",
  "codigo": "INVALID_NAME"
}
```

## Ejemplos de Uso

### cURL

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

### JavaScript (fetch)

```javascript
const buscarEmbargo = async (tipoBusqueda, valor) => {
  try {
    const response = await fetch('http://localhost:5678/webhook/buscar-embargo', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        tipo_busqueda: tipoBusqueda,
        valor: valor
      })
    });
    
    const data = await response.json();
    
    if (data.error) {
      console.error('Error:', data.mensaje);
      return null;
    }
    
    return data;
  } catch (error) {
    console.error('Error de red:', error);
    return null;
  }
};

// Ejemplo de uso
buscarEmbargo('documento', '12345678')
  .then(resultado => {
    if (resultado) {
      console.log('Resultado:', resultado);
      
      if (resultado.embargo.activo) {
        console.log(`Embargo encontrado por $${resultado.embargo.monto_total.toLocaleString()}`);
        console.log(`Alternativas disponibles: ${resultado.alternativas.length}`);
      } else {
        console.log('No tiene embargos activos');
      }
    }
  });
```

### Python

```python
import requests
import json

def buscar_embargo(tipo_busqueda, valor):
    url = "http://localhost:5678/webhook/buscar-embargo"
    
    payload = {
        "tipo_busqueda": tipo_busqueda,
        "valor": valor
    }
    
    headers = {
        "Content-Type": "application/json"
    }
    
    try:
        response = requests.post(url, json=payload, headers=headers)
        response.raise_for_status()
        
        data = response.json()
        
        if data.get('error'):
            print(f"Error: {data.get('mensaje')}")
            return None
            
        return data
        
    except requests.exceptions.RequestException as e:
        print(f"Error de red: {e}")
        return None

# Ejemplo de uso
resultado = buscar_embargo('documento', '12345678')

if resultado:
    if resultado['embargo']['activo']:
        print(f"Embargo encontrado por ${resultado['embargo']['monto_total']:,}")
        print(f"Alternativas disponibles: {len(resultado['alternativas'])}")
        
        for alternativa in resultado['alternativas']:
            print(f"- {alternativa['descripcion']}")
            if alternativa['descuento_porcentaje']:
                print(f"  Descuento: {alternativa['descuento_porcentaje']}%")
            if alternativa['cuota_mensual']:
                print(f"  Cuota mensual: ${alternativa['cuota_mensual']:,}")
    else:
        print("No tiene embargos activos")
```

### PHP

```php
<?php
function buscarEmbargo($tipoBusqueda, $valor) {
    $url = "http://localhost:5678/webhook/buscar-embargo";
    
    $data = array(
        'tipo_busqueda' => $tipoBusqueda,
        'valor' => $valor
    );
    
    $options = array(
        'http' => array(
            'header' => "Content-type: application/json\r\n",
            'method' => 'POST',
            'content' => json_encode($data)
        )
    );
    
    $context = stream_context_create($options);
    $result = file_get_contents($url, false, $context);
    
    if ($result === FALSE) {
        return null;
    }
    
    return json_decode($result, true);
}

// Ejemplo de uso
$resultado = buscarEmbargo('documento', '12345678');

if ($resultado) {
    if ($resultado['embargo']['activo']) {
        echo "Embargo encontrado por $" . number_format($resultado['embargo']['monto_total']) . "\n";
        echo "Alternativas disponibles: " . count($resultado['alternativas']) . "\n";
        
        foreach ($resultado['alternativas'] as $alternativa) {
            echo "- " . $alternativa['descripcion'] . "\n";
            if ($alternativa['descuento_porcentaje']) {
                echo "  Descuento: " . $alternativa['descuento_porcentaje'] . "%\n";
            }
        }
    } else {
        echo "No tiene embargos activos\n";
    }
}
?>
```

## Tipos de Alternativas

### plan_pagos
Plan de pagos en cuotas mensuales.

**Campos específicos**:
- `monto_inicial`: Cuota inicial requerida
- `cuota_mensual`: Valor de cada cuota mensual
- `numero_cuotas`: Cantidad de cuotas
- `monto_final`: Monto total a pagar

### descuento_pronto_pago
Descuento por pago inmediato o en plazo corto.

**Campos específicos**:
- `descuento_porcentaje`: Porcentaje de descuento aplicado
- `monto_final`: Monto final después del descuento
- `fecha_limite`: Fecha límite para aplicar el descuento

### refinanciacion
Refinanciación de la deuda con nuevas condiciones.

**Campos específicos**:
- `monto_inicial`: Cuota inicial
- `cuota_mensual`: Nueva cuota mensual
- `numero_cuotas`: Número de cuotas de la refinanciación
- `monto_final`: Monto total refinanciado

## Códigos de Error

| Código | Descripción |
|--------|-------------|
| `INVALID_INPUT` | Faltan campos requeridos |
| `INVALID_SEARCH_TYPE` | Tipo de búsqueda inválido |
| `INVALID_DOCUMENT` | Documento con formato inválido |
| `INVALID_NAME` | Nombre muy corto o inválido |
| `DATABASE_ERROR` | Error de conexión a base de datos |
| `INTERNAL_ERROR` | Error interno del servidor |

## Rate Limiting

- **Límite**: 100 requests por 15 minutos por IP
- **Header de respuesta**: `X-RateLimit-Remaining`
- **Respuesta cuando se excede**:

```json
{
  "error": true,
  "mensaje": "Demasiadas solicitudes, intente nuevamente en 15 minutos",
  "codigo": "RATE_LIMIT_EXCEEDED"
}
```

## Headers de Respuesta

| Header | Descripción |
|--------|-------------|
| `Content-Type` | Siempre `application/json` |
| `X-Response-Time` | Tiempo de procesamiento en ms |
| `X-Request-ID` | ID único de la request |

## Monitoreo y Logs

Todas las búsquedas se registran en la tabla `historial_busquedas` con:

- Tipo de búsqueda realizada
- Valor buscado
- Resultado (encontrado/no encontrado)
- IP de origen
- User-Agent
- Timestamp

## Consideraciones de Seguridad

1. **Autenticación**: Opcional, configurable con Basic Auth
2. **HTTPS**: Recomendado para producción
3. **Validación**: Todos los inputs son validados
4. **Rate Limiting**: Protección contra abuso
5. **Logs**: Auditoría completa de accesos

## Webhook de Notificaciones (Opcional)

Para recibir notificaciones de búsquedas con embargos:

**URL**: Configurable en variables de entorno
**Método**: POST
**Payload**:

```json
{
  "evento": "embargo_encontrado",
  "persona": {
    "nombre": "Juan Pérez",
    "documento": "12345678"
  },
  "embargo": {
    "monto_total": 5000000,
    "entidad": "DIAN"
  },
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

---

Para más información o soporte, consulte la documentación de instalación o contacte al administrador del sistema.