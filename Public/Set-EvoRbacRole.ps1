function Set-EvoRbacRole {
    <#
    .SYNOPSIS
        Update an existing RBAC v2 role.

    .DESCRIPTION
        Updates a role via the /v1/rbac_roles/{id} endpoint. Only the supplied
        properties are sent; grants are replaced wholesale when provided.

        Built-in (stock) roles are not editable and the API rejects updates to
        them; their assignments can still be changed.

    .PARAMETER Id
        ID (selector UUID) of the role to update.

    .PARAMETER Name
        New name for the role.

    .PARAMETER Description
        New description for the role.

    .PARAMETER PermissionKeyList
        Replacement set of individual permission keys.

    .PARAMETER CategoryKeyList
        Replacement set of category keys.

    .PARAMETER GroupKeyList
        Replacement set of permission group keys.

    .PARAMETER Grants
        Full replacement grants hashtable, e.g.
        @{ permissions = @('view_dashboard'); categories = @('billing') }.

    .PARAMETER ClearGrant
        Remove every grant from the role, leaving it with no access. Sends an
        empty grants object, which the API treats as "clear".

    .EXAMPLE
        Set-EvoRbacRole -Id $role.id -Name 'Updated Name'

        Renames a role, leaving its grants untouched.

    .EXAMPLE
        Set-EvoRbacRole -Id $role.id -CategoryKeyList @('billing','dashboard')

        Replaces the role's grants with two whole categories.

    .EXAMPLE
        Set-EvoRbacRole -Id $role.id -ClearGrant

        Removes all grants from the role.
    #>
    [CmdletBinding(SupportsShouldProcess = $true, DefaultParameterSetName = 'Keys')]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('RbacRoleId')]
        [string]$Id,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]$Name,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]$Description,

        [Parameter(ParameterSetName = 'Keys', ValueFromPipelineByPropertyName = $true)]
        [Alias('PermissionKeys')]
        [string[]]$PermissionKeyList,

        [Parameter(ParameterSetName = 'Keys', ValueFromPipelineByPropertyName = $true)]
        [Alias('CategoryKeys')]
        [string[]]$CategoryKeyList,

        [Parameter(ParameterSetName = 'Keys', ValueFromPipelineByPropertyName = $true)]
        [Alias('GroupKeys')]
        [string[]]$GroupKeyList,

        [Parameter(ParameterSetName = 'Grants', Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [hashtable]$Grants,

        [Parameter(ParameterSetName = 'ClearGrants', Mandatory = $true)]
        [switch]$ClearGrant
    )

    process {
        if (-not $PSCmdlet.ShouldProcess("RBAC role '$Id'", 'Update')) {
            return
        }

        $body = @{}

        if ($PSBoundParameters.ContainsKey('Name') -and $Name) {
            $body['name'] = $Name
        }

        if ($PSBoundParameters.ContainsKey('Description')) {
            $body['description'] = $Description
        }

        if ($ClearGrant) {
            $body['grants'] = @{}
        }
        else {
            $grantPayload = ConvertTo-EvoRbacGrant -Grants $Grants `
                -PermissionKeyList $PermissionKeyList `
                -CategoryKeyList $CategoryKeyList `
                -GroupKeyList $GroupKeyList

            if ($null -ne $grantPayload) {
                $body['grants'] = $grantPayload
            }
        }

        if ($body.Count -eq 0) {
            throw 'Nothing to update. Supply at least one of -Name, -Description, grant keys, -Grants or -ClearGrant.'
        }

        $response = Invoke-EvoApiRequest -Method 'PUT' -Path "/v1/rbac_roles/$Id" -Body $body

        if ($null -ne $response -and $response.PSObject.Properties['data']) {
            $role = $response.data

            if ($role -is [pscustomobject]) {
                $role.PSObject.TypeNames.Insert(0, 'Evo.RbacRole')
            }

            Write-Output $role
        }
        else {
            Write-Output $response
        }
    }
}
