#plugin add /run/current-system/sw/bin/nu_plugin_polars
#plugin use polars


def pg [query?:string ...rest: string] {
    let db = (open ~/.config/pgcli/config
            | from toml
            | get alias_dsn
            | columns
            | tv-from-list --input $"($query)" --select-1 --input-header "Select database")
    setAppTitle "Postgres" $db
    echo $db
    pgcli -D $db ...$rest
}

let carapace_completer = {|spans|
  # if the current command is an alias, get it's expansion
  let expanded_alias = (scope aliases | where name == $spans.0 | get -o 0 | get -o expansion)

  # overwrite
  let spans = (if $expanded_alias != null  {
    # put the first word of the expanded alias first in the span
    $spans | skip 1 | prepend ($expanded_alias | split row " " | take 1)
  } else {
    $spans
  })

  carapace $spans.0 nushell ...$spans
  | from json
}

$env.config = {
    show_banner: false,
    hooks: {
      pre_prompt: [
        {||
          let cwd = ($env.PWD | str replace $env.HOME "~");
          print -n $"\e]0;($cwd)\e\\"
        }
      ]
    },


  keybindings: [
      {
        name: fuzzy_finder
        modifier: control
        keycode: char_p
        mode: [emacs, vi_normal, vi_insert]
        event: [
          {
            send: ExecuteHostCommand
            cmd: " do {
              let to_insert = (tv channels)
              if ($to_insert | is-empty) {
                return
              }

              commandline edit --insert $to_insert
            }"
          }
        ]
      },
      {
      name: gotorepo
      modifier: control
      keycode: char_g
      mode: [emacs, vi_normal, vi_insert]
      event: [
        {
          send: ExecuteHostCommand
          cmd: "
            let path = tv git-repos --select-1 --exact
            if ($path | is-empty) {
              return
            }

            cd $path
          "
        }
      ]
    },
    {
      name: editrepo
      modifier: control
      keycode: char_e
      mode: [emacs, vi_normal, vi_insert]
      event: [
        {
          send: ExecuteHostCommand
          cmd: "
            let path = tv git-repos --select-1 --exact
            if ($path | is-empty) {
              return
            }

            setAppTitle 'Helix' $path
            cd $path
            hx
          "
        }
      ]
    },
    ],
    completions: {
        case_sensitive: false # case-sensitive completions
        quick: true    # set to false to prevent auto-selecting completions
        partial: true    # set to false to prevent partial filling of the prompt
        algorithm: "fuzzy"    # prefix or fuzzy
        external: {
            # set to false to prevent nushell looking into $env.PATH to find more suggestions
            enable: true
            # set to lower can improve completion performance at the cost of omitting some options
            max_results: 100
            completer: $carapace_completer # check 'carapace_completer'
        }
    },
    ls: {
      clickable_links: false
    },
    float_precision: 10,
    datetime_format: {
      normal: '%Y-%m-%dT%H:%M:%S%z'  # shows up in displays of variables or other datetime's outside of tables
      table: '%Y-%m-%dT%H:%M:%S%z'        # generally shows up in tabular outputs such as ls
    },
    edit_mode: 'vi'

}
$env.GITHUB_TOKEN = (gh auth token);

def setTitle [title: string] {
  print $"\e]0;($title)\e\\"
}

def setAppTitle [title: string, loc: string] {
  setTitle $"($title) | ($loc)"
}

def --env tmux-switch [] {
          do {
            let session = (tv tmux-sessions --select-1 --exact)
            if ($session | is-empty) {
              return
            }
            if ($env | get -o TMUX | is-not-empty) {
              tmux switch-client -t $session
            } else {
              tmux attach -t $session
            }
          }
}


alias builtin-vi = vi; 


def vi [...rest] {
  let path = pwd;
  setAppTitle "NeoVIM" $path
  builtin-vi ...$rest

}

def simple_fzf [query?: string] {
  $in
  | each {|entry| 
    $"($entry)\t($entry)"
    }
  | pretty_fzf $query
}

def pprint [first: string, ...rest: string] {
  print $"(ansi blue_dimmed)($first)(ansi reset) ($rest | str join ' ')"
}


alias g = git
def "g co" [query?: string] {
  let branch = (git branch -a 
    | lines 
    | where {|b| not (($b | str contains "->") or ($b | str starts-with "*"))}
    | str trim 
    | str replace --regex "^remotes\/origin\/" ""
    | str trim 
    | simple_fzf $query)

  git switch $branch
}


alias "g pr view" = gh pr view --web

def --env "g pr" [] {
    pprint "Pushing"
    git push -q

    pprint "Creating pull request"
    let status = (gh pr create --fill-verbose) | complete;
    if $status.exit_code == 1 {
      print $"(ansi red_bold)failed:(ansi reset)"
      print $status.stderr
      return
    }
    pprint "Done!"

    g pr view
}


