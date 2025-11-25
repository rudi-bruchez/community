docker pull mcr.microsoft.com/mssql/server:2025-latest

# ------------- Desktop -------------
docker run -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=Admin1234!' -e "MSSQL_PID=developerstandard" `
    -e "MSSQL_AGENT_ENABLED=true" -p 1444:1433 --name sql2025 --restart unless-stopped `
    --volume=D:/sqldata/backups:/var/opt/mssql/backups `
    -d mcr.microsoft.com/mssql/server:2025-latest

winget install --id=Microsoft.msodbcsql.18  -e
winget install sqlcmd
install-Module -Name dbatools