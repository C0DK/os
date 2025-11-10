let carapace_completer = {|spans|
  # if the current command is an alias, get it's expansion
  let expanded_alias = (scope aliases | where name == $spans.0 | get -i 0 | get -i expansion)

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
      normal: '%Y-%m-%dTH:%M:%S%z'  # shows up in displays of variables or other datetime's outside of tables
      table: '%Y-%m-%dTH:%M:%S%z'        # generally shows up in tabular outputs such as ls
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
    | filter {|b| not (($b | str contains "->") or ($b | str starts-with "*"))}
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



alias "dn format" = dotnet csharpier format .;

def fzf_repos [query?: string] {
    let repos = ($env.REPOS? | default "~/Documents" | path expand)

    glob $"($repos)/**/*/.git"
    | path dirname
    | each { |full|
        let pretty = ($full | str replace -r $"^($repos)/" "")
        $"($full)\t($pretty)"
    }
    | pretty_fzf $query
}

def --env cr [query?: string] {
  let path = fzf_repos $query
  cd $path
}
def --env vir [query?: string] {
  let path = fzf_repos $query
  cd $path
  setAppTitle "NeoVIM" $path
  vi
}
$env.PATH = ($env.PATH |
    split row (char esep) |
    append /usr/bin/env |
    append /home/cwb/.local/bin
)

open ~/.env | from toml | load-env;

$env.SSH_AUTH_SOCK = (gpgconf --list-dirs agent-ssh-socket)
