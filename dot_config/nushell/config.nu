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

# Dotfiles management
alias cz = cd ~/.local/share/chezmoi

# Better 'cd' that automatically lists files
def --env c [dir: path] {
    cd $dir
    ls -a
}

# Sesh + FZF session switcher
def --env t [] {
    # 1. Get the list of possible project directories for FZF
    let project_paths = (
      fd 
        --mindepth 1 
        --maxdepth 1 
        --type d 
        . ~/git ~/git-templates ~/remotes 
        | lines | sort
    )
    
    # 2. Get existing sessions as plain strings
    let existing_sessions = (
        sesh list -j 
        | from json 
        | get Name 
        | prepend "--- Connect to Existing Session ---"
    )
    
    # 3. Combine both lists and let the user select one
    let all_options = ($project_paths | append $existing_sessions)
    let selection = (
        $all_options 
        | str join (char newline)
        | fzf --height 40% --reverse --border 
        | str trim
    )
    
    if ($selection | is-empty) {
        return # User canceled
    }
    
    # 4. Handle selection
    if ($selection == "--- Connect to Existing Session ---") {
        let session_to_connect = (
            sesh list -j 
            | from json 
            | get name 
            | str join (char newline)
            | fzf --height 40% --reverse --border 
            | str trim
        )
        if not ($session_to_connect | is-empty) {
            sesh connect $session_to_connect
        }
    } else if $selection in $project_paths {
        let session_name = ($selection | path basename | str replace '.' '_')
        sesh connect -s $session_name -c $selection
    } else {
        sesh connect $selection
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
