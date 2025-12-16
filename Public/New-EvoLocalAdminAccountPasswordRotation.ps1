function New-EvoLocalAdminAccountPasswordRotation {
    <#
    .SYNOPSIS
        Trigger immediate password rotation for local admin accounts.

    .DESCRIPTION
        Manually triggers immediate password rotation for one or more local
        admin accounts via the /v1/local_admin_accounts/password_rotations
        endpoint. This is for immediate, one-time rotations. For scheduled
        password rotations, use the password rotation config cmdlets instead.

    .PARAMETER LocalAdminAccountIdList
        Array of local admin account IDs to rotate passwords for.

    .EXAMPLE
        New-EvoLocalAdminAccountPasswordRotation -LocalAdminAccountIdList @('account-id-1', 'account-id-2')

        Triggers password rotation for the specified accounts.

    .EXAMPLE
        $accounts = Get-EvoLocalAdminAccount -TenantIdList @('tenant-id')
        New-EvoLocalAdminAccountPasswordRotation -LocalAdminAccountIdList $accounts.id

        Triggers password rotation for all accounts in a tenant.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('LocalAdminAccountIds', 'Ids')]
        [string[]]$LocalAdminAccountIdList
    )

    process {
        if (-not $PSCmdlet.ShouldProcess("$($LocalAdminAccountIdList.Count) local admin account(s)", 'Trigger password rotation')) {
            return
        }

        $body = @{
            localAdminAccountIds = $LocalAdminAccountIdList
        }

        $response = Invoke-EvoApiRequest -Method 'POST' -Path '/v1/local_admin_accounts/password_rotations' -Body $body

        if ($null -ne $response -and $response.PSObject.Properties['data']) {
            $result = $response.data

            if ($result -is [pscustomobject]) {
                $result.PSObject.TypeNames.Insert(0, 'Evo.PasswordRotationRequest')
            }

            # Attach failed items if present
            if ($response.PSObject.Properties['failedItems'] -and $response.failedItems) {
                $result | Add-Member -NotePropertyName 'FailedItems' -NotePropertyValue $response.failedItems -Force

                $failedCount = @($response.failedItems).Count
                if ($failedCount -gt 0) {
                    Write-Warning "$failedCount account(s) failed validation for password rotation."
                    foreach ($fi in $response.failedItems) {
                        if ($fi.localAdminAccountId -and $fi.error) {
                            Write-Warning "  $($fi.localAdminAccountId): $($fi.error)"
                        }
                    }
                }
            }

            Write-Output $result
        }
        else {
            Write-Output $response
        }
    }
}
