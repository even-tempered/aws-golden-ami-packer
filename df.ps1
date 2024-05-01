# Set default password
$adminPassword = "Password@123"
$secureAdminPassword = ConvertTo-SecureString -String $adminPassword -AsPlainText -Force
net user Administrator $adminPassword
 
# Run sysprep
C:\Windows\System32\sysprep\sysprep.exe /generalize /oobe /shutdown /quiet
