function Set-EvoGroup {
    <#
    .SYNOPSIS
        Update an existing group.

    .DESCRIPTION
        Updates group properties via the /v1/groups/{id} endpoint.

    .PARAMETER Id
        The ID of the group to update.

    .PARAMETER Name
        New name for the group.

    .PARAMETER Description
        New description for the group.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('GroupId')]
        [string]$Id,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]$Name,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]$Description
    )

    process {
        $body = @{}

        if ($PSBoundParameters.ContainsKey('Name')) {
            $body['name'] = $Name
        }

        if ($PSBoundParameters.ContainsKey('Description')) {
            $body['description'] = $Description
        }

        if ($body.Count -eq 0) {
            Write-Verbose 'No updatable fields were provided.'
            return
        }

        if (-not $PSCmdlet.ShouldProcess("Group $Id", 'Update')) {
            return
        }

        $path = "/v1/groups/$Id"
        $response = Invoke-EvoApiRequest -Method 'PUT' -Path $path -Body $body

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
