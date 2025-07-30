-- Schema para el sistema de búsqueda de embargos
-- Base de datos: PostgreSQL

-- Tabla de personas
CREATE TABLE personas (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    apellido VARCHAR(255) NOT NULL,
    documento VARCHAR(20) UNIQUE NOT NULL,
    tipo_documento VARCHAR(5) NOT NULL DEFAULT 'CC',
    fecha_nacimiento DATE,
    telefono VARCHAR(20),
    email VARCHAR(100),
    direccion TEXT,
    ciudad VARCHAR(100),
    estado VARCHAR(50) DEFAULT 'ACTIVO',
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de embargos
CREATE TABLE embargos (
    id SERIAL PRIMARY KEY,
    persona_id INTEGER REFERENCES personas(id),
    monto DECIMAL(15,2) NOT NULL,
    monto_original DECIMAL(15,2) NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_vencimiento DATE,
    entidad VARCHAR(100) NOT NULL,
    tipo_embargo VARCHAR(50) NOT NULL,
    descripcion TEXT,
    estado VARCHAR(20) DEFAULT 'ACTIVO',
    numero_proceso VARCHAR(50),
    juzgado VARCHAR(100),
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de alternativas de pago
CREATE TABLE alternativas_pago (
    id SERIAL PRIMARY KEY,
    embargo_id INTEGER REFERENCES embargos(id),
    tipo VARCHAR(50) NOT NULL,
    descripcion TEXT NOT NULL,
    monto_inicial DECIMAL(15,2),
    monto_final DECIMAL(15,2),
    cuota_mensual DECIMAL(15,2),
    numero_cuotas INTEGER,
    descuento_porcentaje DECIMAL(5,2),
    fecha_limite DATE,
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de historial de búsquedas
CREATE TABLE historial_busquedas (
    id SERIAL PRIMARY KEY,
    tipo_busqueda VARCHAR(20) NOT NULL,
    valor_buscado VARCHAR(255) NOT NULL,
    resultado_encontrado BOOLEAN NOT NULL,
    persona_id INTEGER REFERENCES personas(id),
    ip_origen VARCHAR(45),
    user_agent TEXT,
    fecha_busqueda TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Índices para mejorar el rendimiento
CREATE INDEX idx_personas_documento ON personas(documento);
CREATE INDEX idx_personas_nombre ON personas(nombre, apellido);
CREATE INDEX idx_embargos_persona_id ON embargos(persona_id);
CREATE INDEX idx_embargos_estado ON embargos(estado);
CREATE INDEX idx_alternativas_embargo_id ON alternativas_pago(embargo_id);
CREATE INDEX idx_historial_fecha ON historial_busquedas(fecha_busqueda);

-- Función para buscar por nombre (búsqueda parcial)
CREATE OR REPLACE FUNCTION buscar_por_nombre(nombre_busqueda VARCHAR)
RETURNS TABLE(
    persona_id INTEGER,
    nombre_completo VARCHAR,
    documento VARCHAR,
    tipo_documento VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id,
        CONCAT(p.nombre, ' ', p.apellido) as nombre_completo,
        p.documento,
        p.tipo_documento
    FROM personas p
    WHERE 
        LOWER(CONCAT(p.nombre, ' ', p.apellido)) LIKE LOWER('%' || nombre_busqueda || '%')
        OR LOWER(p.nombre) LIKE LOWER('%' || nombre_busqueda || '%')
        OR LOWER(p.apellido) LIKE LOWER('%' || nombre_busqueda || '%')
    ORDER BY 
        CASE 
            WHEN LOWER(CONCAT(p.nombre, ' ', p.apellido)) = LOWER(nombre_busqueda) THEN 1
            WHEN LOWER(CONCAT(p.nombre, ' ', p.apellido)) LIKE LOWER(nombre_busqueda || '%') THEN 2
            ELSE 3
        END;
END;
$$ LANGUAGE plpgsql;

-- Función para obtener información completa de embargo
CREATE OR REPLACE FUNCTION obtener_info_embargo(persona_id_param INTEGER)
RETURNS TABLE(
    persona_id INTEGER,
    nombre_completo VARCHAR,
    documento VARCHAR,
    tipo_documento VARCHAR,
    embargo_id INTEGER,
    monto DECIMAL,
    fecha_inicio DATE,
    entidad VARCHAR,
    tipo_embargo VARCHAR,
    estado VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id as persona_id,
        CONCAT(p.nombre, ' ', p.apellido) as nombre_completo,
        p.documento,
        p.tipo_documento,
        e.id as embargo_id,
        e.monto,
        e.fecha_inicio,
        e.entidad,
        e.tipo_embargo,
        e.estado
    FROM personas p
    LEFT JOIN embargos e ON p.id = e.persona_id AND e.estado = 'ACTIVO'
    WHERE p.id = persona_id_param;
END;
$$ LANGUAGE plpgsql;

-- Trigger para actualizar fecha_actualizacion
CREATE OR REPLACE FUNCTION actualizar_fecha_modificacion()
RETURNS TRIGGER AS $$
BEGIN
    NEW.fecha_actualizacion = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_personas_actualizacion
    BEFORE UPDATE ON personas
    FOR EACH ROW
    EXECUTE FUNCTION actualizar_fecha_modificacion();

CREATE TRIGGER trigger_embargos_actualizacion
    BEFORE UPDATE ON embargos
    FOR EACH ROW
    EXECUTE FUNCTION actualizar_fecha_modificacion();