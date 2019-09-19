# RepositorySync
Powershell script to synchronize two master branches from different repositories

## Usage

1. Create a personal access token in the source Azure DevOps server
   - Make sure to save this PAT to a secure location
2. Create a personal access token in the target Azure DevOps server
   - Again, this needs to be secured
3. To use the command, use this syntax:
   - `CloneRepo.ps1 -SourceURL "https://example.visualstudio.com/xxx/_git/" -SourcePAT "PersonalAccessToken" -TargetURL "https://example.visualstudio.com/xxx/_git" -TargetPAT "PersonalAccessToken" -SourceRepository "Source" - TargetRepository "Target"`
