$Base  = Read-Host "Enter Your CyberArk Base URL (as like https://cyberark.ekaynar.local)
>"

 $AuthX = Read-Host "Select the Connection Type:
 Enter 1 for CyberArk
 Enter 2 for LDAP
 Enter 3 for Radius
 YOUR CHOICE: "

if ($AuthX -eq 1) {
 $Url = "$Base/PasswordVault/api/Auth/cyberark/Logon"
}
elseif ($AuthX -eq 2) {
  $Url = "$Base/PasswordVault/api/Auth/LDAP/Logon"
}
elseif ($AuthX -eq 3) {
  $Url = "$Base/PasswordVault/api/Auth/Radius/Logon"
  }
else {
 $Url = "FCKU"
 }

$Body = @{
    'Username' = Read-Host "Please enter your Authentication User"
    'password' = Read-Host "Please enter your password" -AsSecureString
    "concurrentSession" = "true"
}

$Body.password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Body.password))

$Header = @{
     'ContentType' = 'application/json'
     'Authorization' = Invoke-RestMethod -Uri $Url -Method Post -Body $Body
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
