function New-EvoRoleGroup {
    <#
    .SYNOPSIS
        Create a new role group.

    .DESCRIPTION
        Creates a new role group via the /v1/role_groups endpoint. The name
        must be unique per environment.

    .PARAMETER Name
        Name of the role group (must be unique per environment).

    .PARAMETER Description
        Optional description of the role group.

    .PARAMETER RoleIdList
        Array of role IDs to include in this role group (at least one required).

    .EXAMPLE
        New-EvoRoleGroup -Name 'IT Administrators' -RoleIdList @('role-id-1', 'role-id-2')

        Creates a new role group named 'IT Administrators' with the specified roles.

    .EXAMPLE
        New-EvoRoleGroup -Name 'Help Desk' -Description 'Help desk support team' -RoleIdList @('role-id-1')

        Creates a new role group with a description.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$Name,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]$Description,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('RoleIds')]
        [string[]]$RoleIdList
    )

    process {
        if (-not $PSCmdlet.ShouldProcess("Role group '$Name'", 'Create')) {
            return
        }

        $body = @{
            name    = $Name
            roleIds = $RoleIdList
        }

        if ($PSBoundParameters.ContainsKey('Description') -and $Description) {
            $body['description'] = $Description
        }

        $response = Invoke-EvoApiRequest -Method 'POST' -Path '/v1/role_groups' -Body $body

        if ($null -ne $response -and $response.PSObject.Properties['data']) {
            $rg = $response.data

            if ($rg -is [pscustomobject]) {
                $rg.PSObject.TypeNames.Insert(0, 'Evo.RoleGroup')
            }

            Write-Output $rg
        }
        else {
            Write-Output $response
        }
    }
}
