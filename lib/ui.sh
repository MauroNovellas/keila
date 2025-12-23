#!/bin/bash

UI_INIT=0
SHOW_CONTROLS=0
LAST_BITRATE="" # Variable para suavizar el bitrate

##############################################################################
# UTILIDADES DE DIBUJO
##############################################################################

barra_vol() {
    local v=$1
    local w=20
    local f=$((v * w / 100))

    printf "["
    for ((i=0;i<w;i++)); do
        if [ "$i" -lt "$f" ]; then
            printf "█"
        else
            printf "░"
        fi
    done
    printf "] %3d%%" "$v"
}

##############################################################################
# UI FIJA
##############################################################################

ui_init() {
    clear
    tput civis

    # Cabecera fija rediseñada
    echo "────────────────────────────────"
    echo
    echo " Emisora :"
    echo " Volumen :"
    echo " Estado  :"
    echo "────────────────────────────────"
    echo " Mostrar Controles: [c]"
    echo

    echo "EMISORAS FAVORITAS"
    echo "------------------"

    UI_INIT=1
}

##############################################################################
# CONTROLES
##############################################################################

draw_controls() {
    tput cup 6 0 # Subimos un poco para aprovechar el espacio de la línea eliminada
    printf "\033[J"

    echo " Mostrar Controles"
    echo " ---------"
    echo " ↑ ↓   Seleccionar emisora"
    echo " ← →   Volumen"
    echo " ENTER Reproducir"
    echo " p     Pausa"
    echo " f     Favorito"
    echo " m     Mover favorito"
    echo " e     Todas las emisoras"
    echo " q     Salir"
    echo
    echo "EMISORAS FAVORITAS"
    echo "------------------"
}

clear_controls() {
    tput cup 6 0
    printf "\033[J"
    echo "EMISORAS FAVORITAS"
    echo "------------------"
}

##############################################################################
# DIBUJO DINÁMICO
##############################################################################

menu() {
    [ "$UI_INIT" -eq 0 ] && ui_init

    # 1. Nombre de Emisora
    tput cup 2 11
    printf "\033[K%s" "$ACTUAL_NOMBRE"

    # 2. Volumen
    tput cup 3 11
    printf "\033[K"
    barra_vol "$VOL_ACTUAL"

    # 3. Lógica de Suavizado de Bitrate e Info combinada
    # Si INFO_STREAM tiene kbps, lo guardamos. Si viene vacío o es 0, usamos el último conocido.
    if [[ "$INFO_STREAM" =~ [1-9][0-9]* ]]; then
        LAST_BITRATE=" @ $INFO_STREAM"
    fi

    # Si el estado es "Reproduciendo", le añadimos el bitrate guardado
    local linea_estado="$ESTADO"
    if [ "$ESTADO" = "Reproduciendo" ]; then
        linea_estado="${ESTADO}${LAST_BITRATE}"
    fi

    tput cup 4 11
    printf "\033[K%s" "$linea_estado"

    # 4. Lista de favoritos
    local start_line
    if [ "$SHOW_CONTROLS" = "1" ]; then
        start_line=16
    else
        start_line=8
    fi

    tput cup "$start_line" 0
    printf "\033[J"

    for i in "${!fav_names[@]}"; do
        if [ "$i" -eq "$CURSOR_IDX" ]; then
            printf "> %d) %s\n" "$((i+1))" "${fav_names[$i]}"
        else
            printf "  %d) %s\n" "$((i+1))" "${fav_names[$i]}"
        fi
    done
}
