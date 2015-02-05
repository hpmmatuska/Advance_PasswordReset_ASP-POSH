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
 
namespace PowerShellExecution
{
    public partial class Default : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
 
        }
 
        protected void ExecuteCode_Click(object sender, EventArgs e)
        {
            // Clean the Result TextBox
            ResultBox.Text = string.Empty;
 
            // Validate the input & remove all potentially dangerous chars
            var NewInput = Input.Text;
            NewInput = Regex.Replace(NewInput,@"[^a-zA-Z\d\s]","");

            // Initialize PowerShell engine
            var shell = PowerShell.Create();
 
            // Add the script to the PowerShell object
            shell.Commands.AddScript("C:\\inetpub\\PasswordReset_v2\\PowerShell\\CreateCustomWeb.ps1 " + NewInput);
 
            // Execute the script
            var results = shell.Invoke();
 
            // display results, with BaseObject converted to string
            // Note : use |out-string for console-like output
            if (results.Count > 0)
            {
                // We use a string builder ton create our result text
                var builder = new StringBuilder();
 
                foreach (var psObject in results)
                {
                    // Convert the Base Object to a string and append it to the string builder.
                    // Add \r\n for line breaks
                    builder.Append(psObject.BaseObject.ToString() + "\r\n");
                }
 
                //Encode the string in HTML (prevent security issue with dangerous caracters like < >
                //ResultBox.Text = Server.HtmlEncode(builder.ToString());
                ResultBox.Text = builder.ToString();
            }
            //Input.Text = string.Empty;
        }
    }
}