# Set administrator password
net user Administrator P@cker!
wmic useraccount where "name='Administrator'" set PasswordExpires=FALSE
