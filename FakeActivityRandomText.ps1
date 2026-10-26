$sentences = @(
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit.`n",
    "The quick brown fox jumps over the lazy dog.`n",
    "Life is like a box of chocolates, you never know what you're gonna get.`n",
    "To be or not to be, that is the question.`n"
)
$myshell = New-Object -Com "wscript.shell"
while ($true) {
    $myshell.sendkeys("Random Sentence: $(Get-Random $sentences)")
    Start-Sleep -Seconds 5
}
