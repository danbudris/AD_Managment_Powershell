function ConcatonateCSV {

<#
.Synopsis
   Combines the CSV files containing computer information into a single file
.DESCRIPTION
   When a computer shuts down, a powershell script is run that 
   1. checks if a report from the computer is already in V:\technology\compinfo
   2. if it is not, it retrives information about the computer using WMI
   3. then writes that information to a CSV in the V:\technology\compinfo directory

   This function then grabs each of those CSVs, and appends the information contine therein to a single CSV, located at V:\technology\allcompstemp.csv by default

.EXAMPLE

   ConcatonateCSV

   Simply run the command; this will produce a allcompstemp.csv by default.  Usually pair it with AddManager in order to add the managed-by attribute, and update it. 

#>

$filenames = (Get-ChildItem \\chq-cai3\company\technology\compinfo\*.csv | Select-Object -Property Name -ExpandProperty Name)

foreach ($file in $filenames){


Import-Csv -Path ("\\chq-cai3\company\technology\compinfo\" + $file) | Export-Csv -Path \\chq-cai3\company\technology\allcompstemp.csv -append

}#end foreach
}#end function

function AddManager {

<#
.Synopsis
   Adds the user who manages the device to the object properties

.DESCRIPTION
   Grabs the info from allcompstemp.csv created by ConcatonateCSV and looks up each computers 'managedby' property, converts it into a normal name, and then adds it as a property, outputting it as a CSV to V:\techonlogy\allcomps.csv by default
.EXAMPLE
    ConcatonateCSV
    AddManager
#>

$filenames = (Get-ChildItem \\chq-cai3\company\technology\compinfo\*.csv | Select-Object -Property Name -ExpandProperty Name)

foreach ($file in $filenames){

try {

$test = Import-Csv -Path ("\\chq-cai3\company\technology\compinfo\" + $file)

$compname = $test.Name

$DN = (Get-ADComputer -Filter {name -eq $compname} -Properties managedby | Select-Object -ExpandProperty managedby)

$managedby = (Get-ADUser -Filter {distinguishedname -eq $DN} | Select-Object -ExpandProperty Name)

}#end try
catch
{
$managedby = ""
}#end catch

$test | Add-Member -NotePropertyName ManagedBy -NotePropertyValue $managedby


$test | Export-Csv -Path \\chq-cai3\company\technology\allcomps.csv -Append

finally
{
"Updated!"
}#end finally
}#end foreach
}#end function

function CleanData {

<#
.Synopsis
  Cleans the data in allcomps.csv created by AddManager and Concatonate CSV
.DESCRIPTION
   Removes the weird formatting resulting from how the data is collected.  This step could be eliminated by refining the WMI query and the script that collects the data, but this will do for now.
#>

$data = Get-Content \\chq-cai3\Company\Technology\allcomps.csv 

 ForEach-Object {
    
    $data -replace "\Drives","" `
    -replace "\------",""
       
    } | Set-Content \\chq-cai3\Company\Technology\allcomps.csv


    }#end function

function ProduceComputerReport{

    <#
.Synopsis
   Takes all the steps to produce the all computer stats report
.DESCRIPTION
   Concatonates the CSVs in V:\technology\compinfo, queryies AD for the manager and adds it as a property, cleans up the formatting of the data, and saves it all as V:\technology\allcomps.csv
.EXAMPLE
    ProduceComputerReport

   right now this has no paramaters, but I guess it could be updated...

  
#>

    ConcatonateCSV

    AddManager

    Remove-Item V:\Technology\allcompstemp.csv

    CleanData
    
}#end function
