<#
    .SYNOPSIS
        This is the alias to the build task Create_Release_Git_Tag's
        script file.

    .DESCRIPTION
        This makes available the alias 'Task.Create_Release_Git_Tag' that
        is exported in the module manifest so that the build task can be correctly
        imported using for example Invoke-Build.

    .NOTES
        This is using the pattern lined out in the Invoke-Build repository
        https://github.com/nightroman/Invoke-Build/tree/master/Tasks/Import.
#>

Set-Alias -Name 'Task.Create_Release_Git_Tag' -Value "$PSScriptRoot/tasks/Create_Release_Git_Tag.build.ps1"
