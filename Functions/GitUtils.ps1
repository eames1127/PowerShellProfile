# Git shortcuts for a feature-branch -> pull request -> merge workflow

<#
.SYNOPSIS
Return the repo's default branch name (e.g. master or main).
#>
function getDefaultBranch {
    $ref = git symbolic-ref --quiet refs/remotes/origin/HEAD 2>$null
    if ($ref) { return ($ref -replace '^refs/remotes/origin/', '') }
    # origin/HEAD isn't always set on older clones - fall back to whichever exists
    foreach ($name in 'main', 'master') {
        git show-ref --verify --quiet "refs/heads/$name"
        if ($LASTEXITCODE -eq 0) { return $name }
    }
    return 'master'
}

<#
.SYNOPSIS
Update the default branch and create a new feat/<name> branch from it.

.PARAMETER name
Feature name - the branch becomes <prefix>/<name>.

.PARAMETER prefix
Branch prefix, default "feat". Use "fix" or "docs" for other kinds of change.

.EXAMPLE
newFeature networkUtils

.EXAMPLE
newFeature brokenSpeedTest -prefix fix
#>
function newFeature {
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$name,
        [Parameter(Mandatory=$false)]
        [string]$prefix = "feat"
    )

    if (git status --porcelain) {
        Write-Host "You have uncommitted changes - commit or stash them first." -ForegroundColor Red
        return
    }

    $default = getDefaultBranch
    Write-Host "Updating $default..." -ForegroundColor Yellow
    git switch $default
    git pull --ff-only
    git switch -c "$prefix/$name"
}

<#
.SYNOPSIS
Push the current branch and open a pull request (uses the GitHub CLI if installed, otherwise the browser).

.EXAMPLE
pr
#>
function pr {
    $branch = git branch --show-current
    $default = getDefaultBranch
    if ($branch -eq $default) {
        Write-Host "You're on $default - create a feature branch first (newFeature <name>)." -ForegroundColor Red
        return
    }

    git push -u origin HEAD
    if ($LASTEXITCODE -ne 0) { return }

    if (Get-Command gh -ErrorAction SilentlyContinue) {
        gh pr create --fill --web
    } else {
        # Turn git@github.com:user/repo.git or https://github.com/user/repo.git into https://github.com/user/repo
        $remote = (git remote get-url origin) -replace '^git@github\.com:', 'https://github.com/' -replace '\.git$', ''
        Start-Process "$remote/compare/$($default)...$($branch)?expand=1"
    }
}

<#
.SYNOPSIS
Delete local branches that have already been merged into the default branch.

.DESCRIPTION
Fetches and prunes first so branches merged on GitHub are detected. Branches merged with
"Squash and merge" or "Rebase and merge" are not detected as merged by git and are left alone.

.EXAMPLE
cleanBranches
#>
function cleanBranches {
    $default = getDefaultBranch
    git fetch --prune --quiet

    $current = git branch --show-current
    $merged = git branch --merged "origin/$default" --format '%(refname:short)' |
        Where-Object { $_ -and $_ -ne $default -and $_ -ne $current }

    if (-not $merged) {
        Write-Host "No merged branches to delete." -ForegroundColor Green
        return
    }

    Write-Host "Branches merged into $($default):" -ForegroundColor Yellow
    $merged | ForEach-Object { Write-Host "  $_" }
    $continue = Read-Host "Delete these $(@($merged).Count) branches? (y/n)"
    if ($continue.ToLower() -eq 'y') {
        $merged | ForEach-Object { git branch -d $_ }
    } else {
        Write-Host "Aborted" -ForegroundColor Red
    }
}

<#
.SYNOPSIS
Short git status (branch plus changed files).

.EXAMPLE
gs
#>
function gs {
    git status -sb
}

<#
.SYNOPSIS
Compact coloured git log graph.

.PARAMETER count
Number of commits to show (default 20).

.EXAMPLE
glog 50
#>
function glog {
    param(
        [Parameter(Mandatory=$false, Position=0)]
        [int]$count = 20
    )
    git log --graph --oneline --decorate -n $count
}

<#
.SYNOPSIS
Undo the last commit but keep its changes staged.

.EXAMPLE
gitUndo
#>
function gitUndo {
    $last = git log -1 --oneline
    if (-not $last) {
        Write-Host "No commits to undo." -ForegroundColor Red
        return
    }
    Write-Host "Undoing: $last" -ForegroundColor Yellow
    $continue = Read-Host "Continue? Changes stay staged (y/n)"
    if ($continue.ToLower() -eq 'y') {
        git reset --soft HEAD~1
        git status -sb
    } else {
        Write-Host "Aborted" -ForegroundColor Red
    }
}
