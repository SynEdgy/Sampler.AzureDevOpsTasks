<#
    .SYNOPSIS
        This is a build task that generates conceptual help.

    .PARAMETER ProjectPath
        The root path to the project. Defaults to $BuildRoot.

    .PARAMETER OutputDirectory
        The base directory of all output. Defaults to folder 'output' relative to
        the $BuildRoot.

    .PARAMETER ProjectName
        The project name.

    .PARAMETER SourcePath
        The path to the source folder name.

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
    $ChangelogPath = (property ChangelogPath 'CHANGELOG.md'),

    [Parameter()]
    [string]
    $GitConfigUserEmail = (property GitConfigUserEmail ''),

    [Parameter()]
    [string]
    $GitConfigUserName = (property GitConfigUserName ''),

    [Parameter()]
    $ChangelogFilesToAdd = (property ChangelogFilesToAdd ''),

    [Parameter()]
    $ChangelogUpdateChangelogOnPrerelease = (property ChangelogUpdateChangelogOnPrerelease ''),

    [Parameter()]
    $MainGitBranch = (property MainGitBranch 'main'),

    [Parameter()]
    $RepositoryPAT = (property RepositoryPAT ''),

    [Parameter()]
    $BuildInfo = (property BuildInfo @{ })
)

# Synopsis: Creates a PR to update the changelog with the released version
task Create_ChangeLog_PR {
    . Set-SamplerTaskVariable

    function Invoke-Git
    {
        param
        (
            $Arguments
        )

        # catch is triggered ONLY if $exe can't be found, never for errors reported by $exe itself
        try { & git $Arguments } catch { throw $_ }

        if ($LASTEXITCODE)
        {
            throw "git returned exit code $LASTEXITCODE indicated failure."
        }
    }

    $ChangelogPath = Get-SamplerAbsolutePath -Path $ChangeLogPath -RelativeTo $ProjectPath
    "`Changelog Path                 = '$ChangeLogPath'"

    foreach ($changelogConfigKey in @('UpdateChangelogOnPrerelease', 'FilesToAdd'))
    {
        $changelogConfigVariableName = 'Changelog{0}' -f $changelogConfigKey

        if (-not (Get-Variable -Name $changelogConfigVariableName -ValueOnly -ErrorAction 'SilentlyContinue'))
        {
            # Variable is not set in context, use $BuildInfo.ChangelogConfig.<varName>
            $configurationValue = $BuildInfo.ChangelogConfig.($changelogConfigKey)

            Set-Variable -Name $changelogConfigVariableName -Value $configurationValue

            Write-Build DarkGray "`t...Set property $changelogConfigVariableName to the value $configurationValue."
        }
    }

    foreach ($gitConfigKey in @('UserName', 'UserEmail'))
    {
        $gitConfigVariableName = 'GitConfig{0}' -f $gitConfigKey

        if (-not (Get-Variable -Name $gitConfigVariableName -ValueOnly -ErrorAction 'SilentlyContinue'))
        {
            # Variable is not set in context, use $BuildInfo.ChangelogConfig.<varName>
            $configurationValue = $BuildInfo.GitConfig.($gitConfigKey)

            Set-Variable -Name $gitConfigVariableName -Value $configurationValue

            Write-Build DarkGray "`t...Set property $gitConfigVariableName to the value $configurationValue."
        }
    }

    Write-Build DarkGray "`tSetting git configuration."

    Invoke-Git @('config', 'user.name', $GitConfigUserName)
    Invoke-Git @('config', 'user.email', $GitConfigUserEmail)
    Invoke-Git @('config', 'pull.rebase', 'true')

    Write-Build DarkGray ("`tPulling latest commits and tags from branch '{0}'." -f $MainGitBranch)

    $pullArguments = @()

    if ($RepositoryPAT)
    {
        Write-Build DarkGray "`t`tUsing personal access token to pull commits and tags."

        $patBase64 = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(('{0}:{1}' -f 'PAT', $RepositoryPAT)))

        $pullArguments += @('-c', ('http.extraheader="AUTHORIZATION: basic {0}"' -f $patBase64))
    }

    # Track this branch on the remote 'origin
    $pullArguments += @('-c', 'http.sslbackend="schannel"', 'pull', 'origin', $MainGitBranch, '--tag')

    Invoke-Git $pullArguments

    # Make empty line in output
    ""

    Write-Build DarkGray ("`tGetting HEAD commit for the default branch '{0}." -f $MainGitBranch)

    $defaultBranchHeadCommit = Invoke-Git @('rev-parse', "origin/$MainGitBranch")

    Write-Build DarkGray ("`tGet tags at commit '{0}'." -f $defaultBranchHeadCommit)

    $tagsAtCommit = Invoke-Git @('tag', '-l', '--points-at', $defaultBranchHeadCommit)

    Write-Build DarkGray ("`t`tFound tags: {0}" -f ($tagsAtCommit -join ' | '))

    # Only Update changelog if last commit is a full release
    if ($ChangelogUpdateChangelogOnPrerelease)
    {
        $tagVersion = [System.String] ($tagsAtCommit | Select-Object -First 1)

        Write-Build Green "Updating Changelog for PRE-Release $tagVersion."
    }
    else
    {
        $tagVersion = [System.String] ($tagsAtCommit.Where{ $_ -notMatch 'v.*\-' })

        if ($tagVersion)
        {
            Write-Build Green "Updating the ChangeLog for release $tagVersion."
        }
        else
        {
            Write-Build Yellow ("No release tag found to update the changelog from the available tags: {0}" -f ($tagsAtCommit -join ' | '))
            return
        }
    }

    # Make empty line in output
    ""

    Write-Build DarkGray ('About to create the PR for module version ''{0}''.' -f $ModuleVersion)

    $branchName = "updateChangelogAfter$tagVersion"

    Write-Build DarkGray "`tCreating branch $branchName."

    Invoke-Git @('checkout', '-B', $branchName)

    Write-Build DarkGray "`tUpdating Changelog file."

    Update-Changelog -ReleaseVersion ($tagVersion -replace '^v') -LinkMode 'None' -Path $ChangelogPath -ErrorAction 'SilentlyContinue'

    Invoke-Git @('add', $ChangelogFilesToAdd)

    Invoke-Git @('commit', '-m', "Updating ChangeLog since $tagVersion +semver:skip")

    Write-Build DarkGray ("`tPushing commit on branch '{0}' to the repository." -f $branchName)

    $pushArguments = @()

    if ($RepositoryPAT)
    {
        Write-Build DarkGray "`t`tUsing personal access token to push the tag."

        $patBase64 = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(('{0}:{1}' -f 'PAT', $RepositoryPAT)))

        $pushArguments += @('-c', ('http.extraheader="AUTHORIZATION: basic {0}"' -f $patBase64))
    }

    # Track this branch on the remote 'origin
    $pushArguments += @('-c', 'http.sslbackend="schannel"', 'push', '-u', 'origin', $BranchName)

    Invoke-Git $pushArguments

    # $NewPullRequestParams = @{
    #     AccessToken         = $GitHubToken
    #     OwnerName           = $repoInfo.Owner
    #     RepositoryName      = $repoInfo.Repository
    #     Title               = "Updating ChangeLog since release of $TagVersion"
    #     Head                = $BranchName
    #     Base                = $MainGitBranch
    #     ErrorAction         = 'Stop'
    #     MaintainerCanModify = $true
    # }

    # $Response = New-GitHubPullRequest @NewPullRequestParams

    Write-Build Green ('Opened a PR for the changelog branch ''{0}''.' -f $BranchName)
}
