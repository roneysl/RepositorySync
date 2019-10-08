param (
    
    [string]$SourceURL,
    [string]$SourcePAT,
    [string]$TargetURL,
    [string]$TargetPAT,
    [string]$TempGitPath = "D:\TempGit",
    [string]$SourceRepository,
    [string]$TargetRepository
    )

$ErrorActionPreference = 'Stop'

if ($SourceURL -eq "") {
    Write-Error "Source URL is Required"
    exit 999
}
if ($SourcePAT -eq "") {
    Write-Error "Source Personal Access Token is Required"
    exit 999
}
if ($TargetURL -eq "") {
    Write-Error "Target URL is Required"
    exit 999
}
if ($TargetPAT -eq "") {
    Write-Error "Target Personal Access Token is Required"
    exit 999
}
if ($TempGitPath -eq "") {
    Write-Error "Temporary path for GIT repository is Required"
    exit 999
}
if ($SourceRepository -eq "") {
    Write-Error "Source Repository is Required"
    exit 999
}
if ($TargetRepository -eq "") {
    Write-Error "Target Repository is Required"
    exit 999
}

$sourceRepoPath = Join-Path $TempGitPath ($SourceRepository + "_source")
if (-not (Test-Path $sourceRepoPath)) {
    New-Item $sourceRepoPath -ItemType Directory
} else {
   Get-ChildItem -Path $sourceRepoPath -Recurse | Remove-Item -force -recurse
}

$programDirectory = $PWD


[string]$sourceRepoUrl = (new-object -TypeName 'System.Uri' -ArgumentList ([System.Uri] $SourceURL),$SourceRepository).AbsoluteUri
$sourceRepoUrl = $sourceRepoUrl.Replace("https://", "https://" + $SourcePAT + "@")

[string]$targetRepoUrl = (new-object -TypeName 'System.Uri' -ArgumentList ([System.Uri] $TargetURL),$TargetRepository).AbsoluteUri
$targetRepoUrl = $targetRepoUrl.Replace("https://", "https://" + $TargetPAT + "@")

Set-Location -Path $sourceRepoPath -PassThru
git clone -q $sourceRepoUrl

Write-Host "Cloned"
$workingDirectory = Join-Path $sourceRepoPath $SourceRepository

cd $workingDirectory

git checkout master
Write-Host "Checkout"

git pull origin
Write-Host "pull origin"

git remote add target $targetRepoUrl
Write-Host "Added remote"

git push target --tags -q -u -f
git push target --all -q -u -f
Write-Host "push target"

Set-Location $programDirectory -PassThru