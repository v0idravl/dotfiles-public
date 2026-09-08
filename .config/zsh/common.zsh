# common.zsh — the shell core. Sourced from ~/.zshrc.
# Edit HERE for anything every shell should get; keep only machine-specific
# pieces (prompt colors, PATH extras, ssh-agent socket, tmux auto-attach)
# in ~/.zshrc or ~/.zshrc.local.

# ── Core behavior ──────────────────────────────────────────────
setopt autocd
setopt interactivecomments
setopt nonomatch
setopt notify
setopt promptsubst

WORDCHARS='_-'
PROMPT_EOL_MARK=""

# ── History ────────────────────────────────────────────────────
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_verify
setopt hist_find_no_dups
setopt share_history
alias history="history 0"

# ── Completion ─────────────────────────────────────────────────
# -C skips the security re-check of every completion dir on every shell start
# (this file is sourced by every new tmux pane, so the check is felt dozens of
# times a day). Trade-off: completions installed later won't appear until the
# dump is rebuilt — `rm ~/.cache/zcompdump` and open a new shell.
autoload -Uz compinit
compinit -C -d ~/.cache/zcompdump
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' rehash true
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Newline before each prompt (after the first)
precmd() {
    if [ -z "$_NEW_LINE_BEFORE_PROMPT" ]; then
        _NEW_LINE_BEFORE_PROMPT=1
    else
        print ""
    fi
}

# ── Colors for ls, grep, etc. ──────────────────────────────────
eval "$(dircolors -b)"
export LS_COLORS="$LS_COLORS:ow=30;44:"

# ── eza: colorful ls, always show hidden files ─────────────────
# Guarded so a missing tool degrades silently instead of breaking ls.
if command -v eza >/dev/null 2>&1; then
    alias ls='eza --color=always --icons --group-directories-first --all'
    alias ll='eza --color=always --icons --group-directories-first --all --long --header'
    alias lt='eza --color=always --icons --group-directories-first --all --tree --level=2'
    alias la='eza --color=always --icons --all'
else
    alias ls='ls --color=always --all'
    alias ll='ls --color=always --all -lh'
    alias lt='ls --color=always --all -R'
    alias la='ls --color=always --almost-all'
fi

# ── Navigation ─────────────────────────────────────────────────
setopt auto_pushd
setopt pushd_ignore_dups
alias ..='cd ..'
alias ...='cd ../..'
alias bd='popd'
alias t=tmux
# nvim aliases — guarded so a host without neovim keeps plain vim
if command -v nvim >/dev/null 2>&1; then
    alias v=nvim
    alias vim=nvim
fi
# Debian packages bat as batcat; other distros ship it as plain bat.
if command -v batcat >/dev/null 2>&1; then
    alias bat='batcat'
    alias cat='batcat --paging=never'
elif command -v bat >/dev/null 2>&1; then
    alias cat='bat --paging=never'
fi

# ── Safe defaults ──────────────────────────────────────────────
alias mkdir='mkdir -pv'
alias cp='cp -iv'
alias mv='mv -iv'
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias ip='ip --color=auto'

# ── Pager & editor ─────────────────────────────────────────────
# less: F quit if it fits one screen · R render colors · X keep output on
# quit (FRX = git's own pager default, so git log/diff behave the same)
# · i smartcase search (capital in pattern = exact case, like nvim)
# · incsearch = search jumps as you type · mouse wheel scrolls.
export LESS='-FRXi --incsearch --mouse --wheel-lines=3'
# EDITOR: less `v`, git commit, crontab -e. First found wins —
# a minimal install with no nvim lands on nano.
for editor in nvim vim nano vi; do
    if command -v "$editor" >/dev/null 2>&1; then
        export EDITOR="$editor"
        export VISUAL="$editor"
        break
    fi
done

# ── Keybindings ────────────────────────────────────────────────
# no ^R here: fzf's key-bindings (sourced below) own ^R
bindkey -e
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[3~' delete-char
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

# ── Plugins ────────────────────────────────────────────────────
# apt installs these under /usr/share on Debian; the ~/.zsh/plugins fallback
# covers a manual clone. Missing plugins are skipped silently.
for plug in zsh-syntax-highlighting zsh-autosuggestions; do
    for plugdir in /usr/share ~/.zsh/plugins; do
        if [[ -r "$plugdir/$plug/$plug.zsh" ]]; then
            source "$plugdir/$plug/$plug.zsh"
            break
        fi
    done
done
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=244'

# ── fzf ────────────────────────────────────────────────────────
# apt ships the zsh hooks under doc/examples
for fzfdir in /usr/share/doc/fzf/examples; do
    if [[ -r "$fzfdir/key-bindings.zsh" ]]; then
        source "$fzfdir/key-bindings.zsh"
        source "$fzfdir/completion.zsh"
        break
    fi
done

export PATH="$HOME/.local/bin:$PATH"

# collapse duplicate entries (this file is re-sourced in every tmux pane)
typeset -U path PATH
