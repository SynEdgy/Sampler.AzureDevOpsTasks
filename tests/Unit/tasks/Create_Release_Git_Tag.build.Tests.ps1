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

Describe 'Create_Release_Git_Tag' {
    BeforeAll {
        $buildTaskName = 'Create_Release_Git_Tag'

        $taskAlias = Get-Alias -Name "Task.$buildTaskName"
    }

    Context 'When creating a preview release tag' {
        BeforeAll {
            Mock -CommandName Sampler.AzureDevOpsTasks\Invoke-Git

            Mock -CommandName Sampler.AzureDevOpsTasks\Invoke-Git -ParameterFilter {
                $Argument -contains 'rev-parse'
            } -MockWith {
                return '0c23efc'
            }

            Mock -CommandName Get-BuiltModuleVersion -MockWith {
                return '2.0.0'
            }

            Mock -CommandName Start-Sleep

            $mockTaskParameters = @{
                ProjectPath = Join-Path -Path $TestDrive -ChildPath 'MyModule'
                OutputDirectory = Join-Path -Path $TestDrive -ChildPath 'MyModule/output'
                SourcePath = Join-Path -Path $TestDrive -ChildPath 'MyModule/source'
                ProjectName = 'MyModule'
                RepositoryPAT = '22222'
                GitConfigUserName = 'bot'
                GitConfigUserEmail = 'bot@company.local'
                MainGitBranch = 'main'
            }
        }

        It 'Should run the build task without throwing' {
            {
                Invoke-Build -Task $buildTaskName -File $taskAlias.Definition @mockTaskParameters
            } | Should -Not -Throw
        }
    }

    Context 'When publishing should be skipped' {
        BeforeAll {
            Mock -CommandName Sampler.AzureDevOpsTasks\Invoke-Git

            Mock -CommandName Sampler.AzureDevOpsTasks\Invoke-Git -ParameterFilter {
                $Argument -contains 'rev-parse'
            } -MockWith {
                return '0c23efc'
            }

            Mock -CommandName Get-BuiltModuleVersion -MockWith {
                return '2.0.0'
            }

            Mock -CommandName Start-Sleep

            $mockTaskParameters = @{
                ProjectPath = Join-Path -Path $TestDrive -ChildPath 'MyModule'
                OutputDirectory = Join-Path -Path $TestDrive -ChildPath 'MyModule/output'
                SourcePath = Join-Path -Path $TestDrive -ChildPath 'MyModule/source'
                ProjectName = 'MyModule'
                RepositoryPAT = '22222'
                GitConfigUserName = 'bot'
                GitConfigUserEmail = 'bot@company.local'
                MainGitBranch = 'main'
                SkipPublish = $true
            }
        }

        It 'Should run the build task without throwing' {
            {
                Invoke-Build -Task $buildTaskName -File $taskAlias.Definition @mockTaskParameters
            } | Should -Not -Throw
        }
    }

    Context 'When commit already got a tag' {
        BeforeAll {
            # Stub for git executable
            function script:git
            {
                throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
            }

            Mock -CommandName git -MockWith {
                return 'v2.0.0'
            }
            Mock -CommandName Sampler.AzureDevOpsTasks\Invoke-Git

            Mock -CommandName Sampler.AzureDevOpsTasks\Invoke-Git -ParameterFilter {
                $Argument -contains 'rev-parse'
            } -MockWith {
                return '0c23efc'
            }

            Mock -CommandName Get-BuiltModuleVersion -MockWith {
                return '2.0.0'
            }

            Mock -CommandName Start-Sleep

            $mockTaskParameters = @{
                ProjectPath = Join-Path -Path $TestDrive -ChildPath 'MyModule'
                OutputDirectory = Join-Path -Path $TestDrive -ChildPath 'MyModule/output'
                SourcePath = Join-Path -Path $TestDrive -ChildPath 'MyModule/source'
                ProjectName = 'MyModule'
                RepositoryPAT = '22222'
                GitConfigUserName = 'bot'
                GitConfigUserEmail = 'bot@company.local'
                MainGitBranch = 'main'
            }
        }

        It 'Should run the build task without throwing' {
            {
                Invoke-Build -Task $buildTaskName -File $taskAlias.Definition @mockTaskParameters
            } | Should -Not -Throw
        }
    }
}