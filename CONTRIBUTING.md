# Contributing

Thanks for wanting to help! Function ideas, bug fixes and docs improvements are all welcome.

## Adding a function

1. Pick the file in `Functions/` that matches what the function does, or create a new `Something.ps1` (every `.ps1` in `Functions/` is loaded automatically).
2. Use a `param()` block with typed, named parameters.
3. Add comment-based help above the function so `Get-Help yourFunction` works:

   ```powershell
   <#
   .SYNOPSIS
   One line describing what it does.

   .EXAMPLE
   yourFunction -path C:\Temp
   #>
   function yourFunction {
       param(
           [Parameter(Mandatory=$true)]
           [string]$path
       )
       ...
   }
   ```

4. Don't hardcode personal paths or usernames. Read them from `$profileConfig` (see `profile.config.example.psd1`), and add a new key there if you need one.
5. Add the function to the **Function Reference** in `README.md`.

## Before opening a PR

Run the same checks as CI:

```powershell
Install-Module PSScriptAnalyzer, Pester -Scope CurrentUser
Invoke-ScriptAnalyzer -Path . -Recurse -Settings ./PSScriptAnalyzerSettings.psd1
Invoke-Pester ./tests
```

## Branch naming

`feat/<name>` for new functions, `fix/<name>` for bug fixes, `docs/<name>` for documentation.
