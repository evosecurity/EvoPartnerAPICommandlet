function Get-EvoNotificationTypeRule {
    <#
    .SYNOPSIS
        Get the delivery rules of one or more notification types.

    .DESCRIPTION
        Retrieves delivery rules via the /v1/notification-type-rules
        endpoint. Each notification type is returned as one object with
        NotificationTypeKey, enabled, psa_enabled and rules, so it can be
        changed and piped straight into Set-EvoNotificationTypeRule.

        The API returns each rule's recipients resolved (recipient_lists,
        with names). Each rule also gets a recipient_spec holding the same
        recipients as ids, which is what Set-EvoNotificationTypeRule
        sends. Recipients and tenants deleted or deactivated since the rule
        was saved are left out of recipient_spec and tenant_scope, because
        the API refuses them on save. A rule with none left notifies nobody
        and cannot be saved, so it is left out with a warning.

        When a rule is scoped to specific tenants, the active tenant list
        (Get-EvoTenant -All) is read once to find deactivated ones.

        Keys are requested 50 at a time (the API maximum), so any number
        of keys can be passed or piped in.

        Requires an API key with the Manage Notification Configuration
        permission.

    .PARAMETER Key
        One or more notification type keys, e.g. 'elevation.request_pending'.
        Accepts the output of Get-EvoNotificationType from the pipeline.

    .EXAMPLE
        Get-EvoNotificationTypeRule -Key 'elevation.request_pending'

    .EXAMPLE
        Get-EvoNotificationType -All | Get-EvoNotificationTypeRule

        Returns the rules of every configurable notification type.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('NotificationTypeKey')]
        [string[]]$Key
    )

    begin {
        $maxKeysPerRequest = 50
        $keys = [System.Collections.Generic.List[string]]::new()
        # Loaded on first use: only rules scoped to specific tenants need it.
        $activeTenantIds = $null
    }

    process {
        foreach ($k in $Key) {
            if (-not [string]::IsNullOrWhiteSpace($k)) {
                $keys.Add($k)
            }
        }
    }

    end {
        for ($offset = 0; $offset -lt $keys.Count; $offset += $maxKeysPerRequest) {
            $batch = @($keys.GetRange($offset, [Math]::Min($maxKeysPerRequest, $keys.Count - $offset)))

            # A single key returns the rules directly; several return them keyed by notification type.
            if ($batch.Count -eq 1) {
                $response = Invoke-EvoApiRequest -Method 'GET' -Path '/v1/notification-type-rules' -Query @{ notification_type_key = $batch[0] }
                $rulesByKey = @{}
                if ($null -ne $response -and $response.PSObject.Properties['data']) {
                    $rulesByKey[$batch[0]] = $response.data
                }
            }
            else {
                $response = Invoke-EvoApiRequest -Method 'GET' -Path '/v1/notification-type-rules' -Query @{ 'notification_type_keys[]' = $batch }
                $rulesByKey = @{}
                if ($null -ne $response -and $response.PSObject.Properties['data'] -and $response.data.notification_type_rules) {
                    foreach ($property in $response.data.notification_type_rules.PSObject.Properties) {
                        $rulesByKey[$property.Name] = $property.Value
                    }
                }
            }

            if ($rulesByKey.Count -eq 0) {
                Write-Output $response
                continue
            }

            foreach ($k in $batch) {
                if (-not $rulesByKey.ContainsKey($k)) {
                    continue
                }

                $data = $rulesByKey[$k]
                $rules = foreach ($rule in @($data.rules)) {
                    if ($null -eq $rule) { continue }

                    # /v1/tenants lists active tenants only; the PATCH refuses deactivated ones.
                    if ($null -eq $activeTenantIds -and @($rule.tenant_scope.tenant_ids | Where-Object { $null -ne $_ }).Count -gt 0) {
                        $activeTenantIds = [System.Collections.Generic.HashSet[string]]::new()
                        Get-EvoTenant -All -Limit 100 | ForEach-Object { [void]$activeTenantIds.Add("$($_.id)") }
                    }

                    ConvertTo-EvoNotificationRuleInput -Rule $rule -ActiveTenantIds $activeTenantIds
                }
                $result = [pscustomobject][ordered]@{
                    NotificationTypeKey = $k
                    enabled             = $data.enabled
                    psa_enabled         = $data.psa_enabled
                    rules               = @($rules)
                }
                $result.PSObject.TypeNames.Insert(0, 'Evo.NotificationTypeRule')
                Write-Output $result
            }
        }
    }
}
