<#
    .SYNOPSIS
        This build task updates the changelog with the release and creates a PR
        to merge.

    .PARAMETER ProjectPath
        The root path to the project. Defaults to $BuildRoot.

    .PARAMETER OutputDirectory
        The base directory of all output. Defaults to folder 'output' relative to
        the $BuildRoot.

    .PARAMETER BuiltModuleSubdirectory
        The parent path of the module to be built.

    .PARAMETER VersionedOutputDirectory
        If the module should be built using a version folder, e.g. ./MyModule/1.0.0.
        Defaults to $true.

    .PARAMETER ProjectName
        The project name.

    .PARAMETER SourcePath
        The path to the source folder.

    .PARAMETER MainGitBranch
        The name of the default branch. Defaults to 'main'. It is used to compare
        and target the PR against.

    .PARAMETER RepositoryPAT
        The personal access token to use to access the Azure DevOps Git repository.
        If left out the task assumes the authentication works without an personal
        access token, e.g Windows integrated security.

    .PARAMETER BuildInfo
        The build info object from ModuleBuilder. Defaults to an empty hashtable.

    .NOTES
        This is a build task that is primarily meant to be run by Invoke-Build but
        wrapped by the Sampler project's build.ps1 (https://github.com/gaelcolas/Sampler).
#>
param
(
    [Parameter()]
    [System.String]
    $ProjectPath = (property ProjectPath $BuildRoot),

    [Parameter()]
    [System.String]
    $OutputDirectory = (property OutputDirectory (Join-Path $BuildRoot 'output')),

    [Parameter()]
    [System.String]
    $BuiltModuleSubdirectory = (property BuiltModuleSubdirectory ''),

    [Parameter()]
    [System.Management.Automation.SwitchParameter]
    $VersionedOutputDirectory = (property VersionedOutputDirectory $true),

    [Parameter()]
    [System.String]
    $ProjectName = (property ProjectName ''),

    [Parameter()]
    [System.String]
    $SourcePath = (property SourcePath ''),

    [Parameter()]
    $MainGitBranch = (property MainGitBranch 'main'),

    [Parameter()]
    $RepositoryPAT = (property RepositoryPAT ''),

    [Parameter()]
    $BuildInfo = (property BuildInfo @{ })
)

# Synopsis: Creates a PR to update the changelog with the released version
task Create_Changelog_PR {
    . Set-SamplerTaskVariable

    Write-Build DarkGray 'About to create a PR based on the changelog branch.'

    $branchName = "updateChangelogAfterv$ModuleVersion"

    Write-Build DarkGray ("`tVerifying that changelog branch exist '{0}'." -f $branchName)

    # $pullArguments = @()

    # if ($RepositoryPAT)
    # {
    #     Write-Build DarkGray "`t`tUsing personal access token to pull commits and tags."

    #     $patBase64 = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(('{0}:{1}' -f 'PAT', $RepositoryPAT)))

    #     $pullArguments += @('-c', ('http.extraheader="AUTHORIZATION: basic {0}"' -f $patBase64))
    # }

    # # Track this branch on the remote 'origin
    # $pullArguments += @('-c', 'http.sslbackend="schannel"', 'pull', 'origin', $MainGitBranch, '--tag')

    # Sampler.AzureDevOpsTasks\Invoke-AzureDevOpsTasksGit -Argument $pullArguments

    # This should not use Invoke-SamplerGit as this should not throw if fails.
    $upstreamChangelogBranch = git ls-remote --heads origin $branchName

    if ($upstreamChangelogBranch)
    {
        Write-Build DarkGray "`tCreating PR based on the changelog branch."

        <#
            TODO:
            brew install azure-cli
            az config set core.collect_telemetry=off

            # https://docs.microsoft.com/en-us/azure/devops/cli/?view=azure-devops
            az extension add --name azure-devops
            $env:AZURE_DEVOPS_EXT_PAT = 'xxxxxxxxxx' # https://docs.microsoft.com/en-us/azure/devops/cli/log-in-via-pat?view=azure-devops&tabs=windows
            az devops configure --defaults organization=https://dev.azure.com/contoso project=ContosoWebApp core.collect_telemetry=off
            # https://docs.microsoft.com/en-us/azure/devops/repos/git/pull-requests?view=azure-devops&tabs=azure-devops-cli#create-a-new-pull-request
            az repos pr create --detect true # maybe this works instead of above defaults?
            az repos pr create --repository-name $ProjectName --source-branch $branchName --target-branch $MainGitBranch --title "Updating Changelog since release of v$ModuleVersion" --description <description> --labels <label1> <label2> <label3>
        #>

        Write-Build Green ('Opened a PR for the changelog branch ''{0}''.' -f $branchName)
    }
    else
    {
        Write-Build Yellow 'No changelog branch was found. Nothing to do, exiting.'
    }
}
