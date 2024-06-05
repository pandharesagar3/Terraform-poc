Write-Host "DB_HOST: $env:DB_HOST"
Write-Host "ADMIN_USER: $env:ADMIN_USER"
Write-Host "DB_USER: $env:DB_USER"
Write-Host "DB_NAME: $env:DB_NAME"

& "C:\Program Files\PostgreSQL\14\bin\psql.exe" --host=$env:DB_HOST --port=5432 --dbname=postgres --username=$env:ADMIN_USER --command="CREATE DATABASE $env:DB_NAME;"
# Write-Host "step 1"
& "C:\Program Files\PostgreSQL\14\bin\psql.exe" --host=$env:DB_HOST --port=5432 --dbname=$env:DB_NAME --username=$env:ADMIN_USER --command="CREATE USER $env:DB_USER WITH PASSWORD '$env:DB_PASSWORD';"
& "C:\Program Files\PostgreSQL\14\bin\psql.exe" --host=$env:DB_HOST --port=5432 --dbname=postgres --username=$env:ADMIN_USER --command="ALTER DATABASE $env:DB_NAME OWNER TO $env:DB_USER;"
# Write-Host "step 2"
& "C:\Program Files\PostgreSQL\14\bin\psql.exe" --host=$env:DB_HOST --port=5432 --dbname=$env:DB_NAME --username=$env:ADMIN_USER --command='CREATE EXTENSION IF NOT EXISTS pgcrypto; CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";'
# Write-Host "step 3"
$command = @"
GRANT ALL PRIVILEGES ON DATABASE $env:DB_NAME TO $env:DB_USER;
GRANT CONNECT, TEMPORARY ON DATABASE $env:DB_NAME TO $env:DB_USER;
"@

$command = $command -replace 'DB_NAME', $env:DB_NAME
$command = $command -replace 'DB_USER', $env:DB_USER

Write-Host "Command to be executed:"
Write-Host $command

& "C:\Program Files\PostgreSQL\14\bin\psql.exe" --host=$env:DB_HOST --port=5432 --dbname=$env:DB_NAME --username=$env:ADMIN_USER --command=$command
