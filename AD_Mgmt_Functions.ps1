
function Grant-Access{

<<<<<<< HEAD
<#
    .SYNOPSIS
        Grants read, write, and modify permissions to a folder, subfolder and files.  
        Can be applied to a single directory or a list of directories in a .CSV file.

    .EXAMPLE 
        "Grant-Access -username Dbudris -Filepath G:\users\dbudris\github"
        
        This command grants read, write and modify permissions to the user Dbudris
        for the folder G:\dbudris\github and all subfolders and files.

    .EXAMPLE 
        "Grant-Access -batch true"
        Open a .CSV or .TXT file containing a username and list of directories to grant that user access to.  
        
        The .CSV should be formatted as follows:
            C:\firstfolder,username
            C:\secondfolder
            C:\thirdfolder
            C:\so-on
       
        The user will be granted read, write, and modify access to all the folders listed, 
        as well as their subfolders and files.
    
    .NOTES

       -- Created by Dan Budris 6/2015; find more on github.com/danbudris --

   #>

=======
>>>>>>> 80a1981489e65c44ec4348b1f8a4de8efc543ce3
Param(
[string]$batch,
[string]$username,
[string]$filePath
)##end paramter

if ($batch -eq "true"){
Function PermBatch {

#FUNCTION TO OPEN A SELECT-FILE DIALOG BOX

Function Get-FileName($initialDirectory)
{   
 [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") |
 Out-Null

 $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
 $OpenFileDialog.initialDirectory = $initialDirectory
 $OpenFileDialog.filter = "All files (*.*)| *.*"
 $OpenFileDialog.ShowDialog() | Out-Null
 $OpenFileDialog.filename
} #end function Get-FileName

$csv = Get-FileName -initialDirectory "c:\fso" #sets the variable csv to the file selected in the GUI

$User = (Import-CSV "$csv" | select -Property name -first 1 -ExpandProperty name) #grabs the name property out of the csv, and converts it to a string so it can be used in the command

$Permissions = Import-Csv "$csv" # gets the csv, and imports it as a table it holds in memory

$inherit = [system.security.accesscontrol.InheritanceFlags]"ContainerInherit, ObjectInherit" #sets object inheritence 

$propagation = [system.security.accesscontrol.PropagationFlags]"None" 

ForEach($line in $Permissions){

$acl = Get-Acl $line.Path

$accessrule = New-Object system.security.AccessControl.FileSystemAccessRule($User, "Modify", $inherit, $propagation, "Allow")

$acl.AddAccessRule($accessrule)
set-acl -aclobject $acl $line.Path
}
}##end permbatch function
PermBatch
}


else{ 

$inherit = [system.security.accesscontrol.InheritanceFlags]"ContainerInherit, ObjectInherit" ##sets object inheritence 
$propagation = [system.security.accesscontrol.PropagationFlags]"None" 
$acl = Get-Acl $filePath 
$accessrule = New-Object system.security.AccessControl.FileSystemAccessRule($Username, "Modify", $inherit, $propagation, "Allow")

foreach($file in $filePath){

Try{
  
  $acl.AddAccessRule($accessrule)
  set-acl -aclobject $acl $file
}##end try

Catch [System.Management.Automation.MethodInvocationException]{
     write-host "USERNAME IS INCORRECT >_<
     " -ForegroundColor Red
     return
}##end catch1

Catch [System.Management.Automation.RuntimeException]{
    write-host "FILEPATH IS INCORRECT >_<" -ForegroundColor Red
    return
}##end catch2

Catch {
    $_.Exception.GetType().Fullname ##report error name that has not been accounted for already
    write-host "UNEXPECTED ERROR >_<" -ForegroundColor Red
    return
}##end catch3

write-host "GRANTED :)" -ForegroundColor Green -BackgroundColor DarkGray ##colors are fun, so is a completed action w/o errors!
}##end foreach

}}##end function


function New-User {

<<<<<<< HEAD
<#

.SYNOPSIS
Creates new active directory useres; can accept paramaters for a single user, 
or uploads a batch of new users from a .CSV or .TXT.

.EXAMPLE
"New-User -firstname Dan -lastname Budris -Unit Technology -Password BlahDeBlah 

Creates an active directory user, Dbudris, with the password BlahDeBlah with the
Technology unit login script.  Modify the script to accept your units, OUs, domains, 
and login scripts.

.EXAMPLE
"New-User -Batch true"

Loads a file select dialog box, to select a .CSV or .TXT containing user information.  
The user information should be formatted as follows:

firstname,lastname,unit,password
Dan,Budris,Technology,BlahdeBlah
John,Doe,Marketing,InsecurePassword

.NOTES
-- Created by Dan Budris 6/2015; find more on github.com/danbudris --

#>

=======
>>>>>>> 80a1981489e65c44ec4348b1f8a4de8efc543ce3
Param(
[string]$firstname,
[string]$lastname,
[string]$unit,
[string]$password,
[string]$batch = "false"
)##end paramter

import-module ActiveDirectory

if ($batch -eq "true"){
    Function BatchUser{

#FUNCTION TO OPEN A SELECT-FILE DIALOG BOX

Function Get-FileName($initialDirectory)
{   
 [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") |
 Out-Null

 $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
 $OpenFileDialog.initialDirectory = $initialDirectory
 $OpenFileDialog.filter = "All files (*.*)| *.*"
 $OpenFileDialog.ShowDialog() | Out-Null
 $OpenFileDialog.filename
} #end function Get-FileName

import-module ActiveDirectory #you don't need to load module in PS v 4 or later; comment this out if you have newer version of PS

$csv = Get-FileName 'C:\' #opens select file dialog

Import-Csv $csv 

$Users = $csv


foreach ($User in $Users)

{

$firstname = $User.'Firstname'

$firstinitial = $firstname.substring(0,1) #gets first initial with a substring

$lastname = $User.'Lastname'

$fullname = $firstname +" "+$lastname

$username = $firstinitial+$lastname

$userprincipal = $username+"@sample.org" # REPLACE WITH AD DOMAIN NAME

$Directory = "\\server\userdirectory\"+$username # REPLACE WITH USER HOME DIRECTORY

$password = $User.'pass'

$OU = 'OU=Users,DC=SAMPLE,DC=ORG' # REPLACE WITH OU NAME

$WhichScript= $User.'Unit'
# THE FOLLOWING LOOP DETERMINES WHICH LOGON SCRIPT TO ASSIGN, BASED ON UNIT NAME; REPLACE THIS WITH SCRIPTS, OR ELIMINATE
# IF YOU DON'T NEED THIS, ALSO REMOVE THE $script PARAMATER FORM THE FINAL COMMAND
#if ($whichScript -eq 'development')
#{
#	$script = "development_login_script.bat"
#} 
#elseif ($whichscript -eq 'communications')
#{
#	$script = "comms_login_script.bat"
#} 
#elseif ($whichscript -eq 'intern')
#{
#	$script = "intern_login_script.bat"
#	$OU = 'OU=Interns,DC=SAMPLE,DC=ORG'
#}
#else
#{
#	$script = "login_script.bat"
#} 

New-ADUser -Name $fullname -userPrincipalname $userprincipal -SamAccountName $username -GivenName $firstname -Surname $lastname -DisplayName $fullname -Path $OU -HomeDrive 'Z:' -HomeDirectory $directory -Scriptpath $script -AccountPassword (ConvertTo-SecureString $password -AsPlainText -Force) -ChangePasswordAtLogon $true -enabled $true
}

}##batchuser function end


batchuser
}
else
{

$securepassword = ConvertTo-SecureString $password -AsPlainText -Force

$firstinitial = $firstname.substring(0,1)

$fullname = $firstname +" "+$lastname

$username = $firstinitial+$lastname

$userprincipal = $username+"@sample.org" #REPLACE WITH  AD DOMAIN

$Directory = "\\Server\users\"+$username #REPLACE WITH HOME DIRECTORY

$WhichScript= $Unit

$OU = 'OU=Users,DC=SAMPLE,DC=ORG' #REPLACE WITH OU

# THE FOLLOWING LOOP DETERMINES WHICH LOGON SCRIPT TO ASSIGN, BASED ON UNIT NAME; REPLACE THIS WITH SCRIPTS, OR ELIMINATE
# IF YOU DON'T NEED THIS, ALSO REMOVE THE $script PARAMATER FORM THE FINAL COMMAND
#if ($whichScript -eq 'development')
#{
#	$script = "development_login_script.bat"
#} 
#elseif ($whichscript -eq 'communications')
#{
#	$script = "comms_login_script.bat"
#} 
#elseif ($whichscript -eq 'intern')
#{
#	$script = "intern_login_script.bat"
#	$OU = 'OU=Interns,DC=SAMPLE,DC=ORG'
#}
#else
#{
#	$script = "login_script.bat"
#} 

New-ADUser -Name $fullname -userPrincipalname $userprincipal -SamAccountName $username -GivenName $firstname -Surname $lastname -DisplayName $fullname -Path $OU -HomeDrive 'Z:' -HomeDirectory $directory -Scriptpath $script -AccountPassword $securepassword -ChangePasswordAtLogon $true -enabled $true

}
}##end function


function Active-Computers{
<<<<<<< HEAD

<#
    .SYNOPSIS
    Returns a list of enabled active directory copmuters, including their name, 
    OU, group membership, last logon date, operating system and manager.
#>

=======
>>>>>>> 80a1981489e65c44ec4348b1f8a4de8efc543ce3
get-adcomputer -Properties * -filter {enabled -eq "true"} | select -Property name,primarygroup,lastlogondate,memberof,operatingsystem,managedby | sort -Property primarygroup,memberof,name,operatingsystem,managedby
}##end fucntion


