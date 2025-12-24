#!/bin/bash

##############################################################################
# VALORES POR DEFECTO (solo asignaciones)
##############################################################################

VOL_ACTUAL=40
LAST_NAME=""
LAST_URL=""

##############################################################################
# INICIALIZACIÓN (segura)
##############################################################################

init_state() {
    : "${VOL_ACTUAL:=40}"
    : "${LAST_NAME:=}"
    : "${LAST_URL:=}"
}

##############################################################################
# CARGA / GUARDADO (seguro con set -u)
##############################################################################

load_state() {
    [ -z "${STATE:-}" ] && return
    [ -f "$STATE" ] || return
    source "$STATE"
}

save_state() {
    [ -z "${STATE:-}" ] && return

    mkdir -p "$(dirname "$STATE")"

    cat > "$STATE" <<EOF
VOL_ACTUAL=$VOL_ACTUAL
LAST_NAME="$ACTUAL_NOMBRE"
LAST_URL="$ACTUAL_URL"
EOF
}
