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
        $progresspreference = 'silentlyContinue'
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
