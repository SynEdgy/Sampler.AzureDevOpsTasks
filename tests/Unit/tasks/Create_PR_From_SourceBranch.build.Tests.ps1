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

Describe 'Create_PR_From_SourceBranch' {
    BeforeAll {
        function script:git
        {
            param
            (
                $Argument
            )

            throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
        }

        $buildTaskName = 'Create_PR_From_SourceBranch'

        $taskAlias = Get-Alias -Name "Task.$buildTaskName"
    }

    AfterAll {
        Remove-Item 'function:git'
    }

    Context 'When no branch is found' {
        BeforeAll {
            Mock -CommandName 'git' -ParameterFilter {
                $Argument -contains 'ls-remote'
            }

            Mock -CommandName Get-BuiltModuleVersion -MockWith {
                return '2.0.0'
            }

            $mockTaskParameters = @{
                ProjectPath = Join-Path -Path $TestDrive -ChildPath 'MyModule'
                OutputDirectory = Join-Path -Path $TestDrive -ChildPath 'MyModule/output'
                SourcePath = Join-Path -Path $TestDrive -ChildPath 'MyModule/source'
                ProjectName = 'MyModule'
                BasicAuthPAT = '22222'
                MainGitBranch = 'main'
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
            Mock -CommandName 'git' -ParameterFilter {
                $Argument -contains 'ls-remote'
            } -MockWith {
                return 'refs/heads/myBranchName'
            }

            Mock -CommandName Get-BuiltModuleVersion -MockWith {
                return '2.0.0'
            }

            Mock -CommandName Invoke-RestMethod

            $mockTaskParameters = @{
                ProjectPath = Join-Path -Path $TestDrive -ChildPath 'MyModule'
                OutputDirectory = Join-Path -Path $TestDrive -ChildPath 'MyModule/output'
                SourcePath = Join-Path -Path $TestDrive -ChildPath 'MyModule/source'
                ProjectName = 'MyModule'
                BasicAuthPAT = '22222'
                MainGitBranch = 'main'
                PullRequestConfigInstance = 'instance'
                PullRequestConfigCollection = 'collection'
                PullRequestConfigProject = 'project'
                PullRequestConfigRepositoryID = 'repositoryName'
            }
        }

        It 'Should run the build task without throwing' {
            {
                Invoke-Build -Task $buildTaskName -File $taskAlias.Definition @mockTaskParameters
            } | Should -Not -Throw

            Should -Invoke -CommandName 'Invoke-RestMethod'
        }
    }
}
