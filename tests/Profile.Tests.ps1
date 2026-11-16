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
