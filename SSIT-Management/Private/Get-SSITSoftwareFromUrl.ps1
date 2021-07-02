Function Get-SSITSoftwareFromUrl {
    [CmdletBinding()]  
    param (
        [Parameter(Mandatory = $true)]
        [String]$Url
    )


    begin {
        $progresspreference = 'silentlyContinue'
        $LogName = "Application"
        Write-SSITLogs -LogName $LogName -LogMessage "Begin $($MyInvocation.MyCommand)" -WriteToWindowsEventLog
        $TempFolder = "$env:systemdrive\SSIT\Temp"
        $FileName = Split-Path -Path $Url -Leaf

    }

    process {
        try {

            Write-SSITLogs -LogName $LogName -LogMessage "Downloading $Url to $TempFolder"
    
            $wc = New-Object System.Net.WebClient
            $wc.DownloadFile($Url, "$TempFolder\$FileName")    
            
        }

        catch {
            $errorMessage = $_.Exception.Message
            Write-SSITLogs -LogName $LogName -LogType "Error" -LogMessage "[$errorMessage]"
            Write-Error -Message "$(Get-Date -Format u) : Error: [$errorMessage]"
        }

    }

    end {
        return "$TempFolder\$FileName"
        Write-SSITLogs -LogName $LogName -LogMessage "Ending $($MyInvocation.InvocationName)`n" -WriteToWindowsEventLog
    }
}