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

## Commands
<!-- markdownlint-disable MD036 - Emphasis used instead of a heading -->

Refer to the comment-based help for more information about these helper
functions.

### `Invoke-AzureDevOpsTasksGit`

This command executes git with the provided arguments and throws an error
if the call failed.

#### Syntax

<!-- markdownlint-disable MD013 - Line length -->
```plaintext
Invoke-AzureDevOpsTasksGit [-Argument] <string[]> [<CommonParameters>]
```
<!-- markdownlint-enable MD013 - Line length -->

#### Outputs

[System.String]

#### Example

```powershell
Invoke-AzureDevOpsTasksGit -Argument @('config', 'user.name', 'MyName')
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

### `Create_AzureDevOps_Release`

Meta task that runs tasks to create a tag if necessary, and pushes updated
changelog to a branch, then create a PR based on the pushed branch.

The following tasks are run (in order):

- `Create_Release_Git_Tag` (from module Sampler)
- `Create_Changelog_Branch` (from module Sampler)
- `Create_PR_From_SourceBranch`

Please see each individual task for documentation.

This is an example of how to use the task in the _build.yaml_ file:

```yaml
- task: PowerShell@2
  name: createAzureDevOpsRelease
  displayName: 'Create Azure DevOps Release'
  inputs:
    filePath: './build.ps1'
    arguments: '-tasks Create_AzureDevOps_Release'
    pwsh: true
  env:
    MainGitBranch: 'main'
    BasicAuthPAT: $(BASICAUTHPAT)
```

This is an example of how to use the task in the _build.yaml_ file:

```yaml
  publish:
    - Create_AzureDevOps_Release
```

Make sure to pass required environment variables when the task `publish`
runs.

### `Create_PR_From_SourceBranch`

This build task creates a pull request based on an already pushed branch.

>This task requires that (the Sampler) task `Create_Changelog_Branch` have
>been ran, or by any other means that created a branch with the correct name.

This is an example of how to use the task in the _azure-pipelines.yml_ file:

```yaml
- task: PowerShell@2
  name: sendChangelogPR
  displayName: 'Send Changelog PR'
  inputs:
    filePath: './build.ps1'
    arguments: '-tasks Create_PR_From_SourceBranch'
    pwsh: true
  env:
    MainGitBranch: 'main'
    BasicAuthPAT: $(BASICAUTHPAT)
```

This is an example of how to use the task in the _build.yaml_ file:

```yaml
  publish:
    - Create_PR_From_SourceBranch
```

Make sure to pass required environment variables when the task `publish`
runs.

#### Task parameters

Some task parameters are vital for the resource to work. See comment based
help for the description for each available parameter. Below is the most
important.

#### Task configuration

The build configuration (_build.yaml_) can be used to control the behavior
of the build task.

```yaml
####################################################
#            Pull Request Configuration            #
####################################################
PullRequestConfig:
  BranchName: 'updateChangelogAfterv{0}'
  Title: 'Updating Changelog since release of v{0} +semver:skip'
  Description: 'Updating Changelog since release of v{0} +semver:skip'
  Instance: 'azdoserver.company.local'
  Collection: 'MyCollection'
  Project: 'MyProject'
  RepositoryID: 'MyRepositoryName'
  Debug: false
```

#### Section PullRequestConfig

See the [Azure DevOps Server Rest API documentation](https://docs.microsoft.com/en-us/rest/api/azure/devops/git/pull-requests/create?view=azure-devops-server-rest-6.0)
for more information what values to use for each property.

If the property `RepositoryID` is not set, the task will default to the
project name found by Sampler pipeline, which is normally the module
name. Please note that the property `Project` above and the project name
are two different properties.

The property `Debug` when set to `true` will output the response from the
Rest API call.

The property `BranchName` can be used to override the default branch name
that is used as the source branch for the pull request. The branch name
can contain a `{0}` placeholder which will be replaced with the module
version.

The property `Title` and `Description` can be used to override the default
title and description that is used for the pull request. Both values can
contain a `{0}` placeholder which will be replaced with the module version.
