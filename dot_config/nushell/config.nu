$env.config.show_banner = false
$env.config.buffer_editor = "nvim" # Use nvim when editing the command line (Ctrl+o)

$env.config.edit_mode = "vi"

source ($nu.default-config-dir | path join 'scripts/starship.nu')
source ($nu.default-config-dir | path join 'scripts/zoxide.nu')
source ($nu.default-config-dir | path join 'scripts/atuin.nu')

# --- 3. ALIASES ---
# Common shortcuts
alias l = ls -a
alias ll = ls -l -a
alias g = git
alias n = nvim
alias cat = bat
alias grep = rg

# Dotfiles management (shortcut to jump to chezmoi)
alias cz = cd ~/.local/share/chezmoi


# A better 'cd' that automatically lists files after entering
def --env c [dir: path] {
    cd $dir
    ls -a
}

# Sesh + FZF Workflow (The "Killer Feature")
# Typing 'ss' will open a fuzzy finder of your sessions/projects.
# If you select one, it switches to it.
def --env t [] {
    let session = (sesh list | fzf --height 40% --reverse --border)
    if ($session | is-empty) == false {
        sesh connect $session
    }
}

# --- 5. KEYBINDINGS ---
$env.config.keybindings = (
    $env.config.keybindings
    | append {
        name: sesh_launcher
        modifier: control
        keycode: char_t
        mode: [emacs, vi_normal, vi_insert]
        event: {
            send: executehostcommand
            cmd: "t"
        }
    }
)
