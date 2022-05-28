<#
    .SYNOPSIS
        This is the alias to the build task Create_Changelog_PR's
        script file.

    .DESCRIPTION
        This makes available the alias 'Task.Create_Changelog_PR' that
        is exported in the module manifest so that the build task can be correctly
        imported using for example Invoke-Build.

    .NOTES
        This is using the pattern lined out in the Invoke-Build repository
        https://github.com/nightroman/Invoke-Build/tree/master/Tasks/Import.
#>

Set-Alias -Name 'Task.Create_Changelog_PR' -Value "$PSScriptRoot/tasks/Create_Changelog_PR.build.ps1"
