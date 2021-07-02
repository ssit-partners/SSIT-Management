Function Install-SSITModules {
    <#
    .SYNOPSIS
    Download latest modules from GitHub
    .NOTES
    Download latest modules from GitHub
    Modified from https://gist.github.com/MarkTiedemann/c0adc1701f3f5c215fc2c2d5b1d5efd3
    #>
    
        [CmdletBinding()]  
        param (
            [Parameter(Mandatory = $False)]
            [string]$Git="ssit-partners",
            [Parameter(Mandatory = $False)]
            [string]$Repo="SSIT-Management"
        )
    
    
        begin {
            $progresspreference = 'silentlyContinue'
            Write-SSITLogs -LogName "Management" -LogMessage "Begin $($MyInvocation.MyCommand)" -WriteToWindowsEventLog

            Set-SSITFolderStructure
            
            $WorkingFolder = "$env:systemdrive\SSIT"
            $TempFolder = "$WorkingFolder\Temp"
            $ScriptsFolder = "$WorkingFolder\Scripts"        
            
            $Releases = "https://api.github.com/repos/$Git/$Repo/releases"
            $Latest = (Invoke-WebRequest $Releases -UseBasicParsing | ConvertFrom-Json)[0] 
            $DownloadUrl = $Latest.zipball_url
            $ZipFile = "$TempFolder\$Repo.zip"
            $TempDirectory = "$TempFolder\$Repo"
            New-Item -ItemType Directory -Force -Path "$TempDirectory" | Out-Null
    
        }
    
        process {
            try {
                Write-SSITLogs -LogName "Management" -LogMessage "Downloading $DownloadUrl to $ZipFile"
                Invoke-WebRequest $DownloadUrl -Out $ZipFile

                Write-SSITLogs -LogName "Management" -LogMessage "Expanding: $ZipFile"
                Expand-Archive -Path $ZipFile -DestinationPath $TempDirectory -Force
                $ExpandedDirectory = "$TempDirectory\$((Get-ChildItem $TempDirectory).Name)"
                
                Write-SSITLogs -LogName "Management" -LogMessage "Preparing Folder Structure at $ScriptsFolder\$Repo"
                Remove-Item $ScriptsFolder\$Repo -Recurse -Force -ErrorAction SilentlyContinue 
                New-Item -ItemType Directory -Force -Path "$ScriptsFolder\$Repo" | Out-Null
                
                Write-SSITLogs -LogName "Management" -LogMessage "Copying Contents"
                Copy-Item -Path "$ExpandedDirectory\*" -Destination $ScriptsFolder\$Repo -Force -Recurse

                Write-SSITLogs -LogName "Management" -LogMessage "Cleaning up temp files"
                Remove-Item $ZipFile -Force
                Remove-Item $TempDirectory -Recurse -Force
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