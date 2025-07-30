-- Datos de ejemplo para el sistema de búsqueda de embargos

-- Insertar personas de ejemplo
INSERT INTO personas (nombre, apellido, documento, tipo_documento, fecha_nacimiento, telefono, email, direccion, ciudad) VALUES
('Juan Carlos', 'Pérez García', '12345678', 'CC', '1985-03-15', '3001234567', 'juan.perez@email.com', 'Calle 123 #45-67', 'Bogotá'),
('María Elena', 'González López', '87654321', 'CC', '1990-07-22', '3009876543', 'maria.gonzalez@email.com', 'Carrera 45 #12-34', 'Medellín'),
('Carlos Alberto', 'Rodríguez Martínez', '11223344', 'CC', '1982-11-08', '3005555555', 'carlos.rodriguez@email.com', 'Avenida 68 #23-45', 'Cali'),
('Ana Sofía', 'Hernández Ruiz', '44332211', 'CC', '1988-05-12', '3007777777', 'ana.hernandez@email.com', 'Calle 85 #15-30', 'Barranquilla'),
('Luis Fernando', 'Morales Castro', '55667788', 'CC', '1975-09-03', '3002222222', 'luis.morales@email.com', 'Carrera 15 #78-90', 'Cartagena'),
('Patricia', 'Jiménez Vargas', '99887766', 'CC', '1992-12-18', '3008888888', 'patricia.jimenez@email.com', 'Calle 50 #25-40', 'Bucaramanga'),
('Roberto', 'Silva Mendoza', '33445566', 'CE', '1980-04-25', '3003333333', 'roberto.silva@email.com', 'Avenida 30 #12-15', 'Pereira'),
('Carmen Rosa', 'Torres Delgado', '66778899', 'CC', '1987-08-14', '3006666666', 'carmen.torres@email.com', 'Calle 72 #35-50', 'Manizales');

-- Insertar embargos de ejemplo
INSERT INTO embargos (persona_id, monto, monto_original, fecha_inicio, fecha_vencimiento, entidad, tipo_embargo, descripcion, numero_proceso, juzgado) VALUES
(1, 5000000.00, 5000000.00, '2023-01-15', '2025-01-15', 'DIAN', 'Tributario', 'Deuda por impuestos no pagados período 2022', 'DIAN-2023-001', 'Juzgado Administrativo de Bogotá'),
(3, 15000000.00, 18000000.00, '2022-06-10', '2024-12-10', 'Banco Popular', 'Crediticio', 'Crédito hipotecario en mora', 'BP-2022-456', 'Juzgado Civil del Circuito de Cali'),
(5, 3500000.00, 4000000.00, '2023-03-20', '2024-09-20', 'Cooperativa Financiera', 'Crediticio', 'Crédito de libre inversión vencido', 'CF-2023-789', 'Juzgado Civil Municipal de Cartagena'),
(7, 8000000.00, 8000000.00, '2023-05-05', '2025-05-05', 'Secretaría de Hacienda', 'Tributario', 'Impuesto predial acumulado', 'SH-2023-123', 'Juzgado Administrativo de Pereira');

-- Insertar alternativas de pago
INSERT INTO alternativas_pago (embargo_id, tipo, descripcion, monto_inicial, monto_final, cuota_mensual, numero_cuotas, descuento_porcentaje, fecha_limite) VALUES
-- Alternativas para Juan Carlos Pérez (embargo_id = 1)
(1, 'plan_pagos', 'Plan de pagos a 12 meses con 10% de descuento', 450000.00, 4500000.00, 375000.00, 12, 10.00, '2024-12-31'),
(1, 'descuento_pronto_pago', 'Descuento por pronto pago (20%)', NULL, 4000000.00, NULL, NULL, 20.00, '2024-06-30'),
(1, 'plan_pagos_largo', 'Plan de pagos a 24 meses', 250000.00, 5000000.00, 208333.33, 24, 0.00, '2024-12-31'),

-- Alternativas para Carlos Alberto Rodríguez (embargo_id = 2)
(2, 'plan_pagos', 'Plan de pagos a 18 meses', 1500000.00, 15000000.00, 833333.33, 18, 0.00, '2024-12-31'),
(2, 'descuento_pronto_pago', 'Descuento por pronto pago (15%)', NULL, 12750000.00, NULL, NULL, 15.00, '2024-08-31'),
(2, 'refinanciacion', 'Refinanciación a 36 meses con tasa preferencial', 1000000.00, 16500000.00, 458333.33, 36, 0.00, '2024-12-31'),

-- Alternativas para Luis Fernando Morales (embargo_id = 3)
(3, 'plan_pagos', 'Plan de pagos a 10 meses', 350000.00, 3500000.00, 350000.00, 10, 0.00, '2024-10-31'),
(3, 'descuento_pronto_pago', 'Descuento por pronto pago (25%)', NULL, 2625000.00, NULL, NULL, 25.00, '2024-07-31'),

-- Alternativas para Roberto Silva (embargo_id = 4)
(4, 'plan_pagos', 'Plan de pagos a 15 meses', 800000.00, 8000000.00, 533333.33, 15, 0.00, '2024-12-31'),
(4, 'descuento_pronto_pago', 'Descuento por pronto pago (12%)', NULL, 7040000.00, NULL, NULL, 12.00, '2024-09-30'),
(4, 'plan_pagos_largo', 'Plan de pagos a 30 meses con descuento', 400000.00, 7200000.00, 240000.00, 30, 10.00, '2024-12-31');

-- Insertar algunos registros de búsquedas de ejemplo
INSERT INTO historial_busquedas (tipo_busqueda, valor_buscado, resultado_encontrado, persona_id, ip_origen) VALUES
('documento', '12345678', true, 1, '192.168.1.100'),
('nombre', 'Juan Pérez', true, 1, '192.168.1.100'),
('documento', '99999999', false, NULL, '192.168.1.101'),
('nombre', 'María González', true, 2, '192.168.1.102'),
('documento', '11223344', true, 3, '192.168.1.103');

-- Crear vista para consultas rápidas
CREATE VIEW vista_embargos_activos AS
SELECT 
    p.id as persona_id,
    CONCAT(p.nombre, ' ', p.apellido) as nombre_completo,
    p.documento,
    p.tipo_documento,
    e.id as embargo_id,
    e.monto,
    e.monto_original,
    e.fecha_inicio,
    e.entidad,
    e.tipo_embargo,
    e.descripcion,
    COUNT(ap.id) as num_alternativas
FROM personas p
JOIN embargos e ON p.id = e.persona_id
LEFT JOIN alternativas_pago ap ON e.id = ap.embargo_id AND ap.activo = true
WHERE e.estado = 'ACTIVO'
GROUP BY p.id, p.nombre, p.apellido, p.documento, p.tipo_documento, 
         e.id, e.monto, e.monto_original, e.fecha_inicio, e.entidad, 
         e.tipo_embargo, e.descripcion
ORDER BY e.fecha_inicio DESC;