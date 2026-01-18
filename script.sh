#!/bin/bash

# --- Configuración ---
SALIDA="PDF_Unido_Final.pdf"

# --- Funciones Visuales ---
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    echo -n "Procesando... "
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# --- Comprobaciones ---
if ! command -v gs &> /dev/null; then
    echo "Error: Instala ghostscript (sudo apt install ghostscript)."
    exit 1
fi

# --- CAPTURA DE ARCHIVOS (MODO SEGURO) ---
# Usamos mapfile para leer la salida de ls línea por línea en un ARRAY.
# Esto respeta los espacios en los nombres.
mapfile -t archivos < <(ls -v *.pdf 2>/dev/null)

# Verificar si el array está vacío o solo tiene el archivo de salida
if [ ${#archivos[@]} -eq 0 ]; then
    echo "Error: No hay archivos .pdf en este directorio."
    exit 1
fi

# --- Mostrar el Proceso (Fase 1: Listado) ---
echo "========================================"
echo "   PREPARANDO FUSIÓN DE ARCHIVOS PDF"
echo "========================================"
echo "Se unirán los siguientes archivos en este orden:"
echo ""

count=0
lista_final=()

# Iteramos sobre el ARRAY, no sobre una cadena de texto
for f in "${archivos[@]}"; do
    # Ignoramos el archivo de salida si ya existe
    if [ "$f" != "$SALIDA" ]; then
        ((count++))
        echo "  $count. $f"
        # Añadimos a una nueva lista limpia para pasársela a Ghostscript
        lista_final+=("$f") 
    fi
done

if [ "$count" -eq 0 ]; then
   echo "Error: No hay archivos válidos para unir (quizás solo existe el archivo final)."
   exit 1
fi

echo ""
echo "Total: $count archivos."
echo "----------------------------------------"
read -p "Presiona [ENTER] para comenzar o [Ctrl+C] para cancelar..."

# --- Ejecución (Fase 2: Procesamiento) ---
# Importante: "${lista_final[@]}" con comillas mantiene los nombres como unidades enteras

gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress -sOutputFile="$SALIDA" "${lista_final[@]}" 2> /dev/null &

pid=$!
spinner $pid
wait $pid
status=$?

echo ""
# --- Resultado ---
if [ $status -eq 0 ]; then
    echo "✅ ¡HECHO! El archivo se guardó como: $SALIDA"
else
    echo "❌ Ocurrió un error. Verifica que los archivos PDF no estén corruptos."
fi
