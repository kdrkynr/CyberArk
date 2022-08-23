$Base  = Read-Host "Enter the Base URL as like https://cyberark.ekaynar.local"

$Url1 = "$Base/PasswordVault/api/Auth/cyberark/Logon"

$Body = @{
    'Username' = Read-Host "Please enter your CyberArk User"
    'password' = Read-Host "Please enter your password" -AsSecureString
    "concurrentSession" = "true"
}

$Body.password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Body.password))

$Header = @{
     'ContentType' = 'application/json'
     'Authorization' = Invoke-RestMethod -Uri $Url1 -Method Post -Body $Body
}

"PSM Servers" | Out-File C:\cyberark.txt -Append
(Invoke-RestMethod -Uri "$Base/PasswordVault/api/PSM/Servers" -Headers $Header).PSMServers | Out-File C:\cyberark.txt -Append

"Platforms" | Out-File C:\cyberark.txt -Append
((Invoke-RestMethod -Uri "$Base/PasswordVault/api/Platforms" -Headers $Header).Platforms).General | Sort-Object platformbaseid | ft platformbaseid, name | Out-File C:\cyberark.txt -Append

"Safes" | Out-File C:\cyberark.txt -Append
$Safes = Invoke-RestMethod -Uri "$Base/PasswordVault/api/Safes" -Headers $Header -Method Get
$TNofSafes = $Safes.count
"Total Safe Number: $TNofSafes" | Out-File C:\cyberark.txt -Append
$safes.value | Sort-Object safenumber | ft SafeName, creator, managingCPM | Out-File C:\cyberark.txt -Append

"LDAP Directories" | Out-File C:\cyberark.txt -Append
Invoke-RestMethod -Uri "$Base/PasswordVault/api/Configuration/LDAP/Directories" -Headers $Header | Out-File C:\cyberark.txt -Append

"Users" | Out-File C:\cyberark.txt -Append
$Users = Invoke-RestMethod -Uri "$Base/PasswordVault/api/Users" -Headers $Header -Method Get
$TNofUsers = $Users.Total
"Total User Number: $TNofUsers" | Out-File C:\cyberark.txt -Append
$Users.Users | Sort-Object username | Ft username, source, userType | Out-File C:\CyberArk.txt -Append
