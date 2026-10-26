param($minutes = 240)
Start-Process -FilePath "notepad.exe"
$myshell = New-Object -com "Wscript.Shell"
for ($i = 0; $i -lt $minutes; $i++) {
    Start-Sleep -Seconds 5
    $myshell.sendkeys("# ")
}
