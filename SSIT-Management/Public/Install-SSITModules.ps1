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
            Write-Verbose "$(Get-Date -Format u) : Begin $($MyInvocation.MyCommand)"
            
            $WorkingFolder = "$env:systemdrive\SSIT"
            $TempFolder = "$WorkingFolder\Temp"
            $ScriptsFolder = "$WorkingFolder\Scripts"        
            
            New-Item -ItemType Directory -Force -Path "$WorkingFolder" | Out-Null
            New-Item -ItemType Directory -Force -Path "$TempFolder" | Out-Null
            New-Item -ItemType Directory -Force -Path "$ScriptsFolder" | Out-Null
            
            $Releases = "https://api.github.com/repos/$Git/$Repo/releases"
            $Latest = (Invoke-WebRequest $Releases -UseBasicParsing | ConvertFrom-Json)[0] 
            $DownloadUrl = $Latest.zipball_url
            $ZipFile = "$TempFolder\$Repo.zip"
            $TempDirectory = "$TempFolder\$Repo"
            New-Item -ItemType Directory -Force -Path "$TempDirectory" | Out-Null
    
        }
    
        process {
            try {
                Invoke-WebRequest $DownloadUrl -Out $ZipFile
                Expand-Archive -Path $ZipFile -DestinationPath $TempDirectory -Force
                $ExpandedDirectory = "$TempDirectory\$((Get-ChildI tem $TempDirectory).Name)"
                Remove-Item $ScriptsFolder\$Repo -Recurse -Force -ErrorAction SilentlyContinue 
                New-Item -ItemType Directory -Force -Path "$ScriptsFolder\$Repo" | Out-Null
                Copy-Item -Path "$ExpandedDirectory\*" -Destination $ScriptsFolder\$Repo -Force
                Remove-Item $ZipFile -Force
                Remove-Item $TempDirectory -Recurse -Force
            }
    
            catch {
                $errorMessage = $_.Exception.Message
                Write-Error -Message "$(Get-Date -Format u) : Error: [$errorMessage]"
            }
    
        }
    
        end {
            Write-Verbose -Message "$(Get-Date -Format u) : Ending $($MyInvocation.InvocationName)..."
            return 0    
        }
    }