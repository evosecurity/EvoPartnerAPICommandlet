function Get-EvoLocalAdminAccountPasswordRotation {
    <#
    .SYNOPSIS
        Get password rotation details.

    .DESCRIPTION
        Retrieves details of a specific password rotation via the
        /v1/local_admin_accounts/password_rotations/{id} endpoint.

    .PARAMETER Id
        The ID of the password rotation to retrieve.

    .EXAMPLE
        Get-EvoLocalAdminAccountPasswordRotation -Id 'rotation-id'

        Retrieves details of the specified password rotation.

    .EXAMPLE
        $result = New-EvoLocalAdminAccountPasswordRotation -LocalAdminAccountIdList @('account-id-1', 'account-id-2')
        $operation = Get-EvoAsyncOperation -Id $result.operationId
        $rotations = $operation.result.passwordRotations
        Get-EvoLocalAdminAccountPasswordRotation -Id $rotations[0].id

        Creates password rotations for multiple local admin accounts. Once the
        async operation completes, the result contains a passwordRotations array
        with one entry per account. Use the id from each entry to retrieve details.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('PasswordRotationId', 'RotationId')]
        [string]$Id
    )

    process {
        $path = "/v1/local_admin_accounts/password_rotations/$Id"
        $response = Invoke-EvoApiRequest -Method 'GET' -Path $path

        if ($response.data) {
            $rotation = $response.data

            if ($rotation -is [pscustomobject]) {
                $rotation.PSObject.TypeNames.Insert(0, 'Evo.PasswordRotation')
            }

            Write-Output $rotation
        }
        else {
            Write-Output $response
        }
    }
}
