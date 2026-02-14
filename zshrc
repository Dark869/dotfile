# Exports
export PATH=$PATH:/home/dark869/.local/bin

# Lanzador de fastfetch
fastfetch

# Configuración de ohmyposh
eval "$(oh-my-posh init zsh --config ~/dotfile/config/ohmyposh/clean-detailed.omp.json)"

# Alias
alias ll='ls -l'
alias la='ls -la'
alias mkdir='mkdir -p'
alias c='clear'

# Plugin para completado (zsh)
fpath=(/usr/share/zsh/site-functions $fpath)
autoload -Uz compinit
compinit
zstyle ':completion:*' menu select                          # Menú visual para seleccionar
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'        # Case insensitive
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"    # Colores en completado
setopt COMPLETE_ALIASES                                     # Completar aliases
setopt AUTO_LIST                                            # Mostrar lista automáticamente
setopt AUTO_MENU                                            # Usar menú de completado

# Plugin recomendaciones-autocompletado (zsh)
HISTFILE=~/.zsh_history      # Archivo donde se guarda
HISTSIZE=10000               # Comandos en memoria
SAVEHIST=10000               # Comandos guardados en archivo
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# Plugin resaltado de comandos (zsh)
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
