param (
    
    [string]$SourceURL,
    [string]$SourcePAT,
    [string]$TargetURL,
    [string]$TargetPAT,
    [string]$TempGitPath = "D:\TempGit",
    [string]$Repository
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
if ($Repository -eq "") {
    Write-Error "Repository is Required"
    exit 999
}


#https://innovasystems.visualstudio.com/DefaultCollection/DRRS-N/_git/NavyReadiness-MenuService

$sourceRepoPath = Join-Path $TempGitPath ($Repository + "_source")
if (-not (Test-Path $sourceRepoPath)) {
    New-Item $sourceRepoPath -ItemType Directory
} else {
   Get-ChildItem -Path $sourceRepoPath -Recurse | Remove-Item -force -recurse
}
$targetRepoPath = Join-Path $TempGitPath "ShawnMenuService_target"
if (-not (Test-Path $targetRepoPath)) {
    New-Item $targetRepoPath -ItemType Directory
} else {
   Get-ChildItem -Path $targetRepoPath -Recurse | Remove-Item -force -recurse
}


$programDirectory = $PWD

$drrsnUrlGitPart = "DRRS-N/_git/" + $Repository
[string]$sourceRepoUrl = (new-object -TypeName 'System.Uri' -ArgumentList ([System.Uri] $SourceURL),$drrsnUrlGitPart).AbsoluteUri
$sourceRepoUrl = $sourceRepoUrl.Replace("https://", "https://" + $SourcePAT + "@")

$targetUrlGitPart = "DRRS-N/_git/" + "ShawnMenuService"
[string]$targetRepoUrl = (new-object -TypeName 'System.Uri' -ArgumentList ([System.Uri] $TargetURL),$targetUrlGitPart).AbsoluteUri
$targetRepoUrl = $targetRepoUrl.Replace("https://", "https://" + $TargetPAT + "@")

Set-Location -Path $sourceRepoPath -PassThru
git clone -q $sourceRepoUrl

Set-Location -Path $targetRepoPath -PassThru
git clone -q $targetRepoUrl

$sourceFiles = Join-Path $sourceRepoPath $Repository
$targetFiles = Join-Path $targetRepoPath "ShawnMenuService"


& "$PSScriptRoot\Sync-Folder.ps1" -SourceFolder $sourceFiles -TargetFolders $targetFiles -Exceptions "*.git"

Get-ChildItem $sourceFiles | foreach {

    if ($_.Name -ne ".git") {
   
    if (Test-Path -Path $_.FullName -PathType Container) {

        Copy-Item -Path $_.FullName -Destination $targetFiles -recurse -Force 
       } else {
       

        Copy-Item -Path $_.FullName -Destination $targetFiles -Force 
       }
    }
}



Set-Location -Path $targetFiles -PassThru

git add .

$commitMessage = "Update Repository on  $(Get-Date -Format "dd MMM, yyyy")"
git commit -m $commitMessage

git push -q

Set-Location $programDirectory -PassThru