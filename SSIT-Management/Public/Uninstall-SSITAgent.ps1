Function Install-FunctionTemplate {
    [CmdletBinding()]  
    param (
    )


    begin {
        $progresspreference = 'silentlyContinue'
        Write-SSITLogs -LogName "Management" -LogMessage "Begin $($MyInvocation.MyCommand)" -WriteToWindowsEventLog

    }

    process {
        try {

            
        }

        catch {
            $errorMessage = $_.Exception.Message
            Write-SSITLogs -LogName "Management" -LogType "Error" -LogMessage "[$errorMessage]"
            Write-Error -Message "$(Get-Date -Format u) : Error: [$errorMessage]"
        }

    }

    end {
        Write-SSITLogs -LogName "Management" -LogMessage "Ending $($MyInvocation.InvocationName)`n" -WriteToWindowsEventLog
    }
}