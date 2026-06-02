# -------------------------------------------------------------------------
# ~/.zshrc — Optimized
# -------------------------------------------------------------------------

# 1. CORE ENVIRONMENT & PATH
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
export ZSH="$HOME/.oh-my-zsh"

# 2. OH-MY-ZSH TUNING
# Prevents terminal freezing in massive monorepos (node_modules)
DISABLE_UNTRACKED_FILES_DIRTY="true"
# Fallback theme if Starship ever fails to compile
ZSH_THEME="robbyrussell"

# 3. PLUGINS PIPELINE
plugins=(
    git
    sudo
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# 4. MULTIPLIER INTEGRATIONS

# Node.js Version Manager (fnm)
eval "$(fnm env --use-on-cd --shell zsh)"

# Python Version Manager (pyenv)
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# Python Application Runner (pipx)
export PATH="$HOME/.local/bin:$PATH"

# FZF: Universal fuzzy finder for history (Ctrl+R) and files (Ctrl+T)
eval "$(fzf --zsh)"

# Zoxide: Smarter directory jumping
eval "$(zoxide init zsh)"

# 5. HIGH-SIGNAL ALIASES
alias cd="z"
alias ls="eza --icons --group-directories-first"
alias ll="eza -lh --icons --group-directories-first"
alias la="eza -lah --icons --group-directories-first"
alias tree="eza --tree --icons"
alias cat="bat --style=plain --paging=never"

# System operations
alias update="yay -Syu"
alias install="yay -S"
alias remove="yay -Rns"

# Dotfiles bare repository macro (Retained from original)
alias dots='/usr/bin/git --git-dir=$HOME/.dotfiles.git/ --work-tree=$HOME'

# 6. KEYBINDING FIXES
# Ensure Ctrl+Backspace deletes whole words backwards cleanly
bindkey '^H' backward-kill-word
bindkey '5~' kill-word

# 7. PROMPT & TELEMETRY
# Load Starship as the primary visual prompt
eval "$(starship init zsh)"

# Print system metrics on new session launch
fastfetch
