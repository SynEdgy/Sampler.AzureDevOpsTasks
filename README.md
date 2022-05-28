# Sampler.AzureDevOpsTasks

This module contains Sampler project build tasks for Azure DevOps Services and Azure DevOps Server.

[![Build Status](https://dev.azure.com/SynEdgy/Sampler.AzureDevOpsTasks/_apis/build/status/SynEdgy.Sampler.AzureDevOpsTasks?branchName=main)](https://dev.azure.com/SynEdgy/Sampler.AzureDevOpsTasks/_build/latest?definitionId=19&branchName=main)
![Azure DevOps coverage (branch)](https://img.shields.io/azure-devops/coverage/SynEdgy/Sampler.AzureDevOpsTasks/19/main)
[![codecov](https://codecov.io/gh/SynEdgy/Sampler.AzureDevOpsTasks/branch/main/graph/badge.svg)](https://codecov.io/gh/SynEdgy/Sampler.AzureDevOpsTasks)
[![Azure DevOps tests](https://img.shields.io/azure-devops/tests/SynEdgy/Sampler.AzureDevOpsTasks/19/main)](https://SynEdgy.visualstudio.com/Sampler.AzureDevOpsTasks/_test/analytics?definitionId=19&contextType=build)
[![PowerShell Gallery (with prereleases)](https://img.shields.io/powershellgallery/vpre/Sampler.AzureDevOpsTasks?label=Sampler.AzureDevOpsTasks%20Preview)](https://www.powershellgallery.com/packages/Sampler.AzureDevOpsTasks/)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/v/Sampler.AzureDevOpsTasks?label=Sampler.AzureDevOpsTasks)](https://www.powershellgallery.com/packages/Sampler.AzureDevOpsTasks/)

## Code of Conduct

This project has adopted this [Code of Conduct](CODE_OF_CONDUCT.md).

## Releases

For each merge to the branch `main` a preview release will be
deployed to [PowerShell Gallery](https://www.powershellgallery.com/).
Periodically a release version tag will be pushed which will deploy a
full release to [PowerShell Gallery](https://www.powershellgallery.com/).

## Contributing

Please check out common DSC Community [contributing guidelines](https://dsccommunity.org/guidelines/contributing).

## Change log

A full list of changes in each version can be found in the [change log](CHANGELOG.md).

## Cmdlets
<!-- markdownlint-disable MD036 - Emphasis used instead of a heading -->

Refer to the comment-based help for more information about these helper
functions.

### `Invoke-Git`

This command executes git with the provided arguments and throws an error
if the call failed.

#### Syntax

<!-- markdownlint-disable MD013 - Line length -->
```plaintext
Invoke-Git [-Argument] <string[]> [<CommonParameters>]
```
<!-- markdownlint-enable MD013 - Line length -->

#### Outputs

[System.String]

#### Example

```powershell
Invoke-Git -Argument @('config', 'user.name', 'MyName')
```

Calls git to set user name in the git config.

## Tasks

These are `Invoke-Build` tasks. The build tasks are primarily meant to be
run by the project [Sampler's](https://github.com/gaelcolas/Sampler)
`build.ps1` which wraps `Invoke-Build` and has the configuration file
(`build.yaml`) to control its behavior.

To make the tasks available for the cmdlet `Invoke-Build` in a repository
that is based on the [Sampler](https://github.com/gaelcolas/Sampler) project,
add this module to the file `RequiredModules.psd1` and then in the file
`build.yaml` add the following:

```yaml
ModuleBuildTasks:
  Sampler.AzureDevOpsTasks:
    - 'Task.*'
```

### `Create_Changelog_PR`

This build task creates pushes a branch with the changelog updated with
the current release version, then a pull request is created based on the
pushed branch.

>**NOTE: Currently creating a PR from the pushed branch does not work.**

This can be use in conjunction with the `Create_Release_Git_Tag` task
that creates the release tag.

This is an example of how to use the task in the _azure-pipelines.yaml_ file:

```yaml
- task: PowerShell@2
  name: sendChangelogPR
  displayName: 'Send Changelog PR'
  inputs:
    filePath: './build.ps1'
    arguments: '-tasks Create_ChangeLog_PR'
    pwsh: true
  env:
    MainGitBranch: 'main'
    RepositoryPAT: $(REPOSITORYPAT)
```

#### Task parameters

Some task parameters are vital for the resource to work. See comment based
help for the description for each available parameter. Below is the most
important.

#### Task configuration

The build configuration (_build.yaml_) can be used to control the behavior
of the build task.

```yaml
####################################################
#             Changelog Configuration              #
####################################################
ChangelogConfig:
  FilesToAdd:
    - 'CHANGELOG.md'
  UpdateChangelogOnPrerelease: false

####################################################
#                Git Configuration                 #
####################################################
GitConfig:
  UserName: bot
  UserEmail: bot@company.local
```

#### Section ChangelogConfig

##### Property FilesToAdd

This specifies one or more files to add to the commit when creating the
PR branch. If left out it will default to the one file _CHANGELOG.md_.

##### Property UpdateChangelogOnPrerelease

- `true`: Always create a changelog PR, even on preview releases.
- `false`: Only create a changelog PR for full releases. Default.
