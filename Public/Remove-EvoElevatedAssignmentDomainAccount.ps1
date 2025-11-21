function Remove-EvoElevatedAssignmentDomainAccount {
    <#
    .SYNOPSIS
        Remove domain accounts from an elevated assignment.

    .DESCRIPTION
        Removes one or more domain accounts from an elevated assignment
        via /v1/elevated_assignments/{id}/domain_accounts DELETE.

    .PARAMETER ElevatedAssignmentId
        The ID of the elevated assignment.

    .PARAMETER DomainAccountIdList
        One or more domain account IDs to remove from the elevated
        assignment.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$ElevatedAssignmentId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string[]]$DomainAccountIdList
    )

    process {
        if (-not $PSCmdlet.ShouldProcess("Elevated assignment $ElevatedAssignmentId", 'Remove domain accounts')) {
            return
        }

        $body = @{ domainAccountIds = $DomainAccountIdList }
        $path = "/v1/elevated_assignments/$ElevatedAssignmentId/domain_accounts"
        $response = Invoke-EvoApiRequest -Method 'DELETE' -Path $path -Body $body
        Write-Output $response
    }
}
