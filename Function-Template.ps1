Function Install-FunctionTemplate {
    [CmdletBinding()]  
    param (
    )


    begin {
        $ProgressPreference = 'silentlyContinue'
        $LogName = "Application"
        Write-SSITLogs -LogName $LogName -LogMessage "Begin $($MyInvocation.MyCommand)" -WriteToWindowsEventLog

    }

    process {
        try {

            
        }

        catch {
            $errorMessage = $_.Exception.Message
            Write-SSITLogs -LogName $LogName -LogType "Error" -LogMessage "[$errorMessage]"
            Write-Error -Message "$(Get-Date -Format u) : Error: [$errorMessage]"
        }

    }

    end {
        Write-SSITLogs -LogName $LogName -LogMessage "Ending $($MyInvocation.InvocationName)`n" -WriteToWindowsEventLog
    }
}