function New-EvoRbacRole {
    <#
    .SYNOPSIS
        Create a new RBAC v2 role.

    .DESCRIPTION
        Creates a role via the /v1/rbac_roles endpoint. Grants are expressed as
        catalog keys in three buckets (permissions, categories, groups) rather
        than the flat role id list the legacy New-EvoRoleGroup uses. Use
        Get-EvoPermissionCatalog to discover category and permission group keys.

        A role with no grants is a valid state, so grants are optional.

    .PARAMETER Name
        Name of the role (must be unique per environment).

    .PARAMETER Description
        Optional description of the role.

    .PARAMETER Namespace
        Optional product namespace (admin_portal or mobile). Defaults server-side.

    .PARAMETER PermissionKeyList
        Individual permission keys to grant.

    .PARAMETER CategoryKeyList
        Category keys to grant in full, including permissions added later.

    .PARAMETER GroupKeyList
        Permission group keys to grant in full.

    .PARAMETER Grants
        Full grants hashtable, for callers that want to pass the API shape
        directly, e.g. @{ permissions = @('view_dashboard'); categories = @('billing') }.

    .EXAMPLE
        New-EvoRbacRole -Name 'Read Only' -PermissionKeyList @('view_dashboard','view_computers')

        Creates a role granting two individual permissions.

    .EXAMPLE
        New-EvoRbacRole -Name 'Billing Admin' -CategoryKeyList @('billing') -Description 'Owns billing'

        Creates a role granting an entire category.

    .EXAMPLE
        New-EvoRbacRole -Name 'Custom' -Grants @{ permissions = @('view_keys'); groups = @('manage_keys') }

        Creates a role using the raw grants shape.
    #>
    [CmdletBinding(SupportsShouldProcess = $true, DefaultParameterSetName = 'Keys')]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$Name,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]$Description,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateSet('admin_portal','mobile')]
        [string]$Namespace,

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
        [hashtable]$Grants
    )

    process {
        if (-not $PSCmdlet.ShouldProcess("RBAC role '$Name'", 'Create')) {
            return
        }

        $body = @{
            name = $Name
        }

        if ($PSBoundParameters.ContainsKey('Description') -and $Description) {
            $body['description'] = $Description
        }

        if ($PSBoundParameters.ContainsKey('Namespace') -and $Namespace) {
            $body['namespace'] = $Namespace
        }

        $grantPayload = ConvertTo-EvoRbacGrant -Grants $Grants `
            -PermissionKeyList $PermissionKeyList `
            -CategoryKeyList $CategoryKeyList `
            -GroupKeyList $GroupKeyList

        if ($null -ne $grantPayload) {
            $body['grants'] = $grantPayload
        }

        $response = Invoke-EvoApiRequest -Method 'POST' -Path '/v1/rbac_roles' -Body $body

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
