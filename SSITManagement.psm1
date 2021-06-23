#requires -version 3
<#
.SYNOPSIS
Collection of functions to for SmartSource IT Device Management

.DESCRIPTION
Developed for RealPage SmartSource IT 

.NOTES
None

#>

#-----------------------------------------------------------[Functions]------------------------------------------------------------

Function Set-SSITFolderPaths {
    <#
    .SYNOPSIS
      Checks and creates standard folder structure for SmartSource IT Managed Devices

    .EXAMPLE
    Set-SSITFolderPaths
    #>

    [CmdletBinding()]  
    param (
    )

    begin {
        Write-Verbose "$(Get-Date -Format u) : Begin $($MyInvocation.MyCommand)"

        $FolderPaths = @(
            "$env:systemdrive\SSIT",
            "$env:systemdrive\SSIT\Utilities",
            "$env:systemdrive\SSIT\Temp",
            "$env:systemdrive\SSIT\Scripts",
            "$env:systemdrive\SSIT\Software",
            "$env:systemdrive\SSIT\Logs"
        )

    }

    process {
        try {
            Foreach ( $Path in $FolderPaths ) {
                New-Item -ItemType Directory -Force -Path "$Path" | Out-Null
            }
        }

        catch {
            $ErrorMessage = $_.Exception.Message
            Write-Error -Message "$(Get-Date -Format u) : Error: [$ErrorMessage]"
        }

    }

    end {
        Write-Verbose -Message "$(Get-Date -Format u) : Ending $($MyInvocation.InvocationName)..."
        return 0    
    }
}
Function Get-SSITModules {
    <#
    .SYNOPSIS
      Download latest modules from GitHub
    .DESCRIPTION
      Download latest modules from GitHub

    .EXAMPLE
    Get-SSITModules
    #>

    [CmdletBinding()]  
    param (
    )

    begin {
        Write-Verbose "$(Get-Date -Format u) : Begin $($MyInvocation.MyCommand)"


    }

    process {
        try {
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            $response = Invoke-WebRequest "https://github.com/ssit-partners/SmartSourceIT-EUS-Agent/releases/latest" -UseBasicParsing
            $url = "https://github.com/$(($response.links | Where-Object href -match 'dist.zip').href)"
            
            $installerName = "SSIT-Management.zip"            
            $output = "$env:temp\$installerName"

            Write-Verbose "$(Get-Date -Format u) : Downloading $url"

            $wc = New-Object System.Net.WebClient
            $wc.DownloadFile("$url", $output)   

            Write-Verbose "$(Get-Date -Format u) : Extracting $output to $env:systemdrive\GXA\Scripts"

            New-Item -ItemType Directory -Force -Path "$env:systemdrive\GXA\Scripts" | Out-Null
            $shell_app = new-object -com shell.application
            $zip_file = $shell_app.namespace($output)
            $destination = $shell_app.namespace("$env:systemdrive\GXA\Scripts")
            $destination.Copyhere($zip_file.items(), 0x14)

            Write-Verbose "$(Get-Date -Format u) : Fixing folder name"
            $url -Match "https://github.com//GXANetworks/GXA_Managed_Tools/archive/v(?<version>.*).zip" | Out-Null
            $version = $Matches['version']
            Get-Item -Path "$env:systemdrive\GXA\Scripts\GXA_Managed_Tools" | Remove-Item -Recurse -Force
            Rename-Item -Path "$env:systemdrive\GXA\Scripts\GXA_Managed_Tools-$version" -NewName "GXA_Managed_Tools"

            Write-Verbose "$(Get-Date -Format u) : Removing $output"
            Remove-Item -Path $output -Force

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
Function Set-SSITTrustedPublisher {
    <#
    .SYNOPSIS
      Pull certificate from signed file and add to Trusted Publishers
    .DESCRIPTION
      Pull certificate from signed file and add to Trusted Publishers

    .INPUTS None
    .OUTPUTS Array
    .NOTES
      Version:        1.0
      Author:         Rusty Franks
      Creation Date:  20180513
      Purpose/Change: Initial script development
    .EXAMPLE
    #>

    [CmdletBinding()]  
    param (
        [Parameter(Mandatory = $true)][String]$FilePath = ""
    )

    begin {
        Write-Verbose "$(Get-Date -Format u) : Begin $($MyInvocation.MyCommand)"
        $Cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
        $Cert.Import((((Get-AuthenticodeSignature "$FilePath").SignerCertificate).Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Cert)))
        $store = Get-Item "cert:\LocalMachine\TrustedPublisher"


    }

    process {
        try {
            $store.Open([System.Security.Cryptography.X509Certificates.OpenFlags]"ReadWrite")
            $store.Add($Cert)
            $store.Close()
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

#-----------------------------------------------------------[Module Export]------------------------------------------------------------
Export-ModuleMember -Function Set-SSITFolderPaths, Get-SSITModules, Set-SSITTrustedPublisher

#-----------------------------------------------------------[Signature]------------------------------------------------------------
