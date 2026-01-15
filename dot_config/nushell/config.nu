# Nushell configuration

$env.config.show_banner = false
$env.config.buffer_editor = "nvim"
$env.config.edit_mode = "vi"
$env.config.table.mode = "compact"  # or "thin"
#$env.config.table.truncate = "ellipsis"

# Source integrations
source ($nu.default-config-dir | path join 'scripts/starship.nu')
source ($nu.default-config-dir | path join 'scripts/zoxide.nu')
source ($nu.default-config-dir | path join 'scripts/atuin.nu')

# Carapace completions
if (($nu.default-config-dir | path join 'scripts/carapace.nu') | path exists) {
    source ($nu.default-config-dir | path join 'scripts/carapace.nu')
}

$env.PATH = ($env.PATH | prepend '/opt/homebrew/opt/ccache/libexec')

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

# Dotfiles management
alias cz = cd ~/.local/share/chezmoi

# Better 'cd' that automatically lists files
def --env c [dir: path] {
    cd $dir
    ls -a
}

# Tmux + FZF session switcher (Native version, no 'sesh')
# Tmux Project Switcher (Folders only)
def --env t [] {
    # 1. Get possible project directories
    let project_paths = (
        try { 
            # Adjust these paths to match your actual git directories
            fd --mindepth 1 --maxdepth 1 --type d . ~/git ~/git-templates ~/remotes
            | lines 
            | sort
        } catch { [] }
    )

    # 2. Select with FZF
    let selection = (
        $project_paths 
        | str join (char newline)
        | fzf --height 40% --reverse --border --header "Select Project Folder"
        | str trim
    )

    # Exit if cancelled
    if ($selection | is-empty) { return }

    # 3. Derive session name (folder name, replace . with _)
    let session_name = ($selection | path basename | str replace "." "_")

    # 4. Create session if it doesn't exist (detached)
    try {
        tmux new-session -d -s $session_name -c $selection
    }

    # 5. Connect (using your existing helper)
    _tmux_connect $session_name
}

# Helper to handle "Attach vs Switch" logic
def --env _tmux_connect [session_name: string] {
    if ($env.TMUX? | is-empty) {
        # We are NOT inside tmux -> Attach
        tmux attach-session -t $session_name
    } else {
        # We ARE inside tmux -> Switch client
        tmux switch-client -t $session_name
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
            send: ExecuteHostCommand
            cmd: "t"
        }
    }
)

$env.config.keybindings = $env.config.keybindings | append {
    name: paste_bash_multiline
    modifier: alt
    keycode: char_v
    mode: [emacs, vi_normal, vi_insert]
    event: { send: ExecuteHostCommand 
        cmd: r#'commandline edit (
                clip paste
                | str replace -ar '\\(?=\r?\n)' '' 
                | $"\(($in))"
            )'#
    }
}

# --- SPECIFIC TOOLS ---
#
# FNM
#
fnm env --json | from json | load-env
$env.PATH = ($env.PATH | prepend $"($env.FNM_MULTISHELL_PATH)/bin")


