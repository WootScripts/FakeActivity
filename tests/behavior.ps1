# Locks the observable behavior of the fake-activity scripts.
# Windows process and COM calls are mocked, so this does not open Notepad or type.
param([string]$Root = "")

$ErrorActionPreference = "Stop"
if (-not $Root) {
    $Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
}

$script:Failures = 0

function Assert-Equal {
    param([string]$Name, [string]$Actual, [string]$Expected)
    if ($Actual -cne $Expected) {
        Write-Output "FAIL $Name"
        Write-Output "--- actual ---"
        Write-Output $Actual
        Write-Output "--- expected ---"
        Write-Output $Expected
        $script:Failures++
    }
}

function Reset-Trace {
    $global:Events = [System.Collections.Generic.List[string]]::new()
    $global:SleepsSeen = 0
    $global:MaxSleeps = 0
    $global:RandomCalls = 0
    $global:ExpectedPool = $null
}

function Start-Process {
    [CmdletBinding()]
    param([Parameter(Position = 0)][string]$FilePath)
    $global:Events.Add("proc|$FilePath") | Out-Null
}

function Start-Sleep {
    [CmdletBinding()]
    param([int]$Seconds)
    $global:Events.Add("sleep|$Seconds") | Out-Null
    $global:SleepsSeen++
    if ($global:MaxSleeps -gt 0 -and $global:SleepsSeen -ge $global:MaxSleeps) {
        throw "STOPLOOP"
    }
}

function New-Object {
    [CmdletBinding(DefaultParameterSetName = "Type")]
    param(
        [Parameter(Position = 0, ParameterSetName = "Com")]
        [string]$ComObject,
        [Parameter(Position = 0, ParameterSetName = "Type")]
        [string]$TypeName
    )
    if ($ComObject) {
        $global:Events.Add("com|$ComObject") | Out-Null
        $obj = Microsoft.PowerShell.Utility\New-Object -TypeName psobject
        $null = $obj | Microsoft.PowerShell.Utility\Add-Member -MemberType ScriptMethod -Name sendkeys -Value {
            param($keys)
            $shown = ([string]$keys).Replace("`r", "\r").Replace("`n", "\n")
            $global:Events.Add("keys|$shown")
        }
        return $obj
    }
    Microsoft.PowerShell.Utility\New-Object -TypeName $TypeName
}

function Get-Random {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [object]$InputObject
    )
    $pool = @(@($InputObject) | ForEach-Object { [string]$_ })
    $actual = $pool -join "`0"
    $expected = @($global:ExpectedPool) -join "`0"
    if ($actual -cne $expected) {
        throw "Get-Random input does not match the expected phrase list"
    }
    $index = $pool.Count - 1 - ($global:RandomCalls % $pool.Count)
    $global:RandomCalls++
    return $pool[$index]
}

function Invoke-Captured {
    param(
        [string]$Path,
        [hashtable]$Named,
        [object]$Positional,
        [switch]$UsePositional,
        [int]$MaxSleeps = 0,
        [string[]]$Pool
    )
    Reset-Trace
    $global:MaxSleeps = $MaxSleeps
    $global:ExpectedPool = $Pool
    try {
        if ($UsePositional) {
            & $Path $Positional
        } elseif ($null -ne $Named) {
            & $Path @Named
        } else {
            & $Path
        }
    } catch {
        if ("$_" -notmatch "STOPLOOP") { throw }
    }
    return $global:Events
}

function Format-Events {
    param($Events)
    return ($Events -join "`n")
}

