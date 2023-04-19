###############################################################################
#
# Compare a list  of files in $backupDir (specified below) against files used 
# by Veeam backups and export the diff. (c) github.com/joeselway
#
###############################################################################

### USER CONFIG START ###

$backupDir = "F:\VeeamRepo\"
$scriptDir = "C:\Scripts\"

### USER CONFIG END ###

Import-Module Veeam.Backup.PowerShell

Set-Location $scriptDir

Get-ChildItem -Path $backupDir -Recurse | Select-Object FullName | Out-File "AllFilesList.txt"

$veeamBackups = Get-VBRBackup
$veeamUsedFilesList = @()

foreach ($backup in $veeamBackups) {
    $backupFiles = Get-VBRBackupFile -Backup $backup | Select-Object -ExpandProperty Path
    $veeamUsedFilesList += $backupFiles
}

$veeamUsedFilesList | Out-File "VeeamUsedFilesList.txt"

$allFiles = Get-Content "AllFilesList.txt"
$veeamFiles = Get-Content "VeeamUsedFilesList.txt"

$allFilesBaseNames = $allFiles | ForEach-Object { [System.IO.Path]::GetFileName($_) }
$unusedFiles = $allFiles | Where-Object { [System.IO.Path]::GetFileName($_) -notin $veeamFiles }

$unusedFiles | Out-File "UnusedFilesList.txt"