require boxen::environment
require homebrew
require gcc

Exec {
  group       => 'staff',
  logoutput   => on_failure,
  user        => $boxen_user,

  path => [
    "${boxen::config::home}/rbenv/shims",
    "${boxen::config::home}/rbenv/bin",
    "${boxen::config::home}/rbenv/plugins/ruby-build/bin",
    "${boxen::config::home}/homebrew/bin",
    '/usr/bin',
    '/bin',
    '/usr/sbin',
    '/sbin'
  ],

  environment => [
    "HOMEBREW_CACHE=${homebrew::config::cachedir}",
    "HOME=/Users/${::boxen_user}"
  ]
}

File {
  group => 'staff',
  owner => $boxen_user
}

Package {
  provider => homebrew,
  require  => Class['homebrew']
}

Repository {
  provider => git,
  extra    => [
    '--recurse-submodules'
  ],
  require  => File["${boxen::config::bindir}/boxen-git-credential"],
  config   => {
    'credential.helper' => "${boxen::config::bindir}/boxen-git-credential"
  }
}

Service {
  provider => ghlaunchd
}

Homebrew::Formula <| |> -> Package <| |>

node default {
  # core modules, needed for most things
  include dnsmasq
  include git
  include hub
  include nginx

  # node versions
  nodejs::version { 'v0.10': }

  # default ruby versions
  ruby::version { '2.1.2': }

  # common, useful packages
  package {
    [
      'ack',
      'findutils',
      'gnu-tar'
    ]:
  }

  # general development tools
  include iterm2::dev
  include zsh
  include ohmyzsh
  include github_for_mac

  # generate computer tools
  include appcleaner
  include daisy_disk

  # additional modules needed to edit this project
  file { "${boxen::config::srcdir}/boxen":
    ensure => link,
    target => $boxen::config::repodir
  }
  include sublime_text
  sublime_text::package { 'Package Control':
    source => 'wbond/sublime_package_control'
  }
  sublime_text::package { 'Puppet':
    source => 'russCloak/SublimePuppet'
  }
  sublime_text::package { 'Google Spell Check':
    source => 'noahcoad/google-spell-check'
  }
  sublime_text::package { 'MarkdownEditing':
    source => 'SublimeText-Markdown/MarkdownEditing'
  }

}
