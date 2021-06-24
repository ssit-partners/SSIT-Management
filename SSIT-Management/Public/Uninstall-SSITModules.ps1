Function Uninstall-SSITModules {
    <#
    .SYNOPSIS
        Uninstall SSIT Modules
    #>
    
        [CmdletBinding()]  
        param (
        )
    
    
        begin {
            Write-Verbose "$(Get-Date -Format u) : Begin $($MyInvocation.MyCommand)"
        }
    
        process {
            try {
                Remove-Item "$env:systemdrive\SSIT\Scripts\SSIT-Management" -Recurse -Force
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