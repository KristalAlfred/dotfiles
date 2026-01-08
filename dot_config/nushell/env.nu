# Nushell environment configuration

# PATH setup
let brew_linux = '/home/linuxbrew/.linuxbrew/bin'
let brew_mac_arm = '/opt/homebrew/bin'
let brew_mac_intel = '/usr/local/bin'
let local_bin = ($env.HOME | path join '.local/bin')
let cargo_bin = ($env.HOME | path join '.cargo/bin')
let dotnet_tools = ($env.HOME | path join '.dotnet/tools')
let personal_bin = ($env.HOME | path join 'personal/bin')
let flutter_bin = ($env.HOME | path join 'develop/flutter/bin')
let go_bin = ($env.HOME | path join 'go/bin')

$env.PATH = (
  $env.PATH
  | split row (char esep)
  | prepend $go_bin
  | prepend $flutter_bin
  | prepend $personal_bin
  | prepend $dotnet_tools
  | prepend $local_bin
  | prepend $cargo_bin
  | prepend $brew_linux
  | prepend $brew_mac_arm
  | prepend $brew_mac_intel
  | uniq
)

# Editor configuration
$env.EDITOR = 'nvim'
$env.VISUAL = 'nvim'

# Google Cloud SDK (if installed)
let gcloud_path = ($env.HOME | path join 'Downloads/google-cloud-sdk')
if ($gcloud_path | path exists) {
    $env.PATH = ($env.PATH | prepend ($gcloud_path | path join 'bin'))
}

# Tool initializations
mkdir ($nu.default-config-dir | path join 'scripts')

if (which zoxide | is-empty) == false {
    zoxide init nushell | save -f ($nu.default-config-dir | path join 'scripts/zoxide.nu')
}

if (which starship | is-empty) == false {
    starship init nu | save -f ($nu.default-config-dir | path join 'scripts/starship.nu')
}

if (which atuin | is-empty) == false {
    atuin init nu | save -f ($nu.default-config-dir | path join 'scripts/atuin.nu')
}

if (which carapace | is-empty) == false {
    carapace _carapace nushell | save -f ($nu.default-config-dir | path join 'scripts/carapace.nu')
}
