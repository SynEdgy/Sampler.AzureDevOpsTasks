<#
    .SYNOPSIS
        This is the alias to the build task Create_PR_From_SourceBranch's
        script file.

    .DESCRIPTION
        This makes available the alias 'Task.Create_PR_From_SourceBranch' that
        is exported in the module manifest so that the build task can be correctly
        imported using for example Invoke-Build.

    .NOTES
        This is using the pattern lined out in the Invoke-Build repository
        https://github.com/nightroman/Invoke-Build/tree/master/Tasks/Import.
#>

Set-Alias -Name 'Task.Create_PR_From_SourceBranch' -Value "$PSScriptRoot/tasks/Create_PR_From_SourceBranch.build.ps1"
