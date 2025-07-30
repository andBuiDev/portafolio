#!/bin/bash

# Script de pruebas para el Agente de Búsqueda de Embargos
# Uso: ./test-api.sh [URL_BASE]

# Configuración
BASE_URL=${1:-"http://localhost:5678/webhook"}
ENDPOINT="$BASE_URL/buscar-embargo"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para imprimir resultados
print_test() {
    local test_name="$1"
    local status="$2"
    local response="$3"
    
    echo -e "\n${BLUE}=== $test_name ===${NC}"
    
    if [ "$status" = "PASS" ]; then
        echo -e "${GREEN}✓ PASS${NC}"
    else
        echo -e "${RED}✗ FAIL${NC}"
    fi
    
    echo -e "${YELLOW}Response:${NC}"
    echo "$response" | jq '.' 2>/dev/null || echo "$response"
}

# Función para realizar test
run_test() {
    local test_name="$1"
    local payload="$2"
    local expected_status="$3"
    
    echo -e "\n${BLUE}Ejecutando: $test_name${NC}"
    
    response=$(curl -s -w "\n%{http_code}" -X POST "$ENDPOINT" \
        -H "Content-Type: application/json" \
        -d "$payload")
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')
    
    if [ "$http_code" = "$expected_status" ]; then
        print_test "$test_name" "PASS" "$body"
    else
        print_test "$test_name" "FAIL" "Expected status: $expected_status, Got: $http_code\nBody: $body"
    fi
    
    return $([ "$http_code" = "$expected_status" ] && echo 0 || echo 1)
}

# Verificar dependencias
command -v curl >/dev/null 2>&1 || { echo "curl es requerido pero no está instalado." >&2; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "jq es requerido pero no está instalado." >&2; exit 1; }

echo -e "${GREEN}Iniciando pruebas del Agente de Búsqueda de Embargos${NC}"
echo -e "${YELLOW}URL: $ENDPOINT${NC}"

# Contador de pruebas
total_tests=0
passed_tests=0

# Test 1: Búsqueda por documento existente con embargo
total_tests=$((total_tests + 1))
run_test "Búsqueda por documento con embargo" \
    '{"tipo_busqueda": "documento", "valor": "12345678"}' \
    "200" && passed_tests=$((passed_tests + 1))

# Test 2: Búsqueda por documento existente sin embargo
total_tests=$((total_tests + 1))
run_test "Búsqueda por documento sin embargo" \
    '{"tipo_busqueda": "documento", "valor": "87654321"}' \
    "200" && passed_tests=$((passed_tests + 1))

# Test 3: Búsqueda por documento inexistente
total_tests=$((total_tests + 1))
run_test "Búsqueda por documento inexistente" \
    '{"tipo_busqueda": "documento", "valor": "99999999"}' \
    "200" && passed_tests=$((passed_tests + 1))

# Test 4: Búsqueda por nombre existente
total_tests=$((total_tests + 1))
run_test "Búsqueda por nombre existente" \
    '{"tipo_busqueda": "nombre", "valor": "Juan Pérez"}' \
    "200" && passed_tests=$((passed_tests + 1))

# Test 5: Búsqueda por nombre parcial
total_tests=$((total_tests + 1))
run_test "Búsqueda por nombre parcial" \
    '{"tipo_busqueda": "nombre", "valor": "María"}' \
    "200" && passed_tests=$((passed_tests + 1))

# Test 6: Búsqueda por nombre inexistente
total_tests=$((total_tests + 1))
run_test "Búsqueda por nombre inexistente" \
    '{"tipo_busqueda": "nombre", "valor": "Persona Inexistente"}' \
    "200" && passed_tests=$((passed_tests + 1))

# Test 7: Error - Campos faltantes
total_tests=$((total_tests + 1))
run_test "Error - Campos faltantes" \
    '{"tipo_busqueda": "documento"}' \
    "400" && passed_tests=$((passed_tests + 1))

# Test 8: Error - Tipo de búsqueda inválido
total_tests=$((total_tests + 1))
run_test "Error - Tipo de búsqueda inválido" \
    '{"tipo_busqueda": "email", "valor": "test@test.com"}' \
    "400" && passed_tests=$((passed_tests + 1))

# Test 9: Error - Documento muy corto
total_tests=$((total_tests + 1))
run_test "Error - Documento muy corto" \
    '{"tipo_busqueda": "documento", "valor": "123"}' \
    "400" && passed_tests=$((passed_tests + 1))

# Test 10: Error - Nombre muy corto
total_tests=$((total_tests + 1))
run_test "Error - Nombre muy corto" \
    '{"tipo_busqueda": "nombre", "valor": "A"}' \
    "400" && passed_tests=$((passed_tests + 1))

# Test 11: Documento con caracteres especiales (debe limpiarlos)
total_tests=$((total_tests + 1))
run_test "Documento con caracteres especiales" \
    '{"tipo_busqueda": "documento", "valor": "12.345.678-9"}' \
    "200" && passed_tests=$((passed_tests + 1))

# Test 12: JSON malformado
total_tests=$((total_tests + 1))
echo -e "\n${BLUE}Ejecutando: JSON malformado${NC}"
response=$(curl -s -w "\n%{http_code}" -X POST "$ENDPOINT" \
    -H "Content-Type: application/json" \
    -d '{"tipo_busqueda": "documento", "valor":}')

http_code=$(echo "$response" | tail -n1)
if [ "$http_code" = "400" ] || [ "$http_code" = "500" ]; then
    print_test "JSON malformado" "PASS" "$(echo "$response" | sed '$d')"
    passed_tests=$((passed_tests + 1))
else
    print_test "JSON malformado" "FAIL" "Expected 400 or 500, Got: $http_code"
fi
total_tests=$((total_tests + 1))

# Resumen de resultados
echo -e "\n${GREEN}=== RESUMEN DE PRUEBAS ===${NC}"
echo -e "Total de pruebas: $total_tests"
echo -e "Pruebas exitosas: $passed_tests"
echo -e "Pruebas fallidas: $((total_tests - passed_tests))"

if [ $passed_tests -eq $total_tests ]; then
    echo -e "\n${GREEN}🎉 Todas las pruebas pasaron exitosamente!${NC}"
    exit 0
else
    echo -e "\n${RED}❌ Algunas pruebas fallaron${NC}"
    exit 1
fi