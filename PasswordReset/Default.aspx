<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Default.aspx.cs" Inherits="PowerShellExecution.Default" ResponseEncoding="UTF-8" %>
 
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">

<head id="Head1" runat="server">
    <title>Password Reset</title>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="title" content="Password Reset" />
    <meta name="description" content="AD Password Reset" />

    <meta name="language" content="en" />

    <meta name="subject" content="Password Reset" />
    <meta name="MSSmartTagsPreventParsing" content="true" />

    <link rel="icon" type="image/png" href="/images/favicon.png">
</head>

<form id="form1" runat="server">

<body>
    <div>
    	<h1 align="Left">
				<img src="images/logo.gif" style="float:left;margin:0 15px 0 0;" />
				Password Reset<BR> for domain: 
		</h1>
        <table>
            <tr>
                <td>&nbsp;</td>
                <td>&nbsp;</td>
            </tr>
            <tr>
                <td>Enter Login for which you would like to reset password:</td>
                <td>&nbsp;</td>
            </tr>
            <tr>
                <td><asp:TextBox ID="Input" MaxLength="15" runat="server"></asp:TextBox></td>
                <td><asp:Button ID="ExecuteCode" runat="server" Text="Send by mail" Width="200" onclick="ExecuteCode_Click" ></asp:Button></td>
            </tr>
            <tr>
                <td><h3>System Answer:</h3></td>
                <td>&nbsp;</td>
            </tr>
	    </table>
		
	    <asp:TextBox ID="ResultBox" TextMode="MultiLine" Width="700" Height="400" runat="server"></asp:TextBox>

    </div>
</form>
</body>
</html>