let brew_linux = '/home/linuxbrew/.linuxbrew/bin'
let brew_mac_arm = '/opt/homebrew/bin'
let brew_mac_intel = '/usr/local/bin'
let local_bin = ($env.HOME | path join '.local/bin')
let cargo_bin = ($env.HOME | path join '.cargo/bin')

$env.PATH = (
  $env.PATH
  | split row (char esep)
  | prepend $local_bin
  | prepend $cargo_bin
  | prepend $brew_linux
  | prepend $brew_mac_arm
  | prepend $brew_mac_intel
  | uniq
)

$env.EDITOR = 'nvim'
$env.VISUAL = 'nvim'


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
