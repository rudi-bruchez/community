# parameters
$sqlFilesDirectory = "./procs"
$sqlServerName = "localhost,5434"
$databaseName = "PachadataTraining"
$login = "sa"
$password = "Admin1234!"

# Get all .sql files in the specified directory
$sqlFiles = Get-ChildItem -Path $sqlFilesDirectory -Filter "*.sql"

# Loop through each SQL file
foreach ($sqlFile in $sqlFiles) {
    Write-Host "Executing SQL file: $($sqlFile.FullName)"

    $sqlcmdCommand = "sqlcmd -S $sqlServerName -d $databaseName -C -U $login -P $password -i $($sqlFile.FullName)"
    Invoke-Expression $sqlcmdCommand

    Write-Host "" # Add a blank line for readability
}

Write-Host "Finished executing all SQL files."