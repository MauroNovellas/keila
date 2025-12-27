#!/bin/bash

##############################################################################
# CONFIGURACIÓN DEL TERMINAL (SOLUCIÓN AL ^[[D)
##############################################################################

stty -echo -icanon time 0 min 0

restore_tty() {
    stty echo icanon
    tput cnorm
}
trap restore_tty EXIT INT TERM

tput civis

##############################################################################
# ESTADO
##############################################################################

check_player

NECESITA_REDIBUJAR=1
CURSOR_IDX=0

##############################################################################
# FAVORITOS
##############################################################################

load_favorites() {
    fav_names=()
    fav_urls=()
    [ -f "$FAVORITAS" ] || return

    while IFS="|" read -r n u; do
        fav_names+=("$n")
        fav_urls+=("$u")
    done < "$FAVORITAS"
}

save_favorites() {
    : > "$FAVORITAS"
    for i in "${!fav_names[@]}"; do
        echo "${fav_names[$i]}|${fav_urls[$i]}" >> "$FAVORITAS"
    done
}

confirmar_fav() {
    local accion="$1"

    echo
    echo "¿$accion \"$ACTUAL_NOMBRE\" de favoritos? (S/N)"

    while true; do
        read -rsn1 key
        case "$key" in
            [sS]) toggle_fav_real; return ;;
            [nN]) return ;;
        esac
    done
}

toggle_fav_real() {
    for i in "${!fav_urls[@]}"; do
        if [ "${fav_urls[$i]}" = "$ACTUAL_URL" ]; then
            unset fav_names[$i] fav_urls[$i]
            fav_names=("${fav_names[@]}")
            fav_urls=("${fav_urls[@]}")
            ((CURSOR_IDX >= ${#fav_names[@]})) && CURSOR_IDX=$((${#fav_names[@]}-1))
            save_favorites
            NECESITA_REDIBUJAR=1
            return
        fi
    done

    fav_names+=("$ACTUAL_NOMBRE")
    fav_urls+=("$ACTUAL_URL")
    save_favorites
    NECESITA_REDIBUJAR=1
}

##############################################################################
# UTILIDADES
##############################################################################

swap_fav() {
    local a="$1" b="$2" tmp
    tmp="${fav_names[$a]}"
    fav_names[$a]="${fav_names[$b]}"
    fav_names[$b]="$tmp"

    tmp="${fav_urls[$a]}"
    fav_urls[$a]="${fav_urls[$b]}"
    fav_urls[$b]="$tmp"
}

##############################################################################
# LECTURA DE TECLAS (ROBUSTA)
##############################################################################

leer_tecla() {
    local key rest

    read -rsn1 key || return

    if [[ "$key" == $'\x1b' ]]; then
        read -rsn5 -t 0.01 rest
        case "$rest" in
            "[A") echo "UP" ;;
            "[B") echo "DOWN" ;;
            "[C") echo "RIGHT" ;;
            "[D") echo "LEFT" ;;
        esac
        return
    fi

    case "$key" in
        "") echo "ENTER" ;;
        *)  echo "$key" ;;
    esac
}

##############################################################################
# MENÚ PRINCIPAL
##############################################################################

main_loop() {
    while true; do
        check_player

        if [ "$NECESITA_REDIBUJAR" = "1" ]; then
            menu
            NECESITA_REDIBUJAR=0
        fi

        op=$(leer_tecla)
        [ -z "$op" ] && continue

        # ─────── MODO MOVER ───────
        if [ "$MODO_MOVER" = "1" ]; then
            case "$op" in
                UP)
                    ((CURSOR_IDX > 0)) && {
                        swap_fav "$CURSOR_IDX" "$((CURSOR_IDX-1))"
                        ((CURSOR_IDX--))
                        NECESITA_REDIBUJAR=1
                    }
                    ;;
                DOWN)
                    ((CURSOR_IDX < ${#fav_names[@]}-1)) && {
                        swap_fav "$CURSOR_IDX" "$((CURSOR_IDX+1))"
                        ((CURSOR_IDX++))
                        NECESITA_REDIBUJAR=1
                    }
                    ;;
                ENTER|m)
                    save_favorites
                    MODO_MOVER=0
                    NECESITA_REDIBUJAR=1
                    ;;
                q)
                    while [ "$CURSOR_IDX" -ne "$ORIG_IDX" ]; do
                        if [ "$CURSOR_IDX" -gt "$ORIG_IDX" ]; then
                            swap_fav "$CURSOR_IDX" "$((CURSOR_IDX-1))"
                            ((CURSOR_IDX--))
                        else
                            swap_fav "$CURSOR_IDX" "$((CURSOR_IDX+1))"
                            ((CURSOR_IDX++))
                        fi
                    done
                    MODO_MOVER=0
                    NECESITA_REDIBUJAR=1
                    ;;
            esac
            continue
        fi

        # ─────── MODO NORMAL ───────
        case "$op" in
            q) stop_player; exit 0 ;;
            p) toggle_pause; NECESITA_REDIBUJAR=1 ;;
            UP) ((CURSOR_IDX > 0)) && ((CURSOR_IDX--)); NECESITA_REDIBUJAR=1 ;;
            DOWN) ((CURSOR_IDX < ${#fav_names[@]}-1)) && ((CURSOR_IDX++)); NECESITA_REDIBUJAR=1 ;;
            LEFT) ajustar_volumen "-$VOL_STEP"; NECESITA_REDIBUJAR=1 ;;
            RIGHT) ajustar_volumen "$VOL_STEP"; NECESITA_REDIBUJAR=1 ;;
            ENTER)
                [ "${#fav_urls[@]}" -gt 0 ] &&
                reproducir "${fav_names[$CURSOR_IDX]}" "${fav_urls[$CURSOR_IDX]}"
                NECESITA_REDIBUJAR=1
                ;;
        esac
    done
}
