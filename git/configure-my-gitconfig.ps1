if(Test-Path "C:\_PostBuildContent\User_Answers.json") {
    $answers = (Get-Content -Path "C:\_PostBuildContent\User_Answers.json") -join "`n" | ConvertFrom-Json
    $FirstName = $answers.FirstName
    $LastName = $answers.LastName
    $Initials = $answers.Initials
    $EmailAddress = $answers.EmailAddress
}
else {
    $FirstName = Read-Host -Prompt 'Enter your first name'
    $LastName = Read-Host -Prompt 'Enter your last name'
    $Initials = -Join($FirstName.Substring(0,1), $LastName.Substring(0,1))
    $EmailAddress = Read-Host -Prompt 'Enter your Mesh Systems email address'
}

$Path = (Join-Path $env:UserProfile ".gitconfig")
(Get-Content $Path).Replace("<First Last>", "$FirstName $LastName") | Set-Content $Path
(Get-Content $Path).Replace("<email>", $EmailAddress) | Set-Content $Path
(Get-Content $Path).Replace("<fl>", $Initials.ToLower()) | Set-Content $Path
(Get-Content $Path).Replace("<UserName>", $env:UserName) | Set-Content $Path
