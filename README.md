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

## Usage

Although this module is best used as part of the Sampler template pipeline
automation, you can also use this in a standalone or custom way.

You can run the tests against the source of your project or against a built module.  
The format expected for your project follows [the Sampler](https://github.com/gaelcolas/Sampler)
template (basically the source code in a source/src/ModuleName folder, and
a built version in the output folder).

Install the module from the PowerShell Gallery:

```PowerShell
Install-Module Sampler.AzureDevOpsTasks
```

Execute against a Built module:

```PowerShell
Invoke-DscResourceTest -Module UpdateServicesDsc
```

## Dependencies

This module depends on:

- **Pester**: This is a collection of generic Pester tests to run against your built
module or source code.
- **PSScriptAnalyzer**: Some tests are just validating you comply with some of the
guidances set in PSSA rules and with custom rules.
- **DscResource.AnalyzerRules**: This is the custom rules we've created to enforce
a standard across the DscResource module we look after as a community.
- **xDscResourceDesigner**: Because it offers MOF and DSC Resource testing capabilities.

### Contributing

The [Contributing guidelines can be found here](CONTRIBUTING.md).

This project has continuous testing running on Windows, MacOS, Linux, with both
Windows PowerShell 5.1 and the PowerShell version available on the Azure DevOps
agents.

Quick Start:

```PowerShell
PS C:\src\> git clone git@github.com:SynEdgy/Sampler.AzureDevOpsTasks.git
PS C:\src\> cd Sampler.AzureDevOpsTasks
PS C:\src\Sampler.AzureDevOpsTasks> build.ps1 -ResolveDependency
# this will first bootstrap the environment by downloading dependencies required
# then run the '.' task workflow as defined in build.yml
```

## Cmdlets
<!-- markdownlint-disable MD036 - Emphasis used instead of a heading -->

Refer to the comment-based help for more information about these helper
functions.

### `Invoke-Git`

Clear the DSC LCM by performing the following functions:

#### Syntax

<!-- markdownlint-disable MD013 - Line length -->
```plaintext
Clear-DscLcmConfiguration [<CommonParameters>]
```
<!-- markdownlint-enable MD013 - Line length -->

#### Outputs

None.

#### Example

```powershell
Clear-DscLcmConfiguration
```

This command will Stop the DSC LCM and clear out any DSC configurations.

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

### `Invoke_HQRM_Tests`

This build task runs the High Quality Resource Module (HQRM) tests located
in the folder `Tests/QA` in the module _Sampler.AzureDevOpsTasks_'s root. This build
task is normally not used on its own. It is meant to run through the meta task
[`Invoke_HQRM_Tests_Stop_On_Fail`](#invoke-hqrm-tests-stop-on-fail).

Below is an example how the build task can be used when a repository is
based on the [Sampler](https://github.com/gaelcolas/Sampler) project.

```yaml
BuildWorkflow:
  '.':
    - build

  hqrmtest:
    - Invoke_HQRM_Tests
```

The build configuration (build.yaml) can be used to control the behavior
of the build task. Everything under the key `DscTest:` controls the behavior.
There are two sections `Pester` and `Script`.

#### Section Pester

The section Pester control the behavior of `Invoke-Pester` that is run
through the build task. There are two different ways of configuring this,
they can be combined but it is limited to the parameter sets of `Invoke-Pester`,
see the command syntax in the [`Invoke-Pester` documentation](https://pester.dev/docs/commands/Invoke-Pester).

##### Passing parameters to Pester

Any parameter that `Invoke-Pester` takes is valid to use as key in the
build configuration. The exception is `Container`, it is handled by the
build task to pass parameters to the scripts correctly (see [Section Script](#section-script)).
Also the parameter `Path` can only point to test files that do not need
any script parameters passed to them to run.

>**NOTE:** A key that does not have a value will be ignored.

```yaml
DscTest:
  Pester:
    Path:
    ExcludePath:
    TagFilter:
    FullNameFilter:
    ExcludeTagFilter:
      - Common Tests - New Error-Level Script Analyzer Rules
    Output: Detailed
```

Important to note that if the key `Configuration` is present it limits
what other parameters that can be passed to `Invoke-Pester` due to the
parameter set that is then used. But the key `Configuration` gives more
control over the behavior of `Invoke-Pester`. For more information what 
can be configured see the [sections of the `[PesterConfiguration]` object](https://pester.dev/docs/commands/Invoke-Pester#-configuration).

Under the key `Configuration` any section name in the `[PesterConfiguration]`
object is valid to use as key. Any new sections or properties that will be
added in future version of Pester will also be valid (as long as they follow
the same pattern).

```plaintext
PS > [PesterConfiguration]::Default
Run          : Run configuration.
Filter       : Filter configuration
CodeCoverage : CodeCoverage configuration.
TestResult   : TestResult configuration.
Should       : Should configuration.
Debug        : Debug configuration for Pester. ⚠ Use at your own risk!
Output       : Output configuration
```

This shows how to use the advanced configuration option to exclude tags
and change the output verbosity. The keys `Filter:` and `Output:` are the
section names from the list above, and the keys `ExcludeTag` and `Verbosity`
are properties in the respective section in the `[PesterConfiguration]`
object.

>**NOTE:** A key that does not have a value will be ignored.

```yaml
DscTest:
  Pester:
    Configuration:
      Filter:
        Tag:
        ExcludeTag:
          - Common Tests - New Error-Level Script Analyzer Rules
      Output:
        Verbosity: Detailed
```

#### Section Script

##### Passing parameters to test scripts

The key `Script:` is used to define values to pass to parameters in the
test scripts. Each key defined under the key `Script:` is a parameter that
can be used in one or more test script.

See the section [Tests](#tests) for the parameters that can be defined here
to control the behavior of the tests.

>**NOTE:** The test scripts only used the parameters that is required and
>ignore any other that is defined. If there are tests added that need a
>different parameter name, that name can be defined under the key `Script:`
>and will be passed to the test that require it without any change to the
>build task.

This defines three parameters `ExcludeSourceFile`, `ExcludeModuleFile`,
and `MainGitBranch` and their corresponding values.

```yaml
DscTest:
  Script:
    ExcludeSourceFile:
      - output
      - source/DSCResources/DSC_ObsoleteResource1
      - DSC_ObsoleteResource2
    ExcludeModuleFile:
      - Modules/DscResource.Common
    MainGitBranch: main
```

### `Fail_Build_If_HQRM_Tests_Failed`

This build task evaluates that there was no failed tests when the task
`Invoke_HQRM_Tests` ran. This build task is normally not used on its own.
It is meant to run through the meta task [`Invoke_HQRM_Tests_Stop_On_Fail`](#invoke_hqrm_tests_stop_on_fail).

Below is an example how the build task can be used when a repository is
based on the [Sampler](https://github.com/gaelcolas/Sampler) project.

```yaml
BuildWorkflow:
  '.':
    - build

  hqrmtest:
    - Invoke_HQRM_Tests
    - Fail_Build_If_HQRM_Tests_Failed
```

### `Invoke_HQRM_Tests_Stop_On_Fail`

This is a meta task meant to be used in the build configuration to run
tests in the correct order to fail the test pipeline if there are any
failed test.

The order this meta task is running tasks:

- Invoke_HQRM_Tests
- Fail_Build_If_HQRM_Tests_Failed

Below is an example how the build task can be used when a repository is
based on the [Sampler](https://github.com/gaelcolas/Sampler) project.

```yaml
BuildWorkflow:
  '.':
    - build

  hqrmtest:
    - Invoke_HQRM_Tests_Stop_On_Fail
```
