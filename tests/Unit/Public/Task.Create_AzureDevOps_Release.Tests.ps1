BeforeAll {
    $script:moduleName = 'Sampler.AzureDevOpsTasks'

    # If the module is not found, run the build task 'noop'.
    if (-not (Get-Module -Name $script:moduleName -ListAvailable))
    {
        # Redirect all streams to $null, except the error stream (stream 2)
        & "$PSScriptRoot/../../build.ps1" -Tasks 'noop' 3>&1 4>&1 5>&1 6>&1 > $null
    }

    # Re-import the module using force to get any code changes between runs.
    Import-Module -Name $script:moduleName -Force -ErrorAction 'Stop'

    $PSDefaultParameterValues['InModuleScope:ModuleName'] = $script:moduleName
    $PSDefaultParameterValues['Mock:ModuleName'] = $script:moduleName
    $PSDefaultParameterValues['Should:ModuleName'] = $script:moduleName
}

AfterAll {
    $PSDefaultParameterValues.Remove('Mock:ModuleName')
    $PSDefaultParameterValues.Remove('InModuleScope:ModuleName')
    $PSDefaultParameterValues.Remove('Should:ModuleName')

    Remove-Module -Name $script:moduleName
}

Describe 'Task.Create_AzureDevOps_Release' {
    It 'Should have exported the alias correct' {
        $alias = Get-Alias -Name 'Task.Create_AzureDevOps_Release'

        $alias.Name | Should -Be 'Task.Create_AzureDevOps_Release'
        $alias.ReferencedCommand | Should -Be 'Create_AzureDevOps_Release.build.ps1'
        $alias.Definition | Should -Match 'Sampler\.AzureDevOpsTasks[\/|\\]\d+\.\d+\.\d+[\/|\\]tasks[\/|\\]Create_AzureDevOps_Release\.build\.ps1'
    }
}
