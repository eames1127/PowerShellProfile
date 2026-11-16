# PowerShellProfile

[![CI](https://github.com/eames1127/PowerShellProfile/actions/workflows/ci.yml/badge.svg)](https://github.com/eames1127/PowerShellProfile/actions/workflows/ci.yml)
[![Licence: MIT](https://img.shields.io/badge/Licence-MIT-blue.svg)](LICENSE)

My PowerShell profile and the functions I've built up over time for day-to-day dev work and Windows admin jobs. It sets up an oh-my-posh prompt and then loads everything in the `Functions` folder. Feel free to use it, pinch bits of it or suggest additions.

It's written for Windows (Windows PowerShell 5.1 or PowerShell 7).

## Installing

The quickest way is the install script. It backs up your existing profile before copying anything over:

```powershell
irm https://raw.githubusercontent.com/eames1127/PowerShellProfile/master/install.ps1 | iex
```

Or clone the repo and run it from there. `-InstallTerminal` also installs posh-git, oh-my-posh and the Meslo font:

```powershell
git clone https://github.com/eames1127/PowerShellProfile.git
cd PowerShellProfile
.\install.ps1 -InstallTerminal
```

Once it's installed, open `profile.config.psd1` (it sits next to your `$PROFILE`) and set your own paths, then open a new terminal.

## Settings

Your personal settings live in `profile.config.psd1`, so you don't need to edit any of the scripts. Neither `Update-Profile` nor the installer will overwrite it.

```powershell
@{
    CodingPath   = 'D:\Dev'          # where your repos live
    GitHubUser   = 'your-username'   # used by goToGitHubRepo
    Theme        = 'jandedobbeleer'  # any oh-my-posh theme (see Get-PoshThemes)
    ClearOnStart = $false            # clear the screen when the profile loads
    ShowLoadTime = $true             # show the function count and load time
}
```

To add your own functions, drop a `.ps1` file into the `Functions` folder and it'll be loaded automatically. Give each function a `.SYNOPSIS` help block and it'll show up in `profileHelp` too.

## What's in it

If you forget what's available, run `profileHelp` (or `profileHelp git` to filter it). `Get-Help <function> -Examples` shows how to use each one.

### Getting around (TimeSavers.ps1)

- `goToCoding` - jump to your coding folder and open it in VS Code
- `goToRepo <repo>` - jump to a repo and show `git status` (repo names tab-complete)
- `goToGitHubRepo [user] <repo>` - open a repo on GitHub, using `GitHubUser` if you leave the user out
- `initRepo <url>` - clone a repo into your coding folder
- `psProfile` - open the profile folder in VS Code
- `copyPSProfileToCode` - copy your live profile back into this repo
- `Update-Profile` - copy the profile from this repo into your live profile (`copyPSProfileFromCode` still works too)
- `getChangesInBranch -gitLoc <path> -branchName <branch>` - list the merges on your branch since another branch. Add `-filter "*Jira*"` to narrow it down and `-update` to pull first
- `..` and `...` - go up one or two folders
- `mkcd <path>` - make a folder and move into it
- `touch <file>` - create a file, or update its timestamp

### Git (GitUtils.ps1)

These follow the way I work on this repo: a `feat/` branch, a PR, then merge.

- `newFeature <name>` - pull the default branch and create `feat/<name>` (use `-prefix fix` for a fix branch)
- `pr` - push the branch and open a pull request
- `cleanBranches` - delete local branches that have already been merged
- `gs` - short status
- `glog [count]` - one-line log graph
- `gitUndo` - undo the last commit but keep the changes staged
- `getDefaultBranch` - print the repo's default branch name

### Files (FileUtils.ps1)

- `compressAndCopy -fileName <name> -loc <source> -dest <folder>` - zip a folder up with today's date in the name
- `validateFiles -path <folder> -fileList @("a.txt", "b.txt")` - check a set of files exists, which is handy after a deployment
- `copyByExtension -copyTo <folder> -extFilter @("*.ps1")` - copy files of certain types out of a folder tree
- `findFile <pattern>` - find files by name
- `dirSize [path]` - see which folders are taking up the space

### System (SystemUtils.ps1)

- `checkEventLogs -servers @("server1") -days 10` - pull errors out of the event logs and print them to PDF
- `manageServices -serviceID 1 -machine <server>` - restart services locally or on another machine
- `sysInfo` - OS, uptime, CPU, memory and disk space
- `updateAll` - run `winget upgrade --all` and update your PowerShell modules
- `isAdmin` - check whether you're running elevated
- `sudoLast` - re-run your last command as Administrator

### Network (NetworkUtils.ps1)

- `myIP` - private IP, public IP and gateway
- `speedTest` - rough download speed test
- `checkPort <port>` / `killPort <port>` - see what's using a port, or stop it
- `netDiag <host>` - ping, DNS lookup and traceroute in one go
- `netAdapters` - adapters that are up and their link speed
- `pingTest <host>` - returns true or false
- `wifiList [-connectTo <name>]` - list saved WiFi networks or connect to one

### Everything else

- `ll` - list files, including hidden ones
- `installTerminalconfig` - install posh-git, oh-my-posh and the Meslo font
- `PSReadLine.ps1` sets up suggestions from your history, Up/Down history search on what you've typed so far, and a Tab completion menu

## If something isn't working

**Functions don't load.** Make sure the `Functions` folder is next to your profile, and that your execution policy allows local scripts:
`Set-ExecutionPolicy RemoteSigned -Scope CurrentUser`

**The prompt looks broken or has missing icons.** Install oh-my-posh (`winget install JanDeDobbeleer.OhMyPosh`) and the font (`oh-my-posh font install meslo`). Then set Windows Terminal's font to "MesloLGM Nerd Font".

**No history suggestions.** Windows PowerShell 5.1 ships an old version of PSReadLine, so update it with `Install-Module PSReadLine -Force -Scope CurrentUser`. `F2` switches between inline and list view.

**Some network or service functions fail.** A few of them need an Administrator window.

## Contributing

Ideas and PRs are welcome. Have a look at [CONTRIBUTING.md](CONTRIBUTING.md), or open a function request issue.

## Licence

[MIT](LICENSE)
