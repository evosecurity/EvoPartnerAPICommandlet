function Remove-EvoUser {
    <#
    .SYNOPSIS
        Delete an Evo user by ID.

    .DESCRIPTION
        Deletes a user via the Evo Partner API /v1/users/{id} endpoint.
        Returns the API's operation result.

    .PARAMETER Id
        The ID of the user to delete.

    .EXAMPLE
        Remove-EvoUser -Id '00000000-0000-0000-0000-000000000000' -Confirm:$false

        Deletes the specified user without confirmation.
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('UserId')]
        [string]$Id
    )

    process {
        if (-not $PSCmdlet.ShouldProcess("User $Id", 'Delete')) {
            return
        }

        $path = "/v1/users/$Id"
        $response = Invoke-EvoApiRequest -Method 'DELETE' -Path $path
        Write-Output $response
    }
}
