docker pull mcr.microsoft.com/mssql/server:2025-latest

# ------------- Desktop -------------
docker run -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=Admin1234!' -e "MSSQL_PID=developerstandard" `
    -e "MSSQL_AGENT_ENABLED=true" -p 1444:1433 --name sql2025 --restart unless-stopped `
    --volume=D:/sqldata/backups:/var/opt/mssql/backups `
    -d mcr.microsoft.com/mssql/server:2025-latest

# ------------- Surface -------------
# docker run --user=mssql --env=ACCEPT_EULA=Y --env=MSSQL_SA_PASSWORD=Admin1234! `
#     --env=MSSQL_PID=developer --env=PAL_ENABLE_VP=0 `
#     --env=PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin `
#     --env=MSSQL_RPC_PORT=135 --volume=C:/var/sqldata/backups:/var/opt/mssql/backups `
#     --network=bridge -p 5434:1433 --restart=no -d mcr.microsoft.com/mssql/server:2025-latest

    # MSSQL_PID does not seem to be documented yet.
    # https://learn.microsoft.com/en-us/sql/linux/sql-server-linux-configure-environment-variables?view=sql-server-ver17#environment-variables

winget install --id=Microsoft.msodbcsql.18  -e
winget install sqlcmd
install-Module -Name dbatools