#FakeActivityRandomText

#Script Created by: WootScripts
#Change any of the parameters below to your needs.

# Function to get a random sentence
Function Get-RandomSentence {
    $sentences = @(
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit.`n",
        "The quick brown fox jumps over the lazy dog.`n",
        "Life is like a box of chocolates, you never know what you're gonna get.`n",
        "To be or not to be, that is the question.`n"
    )
    Get-Random $sentences
}

# Infinite loop to print random sentences to the screen every minute
$myshell = New-Object -Com "wscript.shell"

while ($true) {
    $randomSentence = Get-RandomSentence
    $myshell.sendkeys("Random Sentence: $randomSentence")
    Start-Sleep -Seconds 5
}
