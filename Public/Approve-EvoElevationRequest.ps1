function Approve-EvoElevationRequest {
    <#
    .SYNOPSIS
        Approve a pending End-User Elevation (EUE) request.

    .DESCRIPTION
        Queues approval of an elevation request via /v1/elevation_requests/{id}/approve.
        The operation is asynchronous and returns an operation ID; poll it with
        Get-EvoAsyncOperation. The resolver is recorded as the approver, exactly as in
        the portal, and must be an active admin who holds the manage_elevation_requests
        permission and has access to the tenant. -ExecutionMode system and -BypassUac
        also require the resolver to hold utilize_system_level_elevations.

        Requires an API key with the canManageElevationRequests scope.

    .PARAMETER Id
        The ID of the elevation request.

    .PARAMETER TenantId
        The tenant the request belongs to.

    .PARAMETER ResolverId
        The ID of the user recorded as the approver.

    .PARAMETER FindingsReason
        Reason recorded on the resolution and in the audit log.

    .PARAMETER ExecutionMode
        How the approved process runs: user, admin, or system.

    .PARAMETER BypassUac
        Skip the UAC prompt on the endpoint.

    .PARAMETER SuppressEndUserNotification
        Do not notify the end user of the outcome.

    .EXAMPLE
        Get-EvoElevationRequest -State pending |
            Where-Object { $_.executable.publisher -eq 'Microsoft Corporation' } |
            Approve-EvoElevationRequest -ResolverId 'resolver-user-id' -FindingsReason 'Signed by Microsoft'

        Approves every pending request for a Microsoft-signed executable.

    .EXAMPLE
        $op = Approve-EvoElevationRequest -Id 'er_01HAYTFG4CRA6FVCFMJQYCP2SM' -TenantId 'tenant-id' -ResolverId 'resolver-user-id' -ExecutionMode admin
        Get-EvoAsyncOperation -Id $op.operationId

        Approves one request to run as admin and checks the outcome.
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
        [ValidateSet('user', 'admin', 'system')]
        [string]$ExecutionMode,

        [Parameter()]
        [switch]$BypassUac,

        [Parameter()]
        [switch]$SuppressEndUserNotification
    )

    process {
        if (-not $PSCmdlet.ShouldProcess("Elevation request $Id", 'Approve')) {
            return
        }

        $body = @{
            tenantId   = $TenantId
            resolverId = $ResolverId
        }

        if ($FindingsReason) { $body['findingsReason'] = $FindingsReason }
        if ($ExecutionMode) { $body['executionMode'] = $ExecutionMode }
        if ($BypassUac.IsPresent) { $body['bypassUac'] = $true }
        if ($SuppressEndUserNotification.IsPresent) { $body['suppressEndUserNotification'] = $true }

        $response = Invoke-EvoApiRequest -Method 'POST' -Path "/v1/elevation_requests/$Id/approve" -Body $body

        if ($null -ne $response -and $response.PSObject.Properties['data']) {
            Write-Output $response.data
        }
        else {
            Write-Output $response
        }
    }
}
