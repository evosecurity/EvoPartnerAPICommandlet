function Set-EvoRoleGroup {
    <#
    .SYNOPSIS
        Update an existing role group.

    .DESCRIPTION
        Updates a role group via the /v1/role_groups/{id} endpoint. Only
        properties explicitly provided are updated. The cmdlet fetches the
        current role group state and merges your changes before updating.

    .PARAMETER Id
        The ID of the role group to update.

    .PARAMETER Name
        Name of the role group (must be unique per environment).

    .PARAMETER Description
        Description of the role group.

    .PARAMETER RoleIdList
        Array of role IDs to include in this role group.

    .EXAMPLE
        Set-EvoRoleGroup -Id 'role-group-id' -Name 'Updated Name'

        Updates only the role group name.

    .EXAMPLE
        Set-EvoRoleGroup -Id 'role-group-id' -Description 'New description'

        Updates only the role group description.

    .EXAMPLE
        Set-EvoRoleGroup -Id 'role-group-id' -RoleIdList @('role-id-1', 'role-id-2')

        Updates only the roles in the role group.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('RoleGroupId')]
        [string]$Id,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]$Name,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [AllowNull()]
        [AllowEmptyString()]
        [string]$Description,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('RoleIds')]
        [string[]]$RoleIdList
    )

    process {
        # Check if any updatable fields were provided
        $hasUpdates = $PSBoundParameters.ContainsKey('Name') -or
                      $PSBoundParameters.ContainsKey('Description') -or
                      $PSBoundParameters.ContainsKey('RoleIdList')

        if (-not $hasUpdates) {
            Write-Verbose 'No updatable fields were provided.'
            return
        }

        if (-not $PSCmdlet.ShouldProcess("Role group $Id", 'Update')) {
            return
        }

        # Fetch current role group to get existing values
        $getPath = "/v1/role_groups/$Id"
        $currentResponse = Invoke-EvoApiRequest -Method 'GET' -Path $getPath

        if ($null -eq $currentResponse -or -not $currentResponse.PSObject.Properties['data']) {
            Write-Error "Failed to retrieve role group $Id"
            return
        }

        $current = $currentResponse.data

        # Build body with current values, then override with provided values
        $body = @{
            name    = $current.name
            roleIds = @($current.roles | ForEach-Object { $_.id })
        }

        # Include current description if it exists
        if ($current.PSObject.Properties['description']) {
            $body['description'] = $current.description
        }

        # Override with provided values
        if ($PSBoundParameters.ContainsKey('Name')) {
            $body['name'] = $Name
        }

        if ($PSBoundParameters.ContainsKey('Description')) {
            $body['description'] = $Description
        }

        if ($PSBoundParameters.ContainsKey('RoleIdList')) {
            $body['roleIds'] = $RoleIdList
        }

        $path = "/v1/role_groups/$Id"
        $response = Invoke-EvoApiRequest -Method 'PUT' -Path $path -Body $body

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
