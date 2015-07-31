
## This process consists of three functions; one is primrary, two are secondary. 
## Primary is UninstJava, which checks the registry for the uninstall string for Java and silently runs the uninstaller.
## Secondary are WriteLog and TestRedundant.  WriteLog writes the outcome of the process to a shared log file. 
## TestRedundant checks if the process has run previously, and if so, exits.  This is beause I have deployed this is a 
## startup script via Group Policy, and will need to let it run for serveral days in order to cover all the workstations in my
## environment.  


function WriteLog { #Writes the outcome of the process, timestamp, and computername to a text file on a share; not installed, uninstalled, or the error message.  

Param(
[string]$InstallStatus
)##end paramter

    $Date = date
    $TEXT = $env:Computername + ", " + $Date + ", " + $InstallStatus
    
    net use K: \\server\share #This ensures that we're able to write to the share.  Modify with correct server name.  
    $TEXT | add-content "K:\javalog.txt" 
    net use K: /delte #Deltes the share drives, so that users don't have it floating around to access (there is a better way)

}#END FUNCTION WRITELOG



function TestRedundant { #If the process completes, an empty text file is created in the root of the computer.
                         #When the process runs, it checks for this file and exits if it is there.  Likley better
                         #ways to acomplish this.  I'll add it to issues . 

$strFileName="C:\completed.txt"
if (Test-Path $strFileName){

exit
}

}#END FUNCTION TEST REDUNDANT



function UninstJava {

TestRedundant #This is run as a startup script with GPO; It is left on over the couse of serveral days, to hit all computers in the environment.
              #So, it is going to check for redundancy so it will exit if it has run before.  

try { #Could use better error handling


    $javaVer = Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" | get-ItemProperty| Where-Object {$_.DisplayName -match "java"}  |select-object -property DisplayName,UninstallString 

if ($javaVer -eq $null){
    
    $notinstalled = "Java not installed"
    WriteLog -InstallStatus $notinstalled
    $Completed = "Test Completed"
    New-Item C:\completed.txt -type file
    $notinstalled | add-content C:\completed.txt ##If, for some reason, the host is unable to communicate with the share the log lives on, we will have a local record of the outcome
    
    Exit
    }#END IF

ForEach ($ver in $javaVer){

If ($ver.UninstallString){

    $uninst = $ver.UninstallString
    & cmd /c $uninst /quiet /norestart

    $uninstalled = "Java Uninstalled"
    WriteLog -InstallStatus $uninstalled
    New-Item C:\completed.txt -type file
    $uninstalled | add-content C:\completed.txt
    
                } #END IF 
                
            } #END FOR
            
        }#END TRY
        
    Catch {

    WriteLog -InstallStatus $Error[0].Exception.GetType().FullNane

        }#END TRY/CATCH
        
}#END FUNCTION

UninstJava #FUNCTION IS EXECUTED
