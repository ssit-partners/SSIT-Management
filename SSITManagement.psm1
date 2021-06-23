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
Modified from https://gist.github.com/MarkTiedemann/c0adc1701f3f5c215fc2c2d5b1d5efd3
#>

    [CmdletBinding()]  
    param (
        [Parameter(Mandatory = $True)]
        [string]$Repo,
        [Parameter(Mandatory = $True)]
        [string]$File
    )


    begin {
        Write-Verbose "$(Get-Date -Format u) : Begin $($MyInvocation.MyCommand)"
        
        Set-SSITFolderPaths
        $WorkingFolder = "$env:systemdrive\SSIT"
        $TempFolder = "$WorkingFolder\Temp"
        $ScriptsFolder = "$WorkingFolder\Scripts"
        
        $Releases = "https://api.github.com/repos/$Repo/releases"

    }

    process {
        try {

            Write-Verbose "$(Get-Date -Format u) : Determining latest release"
            $Latest = (Invoke-WebRequest $Releases -UseBasicParsing | ConvertFrom-Json)[0]
            
            $Download = $Latest.zipball_url
            $Zip = "$TempFolder\$Name-$Tag.zip"
            $Dir = "$ScriptsFolder\$Name-$Tag"
            New-Item -ItemType Directory -Force -Path "$Dir" | Out-Null
            
            Invoke-WebRequest $Download -Out $Zip            
            Expand-Archive -Path $Zip -DestinationPath $Dir
            
            # Cleaning up target dir
            Remove-Item $ScriptsFolder\$Name -Recurse -Force -ErrorAction SilentlyContinue 
            
            # Moving from temp dir to target dir
            Move-Item -Path $Dir -Destination $ScriptsFolder\$Name -Force
            
            # Removing temp files
            Remove-Item $Zip -Force
            Remove-Item $Dir -Recurse -Force

            <#
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            $response = Invoke-WebRequest "https://github.com/ssit-partners/SSIT-Management/releases/latest" -UseBasicParsing
            $url = "https://github.com/$(($response.links | Where-Object href -match 'dist.zip').href)"
                        
            $installerName = "SSIT-Management.zip"            
            $output = "$TempFolder\$installerName"

            Write-Verbose "$(Get-Date -Format u) : Downloading $url"

            $wc = New-Object System.Net.WebClient
            $wc.DownloadFile("$url", $output)   

            Write-Verbose "$(Get-Date -Format u) : Extracting $output to $ScriptsFolder"

            $shell_app = new-object -com shell.application
            $zip_file = $shell_app.namespace($output)
            $destination = $shell_app.namespace($ScriptsFolder)
            $destination.Copyhere($zip_file.items(), 0x14)

            Write-Verbose "$(Get-Date -Format u) : Fixing folder name"
            $url -Match "https://github.com//ssit-partners/SSIT-Management/archive/v(?<version>.*).zip" | Out-Null
            $version = $Matches['version']
            Get-Item -Path "$ScriptsFolder\SSIT-Management" | Remove-Item -Recurse -Force
            Rename-Item -Path "$ScriptsFolder\SSIT-Management-$version" -NewName "SSIT-Management"

            Write-Verbose "$(Get-Date -Format u) : Removing $output"
            Remove-Item -Path $output -Force
            #>

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
