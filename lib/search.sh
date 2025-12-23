#!/bin/bash

##############################################################################
# BÚSQUEDA INCREMENTAL DE EMISORAS
# - Aislada del main_loop
# - Lectura carácter a carácter
# - Redibujado controlado
##############################################################################

buscar_emisora() {
    local query=""
    local key
    local results=()
    local max_results=20

    # Guardar estado del terminal
    stty -echo -icanon time 0 min 0

    clear
    echo "Buscar emisora (ESC cancelar, ENTER reproducir primera)"
    echo "------------------------------------------------------"
    echo
    echo "Buscar: "
    echo
    echo "Resultados:"
    echo "-----------"

    while true; do
        # Leer una tecla (no bloqueante)
        read -rsn1 key

        case "$key" in
            $'\x1b')  # ESC
                break
                ;;
            "")       # ENTER
                if [ "${#results[@]}" -gt 0 ]; then
                    IFS="|" read -r n u <<< "${results[0]}"
                    reproducir "$n" "$u"
                fi
                break
                ;;
            $'\x7f'|$'\b')  # BACKSPACE
                query="${query%?}"
                ;;
            *)
                # Solo caracteres imprimibles
                [[ "$key" =~ [[:print:]] ]] && query+="$key"
                ;;
        esac

        # Buscar resultados
        if [ -n "$query" ]; then
            mapfile -t results < <(
                grep -i "$query" "$EMISORAS" | head -n "$max_results"
            )
        else
            results=()
        fi

        # Redibujar zona dinámica
        tput cup 3 0
        printf "\033[J"

        echo "Buscar: $query"
        echo
        echo "Resultados:"
        echo "-----------"

        if [ "${#results[@]}" -eq 0 ]; then
            echo " (sin resultados)"
        else
            for i in "${!results[@]}"; do
                IFS="|" read -r n _ <<< "${results[$i]}"
                printf " %2d) %s\n" "$((i+1))" "$n"
            done
        fi

        # Pequeña pausa para no quemar CPU
        sleep 0.03
    done

    # Restaurar terminal
    stty sane
    clear
}
