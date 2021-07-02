    Function Install-SSITAgent {
        [CmdletBinding()]  
        param (
            [Parameter(Mandatory = $false)]
            [Int]$LocationID,
    
            [Parameter(Mandatory = $false)]
            [Switch]$NoGUI = $false
        )
    
    
        begin {
            $ProgressPreference = 'silentlyContinue'
            $LogName = "Application"
            Write-SSITLogs -LogName $LogName -LogMessage "Begin $($MyInvocation.MyCommand)" -WriteToWindowsEventLog
        }
    
        process {
            try {
                $InstallFile = Get-SSITSoftwareFromUrl -Url "https://github.com/ssit-partners/SSIT-Management/archive/refs/tags/v0.6-alpha.zip"
                $InstallFile
                
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