# Changelog for Sampler.AzureDevOpsTasks

# Changelog

All notable changes to this project will be documented in this file.

The format is based on and uses the types of changes according to [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed

- README.md
  - Fixed wrong file name to azure-pipelines.yml
- Task `Create_PR_From_SourceBranch`
  - PAT is now used also for the remote git commands.

## [0.1.1] - 2022-06-09

### Adding

- Adding a task `Create_PR_From_SourceBranch`.
- Adding meta task `Create_AzureDevOps_Release`.

### Changed

- Update the documentation and the tasks.

### Fixed

- `Create_PR_From_SourceBranch`
  - Fixed branch not honouring default values.
  - Fixed output from task that were not showing correct values.
