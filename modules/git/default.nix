{
  user,
  fullName,
  email,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    delta
    git-branchless
    worktrunk
  ];

  home-manager.users.${user}.programs.git = {
    enable = true;
    lfs.enable = true;

    ignores = [
      "**/cwb.env"
      "**/*.cwb.env"
      "**/*.claude"
      "**/*CLAUDE.local.md"
    ];
    settings = {
      "url \"git@github.com:\"" = {
        insteadOf = "https://github.com/";
      };
      user = {
        inherit email;
        name = fullName;
        signingKey = "2E1DC0FF50920EDDDE1757D9881239F715822BB7";
      };
      core = {
        editor = "hx";
        pager = "delta";
      };
      interactive = {
        diffFilter = "delta --color-only";
      };
      delta = {
        navigate = true;
        line-numbers = true;

        minus-style = "syntax normal";
        minus-emph-style = "bold syntax '#5b3a3a'";

        # Override: transparent-friendly plus (added lines)
        plus-style = "syntax normal";
        plus-emph-style = "bold syntax '#2e4a3e'";

        # Boost left-side line number visibility
        line-numbers-left-style = "#b4befe"; # catppuccin lavender — stands out clearly
        line-numbers-minus-style = "bold '#f38ba8'";
        line-numbers-right-style = "#585b70";
        line-numbers-zero-style = "#585b70";
      };
      branchless = {
        commands.verbosity = 0;
      };
      merge = {
        conflictStyle = "zdiff3";
      };
      signing = {
        key = "2E1DC0FF50920EDDDE1757D9881239F715822BB7";
      };
      commit = {
        gpgsign = true;
      };
      gpg = {
        program = "gpg2";
      };
      credential = {
        helper = "cache --timeout=600";
      };
      rebase = {
        autoStash = true;
      };
      pull = {
        ff = "only";
        rebase = true;
      };
      fetch = {
        output = "compact";
      };
      push = {
        autoSetupRemote = 1;
        default = "upstream";
      };
      init = {
        defaultBranch = "main";
      };
      color = {
        diff = "auto";
        status = "auto";
        branch = "auto";
        interactive = "auto";
        ui = true;
        pager = true;
      };
      alias = {
        # Branch / checkout
        co = "checkout -q";
        cod = "checkout --detach -q";
        com = "!f(){ git checkout $(git main-branch) -q $@;}; f";
        cob = "checkout -b -q";
        back = "checkout - -q";
        cobp = ''!f() { git cob "$@" && git publish; }; f'';

        # Branch management
        br = "branch";
        brd = "branch -d";
        brD = "branch -D";
        "branch-name" = "rev-parse --abbrev-ref HEAD";
        brDm = ''!f() { git branch --merged | grep -Ev "(^\*|^\+|main|master)" | sed 's/origin\///' | xargs --no-run-if-empty -n 1 git br -d; }; f'';
        "main-branch" = "!git symbolic-ref refs/remotes/origin/HEAD | cut -d'/' -f4";
        remotesh = "remote set-head origin --auto";

        # Status / staging
        st = "status";
        aa = "add -A";
        f = "!git ls-files | grep -i";
        gr = "grep -Ii";
        la = "!git config -l | grep alias | cut -c 7-";

        # Commit
        cm = "commit -m";
        ca = "commit --aamend";
        aacm = "!git aa && git commit -m";
        aaacm = "aacm";
        aacmp = ''!f() { git aa && git commit -m "$@" && git push; }; f'';
        amend = "commit --amend --no-edit";
        aamend = "!git aa && git amend";
        aamende = "!git aa && git commit --amend";
        "amend-edit" = "commit --amend";
        aamendp = "!git aa && git amend && git push --force";
        aaamendp = "!git aa && git amend && git push --force";

        # Conventional commit helpers
        ops = ''!f() { git commit -m "ops: $@"; }; f'';
        aops = "!git aa && git ops";
        feat = ''!f() { git commit -m "feat: $@"; }; f'';
        afeat = "!git aa && git feat";
        fix = ''!f() { git commit -m "fix: $@"; }; f'';
        afix = "!git aa && git fix";
        refactor = ''!f() { git commit -m "refactor: $@"; }; f'';
        arefactor = "!git aa && git refactor";
        style = ''!f() { git commit -m "style: $@"; }; f'';
        astyle = "!git aa && git style";
        test = ''!f() { git commit -m "test: $@"; }; f'';
        atest = "!git aa && git test";
        wip = ''!f() { git commit -m "wip: $@"; }; f'';
        awip = "!git aa && git wip";
        docs = ''!f() { git commit -m "docs: $@"; }; f'';
        adocs = "!git aa && git docs";
        chore = ''!f() { git commit -m "chore: $@"; }; f'';
        achore = "!git aa && git chore";
        migrate = ''!f() { git commit -m "migrate: $@"; }; f'';

        # Pull / push
        pl = "pull -q";
        ps = "push";
        pushf = "push --force";
        pf = "pushf";
        psf = "pushf";
        prbm = "!f(){ git pull --rebase origin $(git main-branch) $@;}; f";

        # Rebase
        rb = "rebase";
        rbm = "!f(){ git rebase $(git main-branch) $@;}; f";
        rbi = "rebase -i";
        rbim = "!f(){ git rebase -i $(git main-branch) $@;}; f";
        rbc = "rebase --continue";
        rbe = "rebase --edit-todo";
        rba = "rebase --abort";
        arbc = "!git aa && git rbc";
        aarbc = "arbc";

        # Reset / undo
        unstage = "reset --soft HEAD^";
        uncommit = "reset --soft HEAD~1";
        drop = "reset --hard HEAD";

        # Cherry-pick
        cp = "cherry-pick";

        di = "! f() { git log --no-color --no-decorate | bat -n -l 'Git log' ; }; f";
        # Log
        lo = "! f() { git log --no-color --no-decorate | bat -n -l 'Git log' ; }; f";

        who = "shortlog --summary --";
        whorank = "shortlog --summary --numbered --no-merges";
      };
    };
  };
}
