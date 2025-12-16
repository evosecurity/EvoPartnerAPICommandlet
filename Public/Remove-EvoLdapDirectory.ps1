function Remove-EvoLdapDirectory {
    <#
    .SYNOPSIS
        Delete an LDAP Directory by ID.

    .DESCRIPTION
        Deletes an LDAP Directory via the /v1/ldap_directories/{id} endpoint.
        The deletion is processed asynchronously. Returns an async operation
        that can be tracked using Get-EvoAsyncOperation.

    .PARAMETER Id
        The ID of the LDAP Directory to delete.

    .EXAMPLE
        Remove-EvoLdapDirectory -Id "12345678-1234-1234-1234-123456789012"

    .EXAMPLE
        Get-EvoLdapDirectory | Where-Object { $_.name -eq "OldDirectory" } | Remove-EvoLdapDirectory
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('DirectoryId')]
        [string]$Id
    )

    process {
        if (-not $PSCmdlet.ShouldProcess("LDAP Directory $Id", 'Delete')) {
            return
        }

        $path = "/v1/ldap_directories/$Id"
        $response = Invoke-EvoApiRequest -Method 'DELETE' -Path $path

        if ($null -ne $response -and $response.PSObject.Properties['data']) {
            $operation = $response.data

            if ($operation -is [pscustomobject]) {
                $operation.PSObject.TypeNames.Insert(0, 'Evo.AsyncOperation')
            }

            Write-Output $operation
        }
        else {
            Write-Output $response
        }
    }
}
