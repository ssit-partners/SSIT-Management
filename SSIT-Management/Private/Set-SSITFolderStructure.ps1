function Set-SSITFolderStructure {

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
                Write-Verbose "$(Get-Date -Format u) : Creating Folder: $Path"
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
    }

}
