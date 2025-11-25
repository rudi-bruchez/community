# PowerShell script using ODBC that will likely fail due to 'date' as column name

$cnString = "Driver={ODBC Driver 18 for SQL Server};Server=localhost,1444;Database=PachadataTraining;TrustServerCertificate=Yes;"
$username = "sa"
$password = "Admin12345!"
$cnString += "Uid=$username;Pwd=$password;"
$query = "CREATE TABLE #t (date date);"

$conn = New-Object System.Data.Odbc.OdbcConnection
$conn.ConnectionString = $cnString
$conn.Open()

$cmd = New-Object System.Data.Odbc.OdbcCommand($query, $conn)
$reader = $cmd.ExecuteNonQuery()

$conn.Close()