def "g new" [msg: string] {
    let parsed = ($msg | parse --regex '^(?P<type>\w+)(?:\((?P<scope>[^)]+)\))?:\s*(?P<subject>.+)$')
    if ($parsed | is-empty) {
        error make { msg: "format: 'type: subject' or 'type(scope): subject'" }
    }
    let type = ($parsed | get type.0)
    let scope = ($parsed | get scope.0)
    let subject = ($parsed | get subject.0)

    let slug = ($subject | str lowercase | str replace --all --regex '[^a-z0-9]+' '-' | str replace --all --regex '^-+|-+$' '')
    let branch = $"($type)/($slug)"

    # Capture dirty files before switching so we can show them clearly.
    let dirty = (git status --porcelain | lines)

    pprint "Switching to main"
    git checkout -q main out+err> /dev/null

    pprint "Pulling"
    git pull -q --ff-only out+err> /dev/null

    pprint $"Creating ($branch)"
    git checkout -q -b $branch out+err> /dev/null

    git config $"branch.($branch).gType" $type
    git config $"branch.($branch).gSubject" $subject
    if ($scope | is-not-empty) { git config $"branch.($branch).gScope" $scope }

    let label = if ($scope | is-empty) { $"($type): ($subject)" } else { $"($type)\(($scope)\): ($subject)" }
    print $"(ansi green_bold)✓(ansi reset) ($branch)"
    print $"  ($label)"

    if ($dirty | is-not-empty) {
        print $"(ansi yellow)carried over:(ansi reset)"
        for line in $dirty {
            let status = ($line | str substring 0..2)
            let file = ($line | str substring 3..)
            print $"  (ansi yellow)($status)(ansi reset) ($file)"
        }
    }
}
def "g done" [] {
    let branch = (git rev-parse --abbrev-ref HEAD | str trim)
    let type = (git config --get $"branch.($branch).gType" | str trim)
    let subject = (git config --get $"branch.($branch).gSubject" | str trim)
    let scope = (do { git config --get $"branch.($branch).gScope" } | complete | get stdout | str trim)

    if ($type | is-empty) or ($subject | is-empty) {
        error make { msg: $"no g-state on ($branch) — was it made with `g new`?" }
    }

    let commit_msg = if ($scope | is-empty) { $"($type): ($subject)" } else { $"($type)\(($scope)\): ($subject)" }

    git add --all
    git commit -m $commit_msg
}

alias dn = dotnet
alias "dn format" = dotnet csharpier format .;


# def "dn w" [query? :string, ...rest: string] {
#   let project = tv dotnet-projects --input $"($query)" --select-1
#   dotnet watch --project $project ...$rest
# }

# def "dn r" [query? :string, ...rest: string] {
#   let project = tv dotnet-projects --input $"($query)" --select-1
#   dotnet run --project $project ...$rest
# }


def --env cr [query?: string] {
  let path = tv git-repos --select-1 --exact --input $"($query)"
  cd $path
}

$env.PATH = ($env.PATH |
    split row (char esep) |
    append /usr/bin/env |
    append /home/cwb/.local/bin |
    append /home/cwb/.dotnet/tools/
)

open ~/.env | from toml | load-env;

$env.SSH_AUTH_SOCK = (gpgconf --list-dirs agent-ssh-socket)


def box-header [title: string, color: string] {
    let w = ($title | str length) + 2
    let bar = (0..<$w | each {|_| "─" } | str join)
    print ""
    print $"(ansi $color)╭($bar)╮(ansi reset)"
    print $"(ansi $color)│ ($title) │(ansi reset)"
    print $"(ansi $color)╰($bar)╯(ansi reset)"
}

def emoji-color [emoji: string] {
    match $emoji {
        "✅" => "green_bold",
        "❌" => "red_bold",
        "⭐" => "yellow",
        "🐳" => "blue",
        "🚀" => "purple_bold",
        "⚙" => "magenta",
        "☁" => "cyan",
        _ => "white",
    }
}

def "act pretty" [...args: string] {
    mut scope = ""
    for line in (^act ...$args | lines) {
        let parsed = ($line | parse -r '^\[(?P<scope>[^\]]+)\]\s+(?P<emoji>\S*)\s*(?P<msg>.*)$')

        if ($parsed | is-empty) {
            # lines act prints without a [job/step] prefix (errors, summaries)
            print $"(ansi grey)($line)(ansi reset)"
            continue
        }

        let row = ($parsed | first)

        if $row.scope != $scope {
            $scope = $row.scope
            box-header $scope "cyan_bold"
        }

        let color = (emoji-color $row.emoji)
        print $"  (ansi $color)($row.emoji)(ansi reset) ($row.msg)"
    }
}
