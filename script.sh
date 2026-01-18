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

# --- Comprobaciones Previas ---
if ! command -v gs &> /dev/null; then
    echo "Error: Instala ghostscript (sudo apt install ghostscript)."
    exit 1
fi

# --- SELECCIÓN DE MODO ---
MODO="NORMAL"
if [ "$1" == "--god" ]; then
    MODO="GOD"
fi

# --- CAPTURA DE ARCHIVOS ---
echo "========================================"
if [ "$MODO" == "GOD" ]; then
    echo "⚡ MODO DIOS ACTIVADO ⚡"
    echo "Buscando PDFs en esta carpeta y todas las subcarpetas..."
    # find . : Busca en el directorio actual (.) recursivamente
    # -type f : Solo archivos
    # sort -V : Ordenamiento natural de versiones (para que 2 vaya antes que 10)
    mapfile -t archivos < <(find . -type f -name "*.pdf" | sort -V)
else
    echo "📂 MODO NORMAL"
    echo "Buscando PDFs solo en la carpeta actual..."
    mapfile -t archivos < <(ls -v *.pdf 2>/dev/null)
fi
echo "========================================"

# Verificar si se encontró algo
if [ ${#archivos[@]} -eq 0 ]; then
    echo "Error: No se encontraron archivos .pdf."
    exit 1
fi

# --- Filtrado y Listado ---
echo "Se unirán los siguientes archivos en este orden:"
echo ""

count=0
lista_final=()

for f in "${archivos[@]}"; do
    # Obtenemos solo el nombre del archivo para comparar, ignorando la ruta ./
    nombre_base=$(basename "$f")
    
    # Evitamos unir el archivo de salida consigo mismo si ya existe
    if [ "$nombre_base" != "$SALIDA" ]; then
        ((count++))
        
        # En modo DIOS mostramos la ruta para saber de qué subcarpeta viene
        if [ "$MODO" == "GOD" ]; then
            echo "  $count. $f"
        else
            echo "  $count. $nombre_base"
        fi
        
        lista_final+=("$f") 
    fi
done

if [ "$count" -eq 0 ]; then
   echo "Error: No hay archivos válidos para unir (quizás solo existe el archivo final)."
   exit 1
fi

echo ""
echo "----------------------------------------"
echo "Total: $count archivos a fusionar."
echo "----------------------------------------"
read -p "Presiona [ENTER] para comenzar o [Ctrl+C] para cancelar..."

# --- Ejecución ---
# Ejecutamos Ghostscript en segundo plano y activamos el spinner
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
    echo "❌ Ocurrió un error. Verifica que los archivos no estén corruptos."
fi
