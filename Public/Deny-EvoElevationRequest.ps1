function Deny-EvoElevationRequest {
    <#
    .SYNOPSIS
        Deny a pending End-User Elevation (EUE) request.

    .DESCRIPTION
        Queues denial of an elevation request via /v1/elevation_requests/{id}/deny.
        The operation is asynchronous and returns an operation ID; poll it with
        Get-EvoAsyncOperation. The resolver is recorded as the denier, exactly as in
        the portal, and must be an active admin who holds the manage_elevation_requests
        permission and has access to the tenant.

        Requires an API key with the canManageElevationRequests scope.

    .PARAMETER Id
        The ID of the elevation request.

    .PARAMETER TenantId
        The tenant the request belongs to.

    .PARAMETER ResolverId
        The ID of the user recorded as the denier.

    .PARAMETER FindingsReason
        Reason recorded on the resolution and in the audit log.

    .PARAMETER SuppressEndUserNotification
        Do not notify the end user of the outcome.

    .EXAMPLE
        Deny-EvoElevationRequest -Id 'er_01HAYTFG4CRA6FVCFMJQYCP2SM' -TenantId 'tenant-id' -ResolverId 'resolver-user-id' -FindingsReason 'Not approved software'

        Denies one request.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [Alias('ElevationRequestId')]
        [string]$Id,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$TenantId,

        [Parameter(Mandatory = $true)]
        [string]$ResolverId,

        [Parameter()]
        [string]$FindingsReason,

        [Parameter()]
        [switch]$SuppressEndUserNotification
    )

    process {
        if (-not $PSCmdlet.ShouldProcess("Elevation request $Id", 'Deny')) {
            return
        }

        $body = @{
            tenantId   = $TenantId
            resolverId = $ResolverId
        }

        if ($FindingsReason) { $body['findingsReason'] = $FindingsReason }
        if ($SuppressEndUserNotification.IsPresent) { $body['suppressEndUserNotification'] = $true }

        $response = Invoke-EvoApiRequest -Method 'POST' -Path "/v1/elevation_requests/$Id/deny" -Body $body

        if ($null -ne $response -and $response.PSObject.Properties['data']) {
            Write-Output $response.data
        }
        else {
            Write-Output $response
        }
    }
}
