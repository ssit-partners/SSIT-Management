#requires -version 3
<#
.SYNOPSIS
Collection of functions for SmartSource IT Device Management

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
Function Install-SSITModules {
<#
.SYNOPSIS
Download latest modules from GitHub
.DESCRIPTION
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
Export-ModuleMember -Function Set-SSITFolderPaths, Install-SSITModules, Set-SSITTrustedPublisher

#-----------------------------------------------------------[Signature]------------------------------------------------------------
