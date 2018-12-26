# Get-AzureMFAReport
This script will gather a list of current O365 users with titles set, then pull their MFA setting and the methods if it is Enabled or Enforced.

The default output file is C:\temp\O365-Users-MFA-Status-<date>.csv. 

Here is a sample output:

UserName	Email	MFAStatus	Method0	Default0	Method1	Default1
user1	user1@email.addr	Disabled	None	None	None	None
user2	user2@email.addr	Enforced	OneWaySMS	TRUE	TwoWayVoiceMobile	FALSE
user3	user3@email.addr	PhoneAppOTP	TRUE	PhoneAppNotification	FALSE
user4	user4@email.addr Disabled	None	None	None	None
