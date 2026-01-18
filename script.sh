#!/bin/bash

# --- Configuración Inicial ---
SALIDA_MERGE="PDF_Unido_Final.pdf"
MODO_BUSQUEDA="NORMAL"
MODO_ACCION="FUSIONAR" # Por defecto fusionamos

# --- 1. Procesamiento de Argumentos ---
for arg in "$@"; do
    case $arg in
        --god)
            MODO_BUSQUEDA="GOD"
            ;;
        --compress)
            MODO_ACCION="COMPRIMIR"
            ;;
    esac
done

# --- Funciones Visuales ---
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    echo -n "Trabajando... "
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

# --- 2. Captura de Archivos ---
echo "========================================"
if [ "$MODO_BUSQUEDA" == "GOD" ]; then
    echo "⚡ MODO DIOS (Búsqueda Recursiva) ⚡"
    mapfile -t archivos < <(find . -type f -name "*.pdf" | sort -V)
else
    echo "📂 MODO LOCAL (Carpeta Actual)"
    mapfile -t archivos < <(ls -v *.pdf 2>/dev/null)
fi

# Verificar si hay archivos
if [ ${#archivos[@]} -eq 0 ]; then
    echo "Error: No se encontraron archivos .pdf."
    exit 1
fi

# --- 3. Listado de Archivos ---
echo "========================================"
echo "Archivos encontrados:"
echo ""

count=0
lista_valida=()

# Mostramos la lista numerada
for f in "${archivos[@]}"; do
    nombre_base=$(basename "$f")
    # Filtramos para no mostrarnos a nosotros mismos si el output ya existe
    if [ "$nombre_base" != "$SALIDA_MERGE" ] && [[ "$nombre_base" != *"_min.pdf" ]]; then
        ((count++))
        
        if [ "$MODO_BUSQUEDA" == "GOD" ]; then
            echo "  [$count] $f"
        else
            echo "  [$count] $nombre_base"
        fi
        
        lista_valida+=("$f") 
    fi
done

if [ "$count" -eq 0 ]; then
   echo "Error: No hay archivos válidos."
   exit 1
fi

echo "----------------------------------------"

# --- 4. RAMIFICACIÓN DE LÓGICA ---

if [ "$MODO_ACCION" == "COMPRIMIR" ]; then
    # ================================
    # MODO COMPRESIÓN (UN SOLO ARCHIVO)
    # ================================
    echo "Has seleccionado el modo --compress."
    echo "Introduce el número del archivo que quieres reducir de peso."
    read -p "Número >> " seleccion

    # Validar que sea un número y esté en rango
    if ! [[ "$seleccion" =~ ^[0-9]+$ ]] || [ "$seleccion" -lt 1 ] || [ "$seleccion" -gt "$count" ]; then
        echo "❌ Selección inválida."
        exit 1
    fi

    # Obtener el archivo real (ajustamos índice -1 porque los arrays empiezan en 0)
    archivo_input="${lista_valida[$((seleccion-1))]}"
    nombre_input=$(basename "$archivo_input")
    archivo_output="${nombre_input%.*}_min.pdf"

    echo "----------------------------------------"
    echo "Comprimiendo: $nombre_input"
    echo "Salida:       $archivo_output"
    echo "----------------------------------------"

    gs -o "$archivo_output" \
       -sDEVICE=pdfwrite \
       -dPDFSETTINGS=/ebook \
       -dInteraction=false \
       -dContinueOnPageError \
       "$archivo_input" &

    pid=$!
    spinner $pid
    wait $pid
    
    echo ""
    if [ $? -eq 0 ]; then
        echo "✅ ¡HECHO! Archivo comprimido creado."
        du -h "$archivo_output"
    else
        echo "❌ Error al comprimir."
    fi

else
    # ================================
    # MODO FUSIÓN (TODOS LOS ARCHIVOS)
    # ================================
    echo "Modo Fusión: Se unirán los $count archivos listados arriba."
    echo "Archivo final: $SALIDA_MERGE"
    read -p "Presiona [ENTER] para confirmar o [Ctrl+C] para salir..."

    gs -o "$SALIDA_MERGE" \
       -sDEVICE=pdfwrite \
       -dPDFSETTINGS=/prepress \
       -dInteraction=false \
       -dContinueOnPageError \
       "${lista_valida[@]}" &

    pid=$!
    spinner $pid
    wait $pid

    echo ""
    if [ $? -eq 0 ]; then
        echo "✅ ¡HECHO! Todos los archivos unidos correctamente."
    else
        echo "❌ Error al unir archivos."
    fi
fi
