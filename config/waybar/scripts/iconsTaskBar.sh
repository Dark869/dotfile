#!/bin/bash

# Script para mostrar dinámicamente los iconos de aplicaciones abiertas
# ~/.config/waybar/scripts/dynamic-app-icons.sh

get_app_icon() {
    local app_class="$1"
    local app_name="$2"
    
    # Directorios donde buscar iconos
    icon_dirs=(
        "/usr/share/icons/hicolor"
        "/usr/share/pixmaps"
        "/usr/share/icons"
        "$HOME/.local/share/icons"
        "/var/lib/flatpak/exports/share/icons"
        "$HOME/.local/share/flatpak/exports/share/icons"
    )
    
    # Posibles nombres de la aplicación para buscar iconos
    possible_names=(
        "${app_class,,}"           # clase en minúsculas
        "${app_name,,}"            # nombre en minúsculas
        "${app_class}"             # clase original
        "${app_name}"              # nombre original
    )
    
    # Buscar archivo .desktop
    desktop_file=""
    for dir in "/usr/share/applications" "$HOME/.local/share/applications" "/var/lib/flatpak/exports/share/applications" "$HOME/.local/share/flatpak/exports/share/applications"; do
        if [[ -d "$dir" ]]; then
            for name in "${possible_names[@]}"; do
                if [[ -f "$dir/${name}.desktop" ]]; then
                    desktop_file="$dir/${name}.desktop"
                    break 2
                fi
            done
        fi
    done
    
    # Extraer el nombre del icono del archivo .desktop
    if [[ -n "$desktop_file" ]]; then
        icon_name=$(grep -E "^Icon=" "$desktop_file" | head -1 | cut -d'=' -f2 | tr -d ' ')
        if [[ -n "$icon_name" ]]; then
            # Si ya es una ruta completa, usarla
            if [[ "$icon_name" == /* ]]; then
                if [[ -f "$icon_name" ]]; then
                    echo "$icon_name"
                    return
                fi
            fi
            
            # Buscar el icono en los directorios de iconos
            for dir in "${icon_dirs[@]}"; do
                if [[ -d "$dir" ]]; then
                    # Buscar en diferentes tamaños y formatos
                    for size in "48x48" "32x32" "24x24" "22x22" "16x16" "scalable"; do
                        for category in "apps" "applications" ""; do
                            for ext in "svg" "png" "xpm"; do
                                icon_path="$dir/$size/$category/$icon_name.$ext"
                                if [[ -f "$icon_path" ]]; then
                                    echo "$icon_path"
                                    return
                                fi
                            done
                        done
                    done
                fi
            done
        fi
    fi
    
    # Si no se encuentra, buscar directamente por el nombre de la clase/aplicación
    for dir in "${icon_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            for name in "${possible_names[@]}"; do
                for size in "48x48" "32x32" "24x24" "22x22" "16x16" "scalable"; do
                    for category in "apps" "applications" ""; do
                        for ext in "svg" "png" "xpm"; do
                            icon_path="$dir/$size/$category/$name.$ext"
                            if [[ -f "$icon_path" ]]; then
                                echo "$icon_path"
                                return
                            fi
                        done
                    done
                done
            done
        fi
    done
    
    # Último recurso: icono genérico
    echo ""
}

main() {
    local output=""
    local tooltip=""
    local apps_seen=()
    
    if command -v hyprctl &> /dev/null; then
        # Para Hyprland
        while IFS= read -r client; do
            class=$(echo "$client" | jq -r '.class // empty')
            title=$(echo "$client" | jq -r '.title // empty')
            
            [[ -z "$class" ]] && continue
            
            # Evitar duplicados
            for seen in "${apps_seen[@]}"; do
                [[ "$seen" == "$class" ]] && continue 2
            done
            apps_seen+=("$class")
            
            icon_path=$(get_app_icon "$class" "$title")
            
            if [[ -n "$icon_path" && -f "$icon_path" ]]; then
                # Usar el icono real del sistema
                output+="<span font='12'><img src='file://$icon_path' width='16' height='16'/></span> "
                tooltip+="$class: $title\n"
            else
                # Fallback a iconos de fuentes (Nerd Fonts)
                case "${class,,}" in
                    *firefox*|*mozilla*) output+=" " ;;
                    *chrom*|*brave*) output+=" " ;;
                    *code*|*codium*|*vscode*) output+=" " ;;
                    *terminal*|*kitty*|*alacritty*|*foot*) output+=" " ;;
                    *discord*) output+="󰙯 " ;;
                    *spotify*) output+=" " ;;
                    *steam*) output+=" " ;;
                    *gimp*) output+=" " ;;
                    *files*|*nautilus*|*dolphin*) output+=" " ;;
                    *libreoffice*|*writer*) output+=" " ;;
                    *calc*) output+=" " ;;
                    *thunderbird*|*mail*) output+=" " ;;
                    *obs*) output+=" " ;;
                    *vlc*|*mpv*) output+="嗢 " ;;
                    *) output+=" " ;;
                esac
                tooltip+="$class: $title\n"
            fi
        done < <(hyprctl clients -j | jq -c '.[] | select(.workspace.id > 0)')
        
    elif command -v swaymsg &> /dev/null; then
        # Para Sway
        while IFS= read -r node; do
            app_id=$(echo "$node" | jq -r '.app_id // .window_properties.class // empty')
            name=$(echo "$node" | jq -r '.name // empty')
            
            [[ -z "$app_id" ]] && continue
            
            # Evitar duplicados
            for seen in "${apps_seen[@]}"; do
                [[ "$seen" == "$app_id" ]] && continue 2
            done
            apps_seen+=("$app_id")
            
            icon_path=$(get_app_icon "$app_id" "$name")
            
            if [[ -n "$icon_path" && -f "$icon_path" ]]; then
                output+="<span font='12'><img src='file://$icon_path' width='16' height='16'/></span> "
                tooltip+="$app_id: $name\n"
            else
                # Mismo fallback que arriba...
                case "${app_id,,}" in
                    *firefox*|*mozilla*) output+=" " ;;
                    *chrom*|*brave*) output+=" " ;;
                    *code*|*codium*|*vscode*) output+=" " ;;
                    *terminal*|*kitty*|*alacritty*|*foot*) output+=" " ;;
                    *discord*) output+="󰙯 " ;;
                    *spotify*) output+=" " ;;
                    *) output+=" " ;;
                esac
                tooltip+="$app_id: $name\n"
            fi
        done < <(swaymsg -t get_tree | jq -c '.. | select(.type?) | select(.type == "con") | select(.app_id != null or .window_properties.class != null)')
    fi
    
    # Limpiar espacios extra
    output=$(echo "$output" | sed 's/ *$//')
    tooltip=$(echo -e "$tooltip" | sed 's/\\n$//')
    
    if [[ -n "$output" ]]; then
        echo "{\"text\":\"$output\",\"tooltip\":\"$tooltip\"}"
    else
        echo "{\"text\":\"\",\"tooltip\":\"No hay aplicaciones abiertas\"}"
    fi
}

main
