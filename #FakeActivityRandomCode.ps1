#FakeActivityRandomCode

#Script Created by: WootScripts
#Change any of the parameters below to your needs.

# Function to get a random line of code
Function Get-RandomSentence {
    $sentences = @(
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
    Get-Random $sentences
    
}

# Infinite loop to print random sentences to the screen every minute
$myshell = New-Object -Com "wscript.shell"

while ($true) {
    $randomSentence = Get-RandomSentence
    $myshell.sendkeys(">> $randomSentence")
    Start-Sleep -Seconds 5
}