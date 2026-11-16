@{
    # Interactive profile functions intentionally use Write-Host and short camelCase names
    ExcludeRules = @(
        'PSAvoidUsingWriteHost',
        'PSUseApprovedVerbs',
        'PSUseSingularNouns',
        'PSAvoidGlobalVars',
        'PSUseShouldProcessForStateChangingFunctions',
        'PSAvoidUsingInvokeExpression',
        'PSUseDeclaredVarsMoreThanAssignments'
    )
}
