# Synopsis: Meta task that runs tasks to create a tag if necessary, and pushes updated changelog to a branch, then create a PR based on the pushed branch
task Create_AzureDevOps_Release Create_Release_Git_Tag, Create_Changelog_Branch, Create_Changelog_PR
