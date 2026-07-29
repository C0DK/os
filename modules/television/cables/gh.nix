{ user, ... }:
{
  home-manager.users.${user}.xdg.configFile = {
    "television/cable/gh-issues.toml" = {
      force = true;
      text = ''
        [metadata]
        name = "gh-issues"
        description = "List GitHub issues for the current repo"
        requirements = ["gh", "jq"]

        [source]
        command = "gh issue list --state open --limit 100 --json number,title,createdAt,author,labels | jq -r 'sort_by(.createdAt) | reverse | .[] | \"  \u001b[32m#\(.number)\u001b[39m   \(.title) \u001b[33m@\(.author.login)\u001b[39m\" + (if (.labels | length) > 0 then \" \" + ([.labels[] | \"\u001b[35m\" + .name + \"\u001b[39m\"] | join(\" \")) else \"\" end)'"
        shell = "bash"
        ansi = true
        output = "{strip_ansi|split:#:1|split: :0}"

        [preview]
        command = "gh issue view '{strip_ansi|split:#:1|split: :0}'"

        [ui.preview_panel]
        header = "{strip_ansi|split:#:1|split: :0}"
      '';
    };

    "television/cable/gh-prs.toml" = {
      force = true;
      text = ''
        [metadata]
        name = "gh-prs"
        description = "List GitHub PRs for the current repo"
        requirements = ["gh", "jq"]

        [source]
        command = "gh pr list --state open --limit 100 --json number,title,createdAt,author,labels | jq -r 'sort_by(.createdAt) | reverse | .[] | \"  \u001b[32m#\(.number)\u001b[39m   \(.title) \u001b[33m@\(.author.login)\u001b[39m\" + (if (.labels | length) > 0 then \" \" + ([.labels[] | \"\u001b[35m\" + .name + \"\u001b[39m\"] | join(\" \")) else \"\" end)'"
        shell = "bash"
        ansi = true
        output = "{strip_ansi|split:#:1|split: :0}"

        [preview]
        command = "gh pr view '{strip_ansi|split:#:1|split: :0}'"

        [ui.preview_panel]
        header = "{strip_ansi|split:#:1|split: :0}"
      '';
    };
  };
}
