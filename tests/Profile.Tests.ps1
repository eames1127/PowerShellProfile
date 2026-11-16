# Pester 5 tests - run with: Invoke-Pester ./tests
BeforeDiscovery {
    $script:functionFiles = Get-ChildItem -Path (Join-Path $PSScriptRoot '..\Functions') -Filter '*.ps1' -Recurse |
        ForEach-Object { @{ Name = $_.Name; Path = $_.FullName } }
}

Describe 'Function file <Name>' -ForEach $functionFiles {
    It 'parses without syntax errors' {
        $errors = $null
        [System.Management.Automation.Language.Parser]::ParseFile($Path, [ref]$null, [ref]$errors) | Out-Null
        $errors | Should -BeNullOrEmpty
    }

    It 'dot-sources without errors' {
        $profileConfig = @{ CodingPath = $TestDrive; GitHubUser = 'test' }
        { . $Path } | Should -Not -Throw
    }
}

Describe 'Main profile' {
    It 'parses without syntax errors' {
        $errors = $null
        $path = Join-Path $PSScriptRoot '..\Microsoft.PowerShell_profile.ps1'
        [System.Management.Automation.Language.Parser]::ParseFile($path, [ref]$null, [ref]$errors) | Out-Null
        $errors | Should -BeNullOrEmpty
    }

    It 'example config is valid PowerShell data' {
        $config = Import-PowerShellDataFile -Path (Join-Path $PSScriptRoot '..\profile.config.example.psd1')
        $config.Keys | Should -Contain 'CodingPath'
    }
}

Describe 'updateAll' {
    BeforeAll {
        . (Join-Path $PSScriptRoot '..\Functions\SystemUtils.ps1')
        # Skip winget so the test never upgrades real packages
        Mock Get-Command { $null } -ParameterFilter { $Name -eq 'winget' }
        Mock Write-Warning { }
        Mock Write-Host { }
        Mock Get-InstalledModule { [pscustomobject]@{ Name = 'GoodModule' }, [pscustomobject]@{ Name = 'BrokenModule' } }
        Mock Update-Module { throw 'simulated failure' } -ParameterFilter { $Name -eq 'BrokenModule' }
        Mock Update-Module { }
    }

    It 'names the module that failed to update' {
        updateAll
        Should -Invoke Write-Host -ParameterFilter { $Object -eq '  BrokenModule failed: simulated failure' } -Exactly 1
        Should -Invoke Write-Host -ParameterFilter { $Object -eq '  GoodModule checked' } -Exactly 1
    }
}

Describe 'Function help' {
    BeforeDiscovery {
        $script:helpCases = foreach ($file in Get-ChildItem -Path (Join-Path $PSScriptRoot '..\Functions') -Filter '*.ps1' -Recurse) {
            $ast = [System.Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref]$null, [ref]$null)
            $ast.FindAll({ $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $false) |
                ForEach-Object { @{ Name = $_.Name; File = $file.Name; Ast = $_ } }
        }
    }

    It '<Name> in <File> has a .SYNOPSIS' -ForEach $helpCases {
        $help = $Ast.GetHelpContent()
        $help | Should -Not -BeNullOrEmpty
        $help.Synopsis | Should -Not -BeNullOrEmpty
    }
}
