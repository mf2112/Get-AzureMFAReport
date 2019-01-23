# Get Multi Factor Authentication User Report
# It will get all enabled users with a title defined.
# Version 1.0

# Define Get-AzureMFAStatus function
function Get-AzureMFAStatus
{
    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({
              If ($_ -match "^\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$") {
                $True
              }
              else {
                Write-Output "$_ is not a correctly formatted email address"
              }
            })]
        [String[]]$UserPrincipalName
    )

    ForEach ($upn in $UserPrincipalName) {
    $user = Get-MsolUser -UserPrincipalName $upn
        # If MFA has been enabled or enforced, collect the methods and which is default
        if ($user.StrongAuthenticationRequirements.State) {
        $mfaStatus = $user.StrongAuthenticationRequirements.State
        $usermethod0 = $user.StrongAuthenticationMethods[0].MethodType
        $userdefault0 = $user.StrongAuthenticationMethods[0].IsDefault
        $usermethod1 = $user.StrongAuthenticationMethods[1].MethodType
        $userdefault1 = $user.StrongAuthenticationMethods[1].IsDefault
        }
        # If MFA has not been enabled yet, set results
        else {
        $mfaStatus = "Disabled"
        $usermethod0 = "None"
        $userdefault0 = "None"
        $usermethod1 = "None"
        $userdefault1 = "None"
        }

    # Set up result object with all collected or set properties   
    $Result = New-Object PSObject -property @{ 
    UserName = $user.DisplayName
    Email = $user.UserPrincipalName
    MFAStatus = $mfaStatus
    Method0 = $usermethod0
    Default0 = $userdefault0
    Method1 = $usermethod1
    Default1 = $userdefault1
    }
    Write-Output $Result
    }
}

# Check to see if user is logged into O365
Try {
    Get-MsolDomain -ErrorAction Stop | Out-Null
    }
Catch {
    Connect-MsolService
    }

# Get all O365 user emails (UPN) where Title has a value which usually indicates a person
$users = Get-MsolUser -All | 
Where-Object {$_.title} | 
Select-Object userprincipalname | 
Sort-Object userprincipalname

# Send the users emails (UPN) collected through the function
$export = $users | Get-AzureMFAStatus | 
Select-Object UserName,Email,MFAStatus,Method0,Default0,Method1,Default1

# Export to file
$export | Export-Csv `
            -Path ("C:\temp\O365-Users-MFA-Status-"+(get-date -Format MM-dd-yy)+".csv") `
            -NoTypeInformation `
            -Encoding UTF8