$codeSentences = @(
    "Description . . . . . . . . . . . : MediaTek Wi-Fi 6 MT7921 Wireless LAN Card`n"
    "Physical Address. . . . . . . . . : B4-8C-9D-8E-1F-B7`n"
    "DHCP Enabled. . . . . . . . . . . : Yes`n"
    "Autoconfiguration Enabled . . . . : Yes`n"
    "IPv6 Address. . . . . . . . . . . : fd5e:122d:48a1:4905:cad7:442c:4472:5810(Preferred)`n"
    "Temporary IPv6 Address. . . . . . : fd5e:122d:48a1:4905:6073:fdc2:953c:c46(Preferred)`n"
    "Link-local IPv6 Address . . . . . : fe80::8fe5:725d:3ffb:44f7%4(Preferred)`n"
    "IPv4 Address. . . . . . . . . . . : 172.16.0.120(Preferred)`n"
    "Subnet Mask . . . . . . . . . . . : 255.255.255.0`n"
    "Lease Obtained. . . . . . . . . . : Monday, October 2, 2023 3:54:12 PM`n"
    "Lease Expires . . . . . . . . . . : Wednesday, October 4, 2023 12:24:27 PM`n"
    "Default Gateway . . . . . . . . . : 172.16.0.1`n"
    "DHCP Server . . . . . . . . . . . : 172.16.0.1`n"
    "DHCPv6 IAID . . . . . . . . . . . : 78941341`n"
    "DHCPv6 Client DUID. . . . . . . . : 00-01-00-01-2B-02-22-65-24-4B-FE-41-B5-56`n"
    "DNS Servers . . . . . . . . . . . : 45.90.28.0, 45.90.30.0`n"
    "NetBIOS over Tcpip. . . . . . . . : Enabled`n"
)
$textSentences = @(
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit.`n",
    "The quick brown fox jumps over the lazy dog.`n",
    "Life is like a box of chocolates, you never know what you're gonna get.`n",
    "To be or not to be, that is the question.`n"
)

function Get-RandomTrace {
    param([string]$Prefix, [string[]]$Sentences, [int]$Count)
    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add("com|wscript.shell") | Out-Null
    for ($i = 0; $i -lt $Count; $i++) {
        $phrase = $Sentences[$Sentences.Count - 1 - ($i % $Sentences.Count)]
        $shown = ($Prefix + $phrase).Replace("`r", "\r").Replace("`n", "\n")
        $lines.Add("keys|$shown") | Out-Null
        $lines.Add("sleep|5") | Out-Null
    }
    return ($lines -join "`n")
}

function Get-SymbolTrace {
    param([int]$Count)
    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add("proc|notepad.exe") | Out-Null
    $lines.Add("com|Wscript.Shell") | Out-Null
    for ($i = 0; $i -lt $Count; $i++) {
        $lines.Add("sleep|5") | Out-Null
        $lines.Add("keys|# ") | Out-Null
    }
    return ($lines -join "`n")
}

$fake = Join-Path $Root "fake_activity.ps1"
$code = Join-Path $Root "#FakeActivityRandomCode.ps1"
$text = Join-Path $Root "FakeActivityRandomText.ps1"

foreach ($path in @($fake, $code, $text)) {
    $parseErrors = $null
    $null = [System.Management.Automation.Language.Parser]::ParseFile($path, [ref]$null, [ref]$parseErrors)
    if ($parseErrors) {
        throw "Parse error in ${path}: $parseErrors"
    }
}

Assert-Equal "minutes positional 0" (Format-Events (Invoke-Captured $fake -UsePositional -Positional 0)) (Get-SymbolTrace 0)
Assert-Equal "minutes named 0" (Format-Events (Invoke-Captured $fake -Named @{ minutes = 0 })) (Get-SymbolTrace 0)
Assert-Equal "minutes named 3" (Format-Events (Invoke-Captured $fake -Named @{ minutes = 3 })) (Get-SymbolTrace 3)
Assert-Equal "minutes string 3" (Format-Events (Invoke-Captured $fake -Named @{ minutes = "3" })) (Get-SymbolTrace 3)
Assert-Equal "minutes fraction 2.1" (Format-Events (Invoke-Captured $fake -Named @{ minutes = 2.1 })) (Get-SymbolTrace 3)
Assert-Equal "minutes negative" (Format-Events (Invoke-Captured $fake -Named @{ minutes = -5 })) (Get-SymbolTrace 0)
Assert-Equal "minutes default" (Format-Events (Invoke-Captured $fake)) (Get-SymbolTrace 240)
Assert-Equal "minutes one" (Format-Events (Invoke-Captured $fake -Named @{ Minutes = 1 })) (Get-SymbolTrace 1)

$draws = 6
Assert-Equal "random code" (Format-Events (Invoke-Captured $code -MaxSleeps $draws -Pool $codeSentences)) (Get-RandomTrace ">> " $codeSentences $draws)
Assert-Equal "random text" (Format-Events (Invoke-Captured $text -MaxSleeps $draws -Pool $textSentences)) (Get-RandomTrace "Random Sentence: " $textSentences $draws)

if ($script:Failures) {
    Write-Output "$script:Failures failed"
    exit 1
}
Write-Output "ok"
