function Add-EvoElevatedAssignmentDomainAccount {
    <#
    .SYNOPSIS
        Add domain accounts to an elevated assignment.

    .DESCRIPTION
        Adds one or more domain accounts as members of an elevated
        assignment via /v1/elevated_assignments/{id}/domain_accounts.

    .PARAMETER ElevatedAssignmentId
        The ID of the elevated assignment.

    .PARAMETER DomainAccountIdList
        One or more domain account IDs to add to the elevated
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
        if (-not $PSCmdlet.ShouldProcess("Elevated assignment $ElevatedAssignmentId", 'Add domain accounts')) {
            return
        }

        $body = @{ domainAccountIds = $DomainAccountIdList }
        $path = "/v1/elevated_assignments/$ElevatedAssignmentId/domain_accounts"
        $response = Invoke-EvoApiRequest -Method 'POST' -Path $path -Body $body
        Write-Output $response
    }
}
