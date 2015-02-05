[CmdletBinding()]
param (
 [Parameter(Position=0, Mandatory=$True, ValueFromPipeline=$True)]
 [string]$SamAccountName
)

import-module ActiveDirectory;

$log = 'c:\inetpub\PasswordReset\Log\TraceLog.log'
$Random_Page_Path = 'c:\inetpub\PasswordReset\Temp\'
$user = Get-ADUser -filter {SamAccountName -eq $SamAccountName} -Properties *
Write-Output ("`n"+(get-date -format o).ToString()+"`t"+$SamAccountName+"`tuser request link for password reset.") |Out-File -FilePath $log -Append -Force -Encoding unicode

Function Get-RandomName {
        $tmp= @('a','b','c','d','e','f','g','h','i','j','k','m','n','o','p','q','r','s','t','u','v','w','x','y','z')
	$tmp+=@('A','B','C','D','E','F','G','H','I','J','K','L','M','N','P','Q','R','S','T','U','V','W','X','Y','Z')
	$tmp+=@('0','1','2','3','4','5','6','7','8','9')
        $Result=''; for($i=1; $i -le 64; $i ++) {$Result+= ($tmp | Get-Random -Count 1)}
        Return $Result
}

if ($user) {
    if($user.EmailAddress) {
        do {
            $Random_Page = Get-RandomName
            $Random_Page_Path += $Random_Page
            $Random_Page_Link = "http://localhost/Temp/" + $Random_Page + ".aspx"
        } until (!(Test-Path ($Random_Page_Path+".aspx"))) # if such a file exist
        $Page_Code = "
            <%@ Page Language=""C#"" AutoEventWireup=""true"" CodeFile=""$Random_Page.aspx.cs"" Inherits=""PowerShellExecution2.Default"" ResponseEncoding=""UTF-8"" %>
            <!DOCTYPE html PUBLIC ""-//W3C//DTD XHTML 1.0 Transitional//EN"" ""http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"">
            <html xmlns=""http://www.w3.org/1999/xhtml"">
            <head id=""Head2"" runat=""server"">
                <title>Password Reset</title>
                <meta http-equiv=""Content-Type"" content=""text/html; charset=utf-8"" />
                <meta name=""title"" content=""Password Reset"" />
                <meta name=""description"" content=""AD Password Reset"" />
                <meta name=""language"" content=""en"" />
                <meta name=""subject"" content=""Password Reset"" />
                <meta name=""MSSmartTagsPreventParsing"" content=""true"" />
                <link rel=""icon"" type=""image/png"" href=""/images/favicon.png"">
            </head>
            <body>
            <form id=""form2"" runat=""server"">
            <div>
	            <h1 align=""Left"">
		            <img src=""/images/logo.gif"" style=""float:left;margin:0 15px 0 0;"" />
		            Password Reset<BR> for domain:
	            </h1>
                    <table>
                    <tr>
                        <p>
                           New password must meet prerequisites:<br>
                                    <ul>
                                        <li>at least 6 characters</li>
                                        <li>Must contains characters at least three from these four categories</li>
                                        <ul>
                                            <li>Alphabet Capital letters (A - Z)</li>
                                            <li>Alphabet small letters (a - z)</li>
                                            <li>Numbers (0 - 9)</li>
                                            <li>Non-AlphaNumerical characters (!, $, #, %, ...)</li>
                                        </ul>
                                    </ul>
                        </p>
                    </tr>
	                <tr>
                        <%--<asp:ValidationSummary runat=server HeaderText=""Zadali ste nasledovné chyby:"" />--%>
	                </tr>
                    <tr>
                        <td>
                            <p style=""color:red""><asp:RequiredFieldValidator runat=server ControlToValidate=InputA ErrorMessage=""Chýbajúce heslo""> * </asp:RequiredFieldValidator></p>
                        </td>
		                <td>Enter New Password:</td>
                        <td><asp:TextBox ID=""InputA"" type=password MaxLength=""25"" runat=""server""></asp:TextBox></td>
		                <td>
			                <p style=""color:red""><asp:RegularExpressionValidator runat=server display=dynamic ControlToValidate=""InputA"" ErrorMessage=""The password does not complexity requirements."" ValidationExpression=""(?=^.{6,15}$)((?=.*\d)(?=.*[A-Z])(?=.*[a-z])|(?=.*\d)(?=.*[^A-Za-z0-9])(?=.*[a-z])|(?=.*[^A-Za-z0-9])(?=.*[A-Z])(?=.*[a-z])|(?=.*\d)(?=.*[A-Z])(?=.*[^A-Za-z0-9]))^.*""/></p>
		                </td>
                    </tr>
                    <tr>
		                <td>
                            <p style=""color:red""><asp:RequiredFieldValidator runat=server ControlToValidate=InputB ErrorMessage=""Repeat Password.""> * </asp:RequiredFieldValidator></td></p>
		                <td>Repead Password:</td>
                        <td><asp:TextBox ID=""InputB"" type=password MaxLength=""25"" runat=""server""></asp:TextBox></td>
		                <td>
                            <p style=""color:red""><asp:CompareValidator runat=server ControlToValidate=InputA ControlToCompare=InputB ErrorMessage=""Passwords not match."" /></p>
                        </td>
                    </tr>
                    <tr>
		                <td>&nbsp;</td>
		                <td>&nbsp;</td><%--<td><input type=submit runat=server id=cmdSubmit value=Submit></td>--%>
                        <td><asp:Button ID=""ExecuteCode2"" runat=""server"" Text=""Change PWD"" Width=""150"" onclick=""ExecuteCode_Click2"" ></asp:Button></td>
                    </tr>
                    <tr>
		                <td>&nbsp;</td>
                        <td><h3>System answer:</h3></td>
                        <td>&nbsp;</td>
                    </tr>
	            </table>
	            <asp:TextBox ID=""ResultBox2"" TextMode=""MultiLine"" Width=""700"" Height=""350"" runat=""server""></asp:TextBox>
            </div>
            </form>
            </body>
            </html>
        "
        $Page_CodeBehind = "
            using System;
            using System.Collections.Generic;
            using System.Linq;
            using System.Web;
            using System.Web.UI;
            using System.Web.UI.WebControls;
            using System.Text;
            using System.Management.Automation;
            using System.Management.Automation.Runspaces;
            using System.Text.RegularExpressions;
 
            namespace PowerShellExecution2
            {
                public partial class Default : System.Web.UI.Page
                {
                    protected void Page_Load(object sender, EventArgs e) {}
                    protected void ExecuteCode_Click2(object sender, EventArgs e)
                    {
                        ResultBox2.Text = string.Empty;
                        var shell2 = PowerShell.Create();
                        var NewInput2 = ""\"""" + InputA.Text + ""\"""";
                        NewInput2 = Regex.Replace(NewInput2,@""[^\42\22]"","""""");
                        shell2.Commands.AddScript(""C:\\inetpub\\PasswordReset_v2\\PowerShell\\NewPwd.ps1 -SamAccountName $SamAccountName -Password "" + NewInput2 +""-RemoveWebPage $Random_Page"");
                        var results2 = shell2.Invoke();
                        if (results2.Count > 0)
                        {
                            var builder2 = new StringBuilder();
                            foreach (var psObject2 in results2) { builder2.Append(psObject2.BaseObject.ToString() + ""\r\n"");}
                            ResultBox2.Text = builder2.ToString();
                        }
                    }
                }
            }
        "
        Try {
            Write-Output $Page_Code | Out-File -FilePath ($Random_Page_Path + ".aspx") -Force -Encoding utf8 -ErrorAction Stop
            Write-Output $Page_CodeBehind | Out-File -FilePath ($Random_Page_Path + ".aspx.cs") -Force -Encoding utf8 -ErrorAction Stop
            Write-Output "The custom Password reset page has been created." | out-string

            $GivenName=$user.GivenName
            $EmailMsg = "
                    <p style='font-family:calibri'>
                        Dear $GivenName<br><br>
                        You have requested Password reset. To complete the task, please go to: <a href='$Random_Page_Link'>Password Reset Page</a><br><br>. 
			If you did not request the password reset, you can safelly ignore this mail.
                    </p>
                    <p style='font-family:calibri'>
			This is automatically generated mail. Please DO NOT ANSWER.
                    </p>
                "
            $encoding = [System.Text.Encoding]::UTF8
            ForEach ($email in $User.EmailAddress) {
                Try {
                    send-mailmessage -to $email -from "<user@domain>" -Subject "Password Change" -body $EmailMsg -smtpserver smtp -BodyAsHtml -Encoding $encoding -ErrorAction Stop
                    write-output ("Link to the page for password reset has been send to: "+$user.EmailAddress+"`nCheck your inbox.") |Out-String
                    Write-Output ("`t`t`t`t`t`tSending link to "+$user.EmailAddress) |Out-File -FilePath $log -Append -Force -Encoding unicode
                } # send mail
                Catch {
                    write-warning ("Cannot send mail:`n"+$_.Exception.Message) |Out-String
                    Write-output ("`t`t`t`t`t`t"+$_.Exception.Message) |Out-File -FilePath $log -Append -Force -Encoding unicode
                } #send mail
            }
        } # create custom password reset page
        Catch {
            write-warning ("Cannot create password reset page:"+$_.Exception.Message) | Out-String
            write-output ("`t`t`t`t`t`t"+$_.Exception.Message) | Out-File -FilePath $log -Append -Force -Encoding unicode
        } #create custom password reset page
    } #if mail exist
    else {
        write-output "The account $SamAccountName is missing e-mail address" | out-string
        Write-Output "`t`t`t`t`t`tMissing mail contact for the user, operation cancelled."|Out-File -FilePath $log -Append -Force -Encoding unicode
    } #missing mail
} #if user exist
else {
    write-output "$SamAccountName - account does not exist"| out-string
    Write-Output "`t`t`t`t`t`tSuch an account does not exist in Active Directory"|Out-File -FilePath $log -Append -Force -Encoding unicode
} #non existing user

