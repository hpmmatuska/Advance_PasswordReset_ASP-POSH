# Simple-PasswordReset_ASP-POSH
Acitve Directory Password reset over ASP.Net with PowerShell

# Long description

The ASP page contains a textbox, which is pulled as a parameter to the powershell script. Output from the ps1 script
is catched and displayed back to the web page.

1. The script itself will generate custom webpage for a specified user with reset password possibility. The link is then send by mail.
2. The generated link will allow set new password for specified user. After password change the page is deleted.

All the actions performed by script have proper error handling defined and all activity is logged to the log file.

# Setup
1. In IIS create new web application pools
2. set application pool to be running under user with appropriate rights
    - delegated rights for OU in AD (http://support.microsoft.com/kb/296999 , http://support.microsoft.com/kb/294952):  
        (Only User objects, General and Property specific) 
        Reset Password, Read pwdLastSet, Write pwdLastSet, Read lockoutTime, Write lockoutTime
    - has "full" controll to the website folder
    - can run PowerShell on the IIS host (Local admin, or follow http://www.airbornegeek.com/2011/03/powershell-while-not-an-admin-well-that-wasnt-any-fun/)
3. set Application Pool to use .Net v.4
4. Create The directory structure for the new Web Application/Site
5. Create Web Application (IIS site, or Virtual Application) running under the created Application Pool and Destination
6. register application pool to get own site signature:
    - go to: %windir%\Microsoft.NET\Framework64\v4.0.30319 
    - run: aspnet_regiis -ga "IIS APPPOOL\app-pool-name"

