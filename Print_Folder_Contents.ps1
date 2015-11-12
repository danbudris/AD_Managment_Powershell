 [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null
    $input = [Microsoft.VisualBasic.Interaction]::InputBox("Enter the Full Path; all .doc, .docx, .pdf, .ppt, and .pptx files in the folder will be printed to your default printer") 
    
 
  
    try {
    
    $files = get-childitem ($input) -ErrorAction stop
    
    ForEach ($file in $files){
    
        if ($file -like "*.pdf")
            {
            
            Start-Process -FilePath $file.FullName –Verb Print 
            
            "Printing $file.FullName"
            
            }##END LIKE PDF
        
        elseif ($file -like "*.doc*")
            {
                       
            $objWord = New-Object -comobject Word.Application  
            $objDoc = $objWord.Documents.Open($file.FullName) 
            $objDoc.PrintOut() 
            $a = $objWord.Quit()
          
            "Printing $file.FullName"
          
            }##END LIKE DOC
        
        elseif ($file -like "*.ppt*")
            {
            
            Add-type -AssemblyName office
            Add-Type -AssemblyName microsoft.office.interop.powerpoint
            $outputType = "microsoft.office.interop.powerpoint.ppPrintOutputType" -as [type]
            $Application = New-Object -ComObject powerpoint.application
            $application.visible = [Microsoft.Office.Core.MsoTriState]::msoTrue
            $presentation = $application.Presentations.open($file.fullname)
            $printOptions = $presentation.printoptions
            $printoptions.outputType = $outputType::ppPrintOutputTwoSlideHandouts            
            $printOptions.FitToPage = $true
            $printOptions.NumberOfCopies = 1
            $presentation.PrintOut() ManualDuplexPrint = true
            $presentation.Close()

            "Printing $file.FullName"

            $application.quit()
            $application = $null
            [gc]::collect()
            [gc]::WaitForPendingFinalizers()
                                  
            }##END LIKE PPT
    
    }##END FILE FOREACH
    }#end try
    catch [system.exception]
    {
Write-Host "There was an error; was the path correct? Press any key to exit" -foregroundcolor red

$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

Write-Host
Write-Host "A"
Write-Host "B"
Write-Host "C"
    }##END CATCH
  
    
