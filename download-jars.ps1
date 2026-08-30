# Run this once: Right-click -> Run with PowerShell
$lib = Join-Path $PSScriptRoot "src\main\webapp\WEB-INF\lib"
New-Item -ItemType Directory -Force -Path $lib | Out-Null
$jars = @{
  "mysql-connector-j-8.3.0.jar" = "https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/8.3.0/mysql-connector-j-8.3.0.jar"
  "gson-2.11.0.jar" = "https://repo1.maven.org/maven2/com/google/code/gson/gson/2.11.0/gson-2.11.0.jar"
  "jsoup-1.18.1.jar" = "https://repo1.maven.org/maven2/org/jsoup/jsoup/1.18.1/jsoup-1.18.1.jar"
  "pdfbox-3.0.3.jar" = "https://repo1.maven.org/maven2/org/apache/pdfbox/pdfbox/3.0.3/pdfbox-3.0.3.jar"
  "pdfbox-io-3.0.3.jar" = "https://repo1.maven.org/maven2/org/apache/pdfbox/pdfbox-io/3.0.3/pdfbox-io-3.0.3.jar"
  "fontbox-3.0.3.jar" = "https://repo1.maven.org/maven2/org/apache/pdfbox/fontbox/3.0.3/fontbox-3.0.3.jar"
}
foreach ($name in $jars.Keys) {
  $out = Join-Path $lib $name
  Write-Host "Downloading $name ..."
  Invoke-WebRequest -Uri $jars[$name] -OutFile $out -UseBasicParsing
}
# Optional: add pdfbox entries to .classpath in Eclipse manually after download
Write-Host "Done. JARs in: $lib"
Write-Host "In Eclipse: Right-click project -> Refresh (F5) -> Project -> Clean"
Get-ChildItem $lib
