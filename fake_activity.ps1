#FakeActivity

#Script Created by: WootScripts
#Change any of the parameters below to your needs.

#total number of mins script will run.
param($minutes = 240)

#opens Notepad.exe to collect input
Start-Process -FilePath "notepad.exe"

#will mimic key-press input every 60 seconds. 
$myshell = New-Object -com "Wscript.Shell"

for ($i = 0; $i -lt $minutes; $i++) {
  Start-Sleep -Seconds 5 #<--- Time in interval in seconds. Change to desired.
  $myshell.sendkeys("# ") #<--- symbol inside quote will be placed each interval. 
}
