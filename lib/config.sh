#!/bin/bash

# Directorio base del proyecto (radio.sh lo define antes de cargar este archivo)
# BASE_DIR ya viene definido desde radio.sh

# Archivos principales
EMISORAS="$BASE_DIR/emisoras.txt"
FAVORITAS="$BASE_DIR/emisorasFavoritas.txt"

# Archivo donde guardar estado (volumen, última emisora, etc.)
STATE="$HOME/.config/radio.sh/state"

# Configuración de volumen
VOL_MIN=0
VOL_MAX=100
VOL_STEP=5
