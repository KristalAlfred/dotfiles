# Nushell configuration

$env.config.show_banner = false
$env.config.buffer_editor = "nvim"
$env.config.edit_mode = "vi"

# Source integrations
source ($nu.default-config-dir | path join 'scripts/starship.nu')
source ($nu.default-config-dir | path join 'scripts/zoxide.nu')
source ($nu.default-config-dir | path join 'scripts/atuin.nu')

# Carapace completions
if (($nu.default-config-dir | path join 'scripts/carapace.nu') | path exists) {
    source ($nu.default-config-dir | path join 'scripts/carapace.nu')
}

# --- ALIASES ---
# Common shortcuts
alias l = ls -a
alias ll = ls -l -a
alias n = nvim
alias cat = bat
alias grep = rg

# Git aliases
alias g = git
alias gs = git status -sb
alias gc = git commit
alias gac = git add -A; git commit -m

# Dotfiles management
alias cz = cd ~/.local/share/chezmoi

# Better 'cd' that automatically lists files
def --env c [dir: path] {
    cd $dir
    ls -a
}

# Sesh + FZF session switcher
def --env t [] {
    let session = (sesh list | fzf --height 40% --reverse --border)
    if ($session | is-empty) == false {
        sesh connect $session
    }
}

# --- DOCKER HELPERS ---
# Fuzzy select running containers
def dsel [] {
    docker ps --format "{{.Names}}\t{{.Image}}\t{{.ID}}\t{{.CreatedAt}}" | fzf -m
}

# Get container IDs from selection
def did [] {
    dsel | lines | parse "{name}\t{image}\t{id}\t{created}" | get id
}

# Enter a selected container
def dexec [cmd: string = "/bin/bash"] {
    let selection = (dsel | lines | parse "{name}\t{image}\t{id}\t{created}")
    if ($selection | is-empty) {
        print "No container selected."
        return
    }
    let container = ($selection | first | get name)
    print $"Connecting to container: ($container)"
    docker exec -it $container $cmd
}

# View logs from selected container
def dlog [] {
    let ids = (did)
    if ($ids | is-empty) {
        print "No container selected."
        return
    }
    docker logs -f ($ids | first)
}

# OSC52 clipboard (useful for remote terminals)
def osc52 [] {
    let encoded = ($in | encode base64 --nopad)
    print $"\e]52;c;($encoded)\a"
}

# --- KEYBINDINGS ---
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
