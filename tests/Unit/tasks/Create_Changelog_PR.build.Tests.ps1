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
}

AfterAll {
    Remove-Module -Name $script:moduleName
}

Describe 'Create_Changelog_PR' {
    BeforeAll {
        $buildTaskName = 'Create_Changelog_PR'

        $taskAlias = Get-Alias -Name "Task.$buildTaskName"
    }

    Context 'When no release tag is found' {
        BeforeAll {
            Mock -CommandName Sampler.AzureDevOpsTasks\Invoke-AzureDevOpsTasksGit

            Mock -CommandName Sampler.AzureDevOpsTasks\Invoke-AzureDevOpsTasksGit -ParameterFilter {
                $Argument -contains 'rev-parse'
            } -MockWith {
                return '0c23efc'
            }

            Mock -CommandName Get-BuiltModuleVersion -MockWith {
                return '2.0.0'
            }

            $mockTaskParameters = @{
                ProjectPath = Join-Path -Path $TestDrive -ChildPath 'MyModule'
                OutputDirectory = Join-Path -Path $TestDrive -ChildPath 'MyModule/output'
                SourcePath = Join-Path -Path $TestDrive -ChildPath 'MyModule/source'
                ProjectName = 'MyModule'
                RepositoryPAT = '22222'
                GitConfigUserName = 'bot'
                GitConfigUserEmail = 'bot@company.local'
                MainGitBranch = 'main'
                ChangelogPath = 'CHANGELOG.md'
            }
        }

        It 'Should run the build task without throwing' {
            {
                Invoke-Build -Task $buildTaskName -File $taskAlias.Definition @mockTaskParameters
            } | Should -Not -Throw
        }
    }

    Context 'When creating change log PR' {
        BeforeAll {
            Mock -CommandName Sampler.AzureDevOpsTasks\Invoke-AzureDevOpsTasksGit

            Mock -CommandName Sampler.AzureDevOpsTasks\Invoke-AzureDevOpsTasksGit -ParameterFilter {
                $Argument -contains 'rev-parse'
            } -MockWith {
                return '0c23efc'
            }

            Mock -CommandName Sampler.AzureDevOpsTasks\Invoke-AzureDevOpsTasksGit -ParameterFilter {
                $Argument -contains 'tag'
            } -MockWith {
                return 'v2.0.0'
            }

            Mock -CommandName Get-BuiltModuleVersion -MockWith {
                return '2.0.0'
            }

            Mock -CommandName Update-Changelog -RemoveParameterValidation 'Path'

            $mockTaskParameters = @{
                ProjectPath = Join-Path -Path $TestDrive -ChildPath 'MyModule'
                OutputDirectory = Join-Path -Path $TestDrive -ChildPath 'MyModule/output'
                SourcePath = Join-Path -Path $TestDrive -ChildPath 'MyModule/source'
                ProjectName = 'MyModule'
                RepositoryPAT = '22222'
                GitConfigUserName = 'bot'
                GitConfigUserEmail = 'bot@company.local'
                MainGitBranch = 'main'
                ChangelogPath = 'CHANGELOG.md'
            }
        }

        It 'Should run the build task without throwing' {
            {
                Invoke-Build -Task $buildTaskName -File $taskAlias.Definition @mockTaskParameters
            } | Should -Not -Throw
        }
    }
}
