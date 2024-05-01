# Set default password for Administrator account
$password = "Password@123"
$securePassword = ConvertTo-SecureString -String $password -AsPlainText -Force
$user = [adsi]"WinNT://./Administrator,user"
$user.SetPassword($securePassword)
 
# Run EC2Config to perform sysprep
$ec2ConfigPath = "C:\Program Files\Amazon\Ec2ConfigService\Ec2Config.exe"
Start-Process -FilePath $ec2ConfigPath -ArgumentList "-sysprep" -NoNewWindow -Wait
