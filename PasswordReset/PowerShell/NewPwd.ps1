[CmdletBinding()]
param (
 [Parameter(Position=0, Mandatory=$True, ValueFromPipeline=$True)]
 [string]$SamAccountName,
 [string]$Password,
 [string]$RemoveWebPage
)

import-module ActiveDirectory;

$log = '\\srvaptest\c$\inetpub\PasswordReset_v2\Log\TraceLog.log'
$user = Get-ADUser -filter {SamAccountName -eq $SamAccountName} -Properties *
Write-Output ("`n"+(get-date -format o).ToString()+"`t"+$SamAccountName+"`tacconut request password reset.") |Out-File -FilePath $log -Append -Force -Encoding unicode

if ($user) { 
    if($user.EmailAddress) { 
        Try { 
            Set-ADAccountPassword -Identity $user -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $password -Force) -ErrorAction Stop
            Write-Output "Password has been changed.`nYou can close this page. This page has been already deleted"|Out-String
            Write-Output "`t`t`t`t`t`tChanged successfully."|Out-File -FilePath $log -Append -Force -Encoding unicode
            #Set-ADUser -Identity $user -ChangePasswordAtNextLogon $true
            Try {
                Remove-Item -Path ("C:\inetpub\PasswordReset\Temp\"+$RemoveWebPage+".*") -Force -Confirm:$false
            } #delete web page
            Catch {
                Write-Output ("`t`t`t`t`t`t")+$_.Exception.Message|Out-File -FilePath $log -Append -Force -Encoding unicode
            } #delete web page
        } # reset password
        Catch { 
            Write-Warning ("The password does not meet the domain complexity requirements:`n"+$_.Exception.Message)|Out-String
            Write-Output ("`t`t`t`t`t`t"+$_.Exception.Message ) |Out-File -FilePath $log -Append -Force -Encoding unicode
        } # reset password
        Try {
            If ($user.locekdout) {Unlock-ADAccount -Identity $user}
        } # unlock account
        Catch {
            write-warning ("Failed to unlock account:`n"+$_.Exception.Message) |out-string
            Write-Output ("`t`t`t`t`t`t"+$_.Exception.Message ) |Out-File -FilePath $log -Append -Force -Encoding unicode
        } # unlock account
        Finally {
            # write some user details
            write-output "Account Info:" |out-string
            $user | Select @{Name="Login Name";Expression={$_.SamAccountName}}, 
                @{Name="Full Domain Name";Expression={$_.UserPrincipalName}}, 
                @{Name="Display Name";Expression={$_.DisplayName}},
                @{Name="Given Name";Expression={$_.GivenName}}, 
                @{Name="Surname";Expression={$_.Surname}}, 
                @{Name="Name";Expression={$_.Name}}, 
                @{Name="Title";Expression={$_.Title}}, 
                @{Name="Descritpion";Expression={$_.Description}}, 
                @{Name="Employee ID";Expression={$_.EmployeeID}}, 
                @{Name="Employee Number";Expression={$_.EmployeeNumber}},
                @{Name="Manager";Expression={$_.Manager}},
                @{Name="E-mail Address";Expression={$_.EmailAddress}},
                @{Name="Mobile Phone";Expression={$_.MobilePhone}},
                @{Name="Office Phone";Expression={$_.OfficePhone}},
                @{Name="Home Phone";Expression={$_.HomePhone}},
                @{Name="Company";Expression={$_.Company}},
                @{Name="Division";Expression={$_.Division}},
                @{Name="Department";Expression={$_.Department}},
                @{Name="Office";Expression={$_.Office}},
                @{Name="Organization";Expression={$_.Organization}},
                @{Name="Street Address";Expression={$_.StreetAddress}},
                @{Name="City";Expression={$_.City}},
                @{Name="State";Expression={$_.State}},
                @{Name="P. O. Box";Expression={$_.POBox}},
                @{Name="ZIP code";Expression={$_.PostalCode}},
                @{Name="Country";Expression={$_.Country}},
                @{Name="Bad Logon Counts";Expression={$_.BadLogonCount}},
                @{Name="Logon Counts";Expression={$_.LogonCount}},
                @{Name="Last Logon Date";Expression={$_.LastLogonDate}},
                @{Name="Expired Password";Expression={$_.PasswordExpired}},
                @{Name="Password Expire at";Expression={$_.PasswordLastSet.AddDays((Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge.Days)}},
                @{Name="Locked Account";Expression={$_.LockedOut}} | out-string
    } # display user info
    } # if mail exist
    else {
        write-output 'Missing e-mail address for the account.' | out-string 
        Write-Output "`t`t`t`t`t`t`tMissing mail contact for the user, operation cancelled."|Out-File -FilePath $log -Append -Force -Encoding unicode
    } #if mail is missing
} # if user exist
else {
    write-output "$SamAccountName - The logon name does not exist."| out-string 
    Write-Output "`t`t`t`t`t`t`tSuch an account does not exist in Active Directory"|Out-File -FilePath $log -Append -Force -Encoding unicode
} #if user is missing
