Function Write-SSITLogs {
        [CmdletBinding()]  
        param (
            [Parameter(Mandatory=$true)]
            [ValidateSet('Application','Maintenance','Management','Security')]
            [String]$LogName,

            [Parameter(Mandatory=$false)]
            [ValidateSet('Error','Information','Warning')]
            [String]$LogType='Information',

            [Parameter(Mandatory=$true)]
            [String]$LogMessage,

            [Parameter(Mandatory=$false)]
            [Switch]$WriteToConsole,

            [Parameter(Mandatory=$false)]
            [Switch]$WriteToWindowsEventLog
        )
    
    
        begin {

            Write-Verbose "$(Get-Date -Format u) : Begin $($MyInvocation.MyCommand)"

            $LogPath = "$env:systemdrive\SSIT\Logs"
            if ( !( Test-Path -Path $LogPath ) ) {
                Set-SSITFolderStructure
            }

            $LogFile = "$logName.log"
            $Log = "$LogPath\$LogFile"
            if ( !( Test-Path $Log ) ) {
                New-Item -Path $LogPath -Name $LogFile -Type "file" | Out-Null
            }
            if ( !(Get-EventLog -LogName "Application" -Source "SSIT-$LogName" -ErrorAction SilentlyContinue ) ) {
                New-EventLog -LogName "Application" -Source "SSIT-$LogName"
            }
        }
    
        process {
            try {

                if ( $WriteToWindowsEventLog -eq $true ) {
                    Write-EventLog -LogName "Application" -Source "SSIT-$LogName" -EntryType $LogType -EventId 1337 -Message $LogMessage
                }
                
                $LogMessage =  "$(Get-Date -Format u) | $LogType : $LogMessage"
                $LogMessage | Out-File -FilePath $Log -Append -Force
                
                if ( $WriteToConsole -eq $true ) {
                    Write-Host $LogMessage -ForegroundColor Green
                }

                
            }
    
            catch {
                $errorMessage = $_.Exception.Message
                Write-Error -Message "$(Get-Date -Format u) : Error: [$errorMessage]"
            }
    
        }
    
        end {
            Write-Verbose -Message "$(Get-Date -Format u) : Ending $($MyInvocation.InvocationName)..."
        }
    }