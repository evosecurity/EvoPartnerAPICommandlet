function Remove-EvoGroup {
    <#
    .SYNOPSIS
        Delete a group by ID.

    .DESCRIPTION
        Deactivates a manual user group via the /v1/groups/{id} DELETE
        endpoint.

    .PARAMETER Id
        The ID of the group to delete.
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('GroupId')]
        [string]$Id
    )

    process {
        if (-not $PSCmdlet.ShouldProcess("Group $Id", 'Delete')) {
            return
        }

        $path = "/v1/groups/$Id"
        $response = Invoke-EvoApiRequest -Method 'DELETE' -Path $path
        Write-Output $response
    }
}
