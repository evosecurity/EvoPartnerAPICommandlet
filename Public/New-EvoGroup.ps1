function New-EvoGroup {
    <#
    .SYNOPSIS
        Create a new manual user group.

    .DESCRIPTION
        Creates a new manual user group via the /v1/groups endpoint.

    .PARAMETER TenantId
        The tenant ID for which the group is created.

    .PARAMETER Name
        The name of the group.

    .PARAMETER Description
        Optional description for the group.

    .PARAMETER UserIdList
        Optional list of user IDs to add as members of the group.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$TenantId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$Name,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]$Description,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string[]]$UserIdList
    )

    process {
        if (-not $PSCmdlet.ShouldProcess("Group '$Name'", 'Create')) {
            return
        }

        $body = @{
            tenantId = $TenantId
            name     = $Name
        }

        if ($PSBoundParameters.ContainsKey('Description') -and $Description) {
            $body['description'] = $Description
        }

        if ($UserIdList) {
            $body['userIds'] = $UserIdList
        }

        $response = Invoke-EvoApiRequest -Method 'POST' -Path '/v1/groups' -Body $body

        if ($null -ne $response -and $response.PSObject.Properties['data']) {
            $group = $response.data
            if ($group -is [pscustomobject]) {
                $group.PSObject.TypeNames.Insert(0, 'Evo.Group')
            }
            Write-Output $group
        }
        else {
            Write-Output $response
        }
    }
}
