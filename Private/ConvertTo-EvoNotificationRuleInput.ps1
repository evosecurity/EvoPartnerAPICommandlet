function ConvertTo-EvoNotificationRuleInput {
    <#
    .SYNOPSIS
        Add a writable recipient_spec to a notification rule returned by the API.

    .DESCRIPTION
        GET /v1/notification-type-rules returns recipients resolved
        (recipient_lists), while PATCH takes recipient_spec with the same
        public ids. This adds recipient_spec to the rule so it can be sent
        back unchanged.

        The GET still lists recipients and tenants that no longer exist, and
        the PATCH rejects them with 400 "Not found in this environment", so
        they are left out:
        - users, groups and roles whose id is null (deleted)
        - role groups whose name is null (deleted; the uuid is still shown)
        - tenants that are null (deleted) or not in -ActiveTenantIds (deactivated)

        A rule left with no recipients, or scoped to tenants that are all
        gone, notifies nobody and cannot be saved (saas-api requires at least
        one of each), so it is dropped with a warning and nothing is returned.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [object]$Rule,

        # Ids of the environment's active tenants. When omitted, only null tenant ids are removed.
        [System.Collections.Generic.HashSet[string]]$ActiveTenantIds
    )

    # The leading comma keeps one-item and empty lists as arrays; the API rejects a bare string.
    $nonNull = { param($values) , @($values | Where-Object { $null -ne $_ -and "$_" -ne '' }) }
    $label = "Notification rule '$($Rule.delivery_channel)' of '$($Rule.notification_type_key)'"

    $lists = $Rule.recipient_lists
    if ($null -ne $lists -and -not $Rule.PSObject.Properties['recipient_spec']) {
        $spec = [ordered]@{
            user_ids         = & $nonNull @($lists.users | ForEach-Object { $_.id })
            group_uuids      = & $nonNull @($lists.groups | ForEach-Object { $_.id })
            role_group_uuids = & $nonNull @($lists.role_groups | Where-Object { $null -ne $_.name } | ForEach-Object { $_.uuid })
            role_ids         = & $nonNull @($lists.roles | ForEach-Object { $_.id })
            emails           = & $nonNull @($lists.emails)
        }

        if (-not ($spec.Values | Where-Object { $_.Count -gt 0 })) {
            Write-Warning "$label was left out: every recipient it had has been deleted."
            return
        }

        $Rule | Add-Member -NotePropertyName 'recipient_spec' -NotePropertyValue ([pscustomobject]$spec)
    }

    $scope = $Rule.tenant_scope
    if ($null -ne $scope -and $scope.PSObject.Properties['tenant_ids'] -and $null -ne $scope.tenant_ids) {
        $tenantIds = & $nonNull @($scope.tenant_ids)
        if ($null -ne $ActiveTenantIds) {
            $tenantIds = @($tenantIds | Where-Object { $ActiveTenantIds.Contains("$_") })
        }

        if ($tenantIds.Count -eq 0) {
            Write-Warning "$label was left out: every tenant it was scoped to has been deleted or deactivated."
            return
        }

        $scope.tenant_ids = $tenantIds
    }

    return $Rule
}
