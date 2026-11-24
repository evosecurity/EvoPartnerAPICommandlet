function Set-EvoNotificationTypeRule {
    <#
    .SYNOPSIS
        Replace the delivery rules of a notification type.

    .DESCRIPTION
        Replaces every delivery rule of one notification type via
        PATCH /v1/notification-type-rules. The rule list you send becomes
        the full list: rules you leave out are deleted.

        Because the API deletes all rules when no rule list is sent, this
        cmdlet requires either -Rule (the full list) or -ClearRules. To
        change one rule or only toggle -Enabled, read the current rules
        with Get-EvoNotificationTypeRule, change them, and pipe the
        object back in.

        The change is processed asynchronously. The cmdlet returns the
        operation (operationId, status); poll it with
        Get-EvoAsyncOperation, then read the result with
        Get-EvoNotificationTypeRule. Requests are applied in order with no
        locking, so the last one processed wins.

        Requires an API key with the Manage Notification Configuration
        permission.

    .PARAMETER Key
        The notification type key, e.g. 'elevation.request_pending'.

    .PARAMETER Rule
        The full list of rules. Each rule is a hashtable or object with
        delivery_channel (required; one of the type's allowedChannels from
        Get-EvoNotificationType) and optionally enabled, recipient_spec
        (user_ids, group_uuids, role_group_uuids, role_ids, role_names,
        emails, shortcuts), tenant_scope (all_tenants, tenant_ids) and
        time_window.

    .PARAMETER ClearRules
        Remove every rule of the notification type.

    .PARAMETER Enabled
        Turn the notification type on or off for the environment. Left
        unchanged when not passed.

    .PARAMETER PsaEnabled
        Turn PSA ticket creation for the notification type on or off. Left
        unchanged when not passed.

    .EXAMPLE
        Set-EvoNotificationTypeRule -Key 'elevation.request_pending' -Rule @(
            @{
                delivery_channel = 'email'
                recipient_spec   = @{ emails = @('soc@partner.example.com') }
                tenant_scope     = @{ all_tenants = $true }
            }
        )

        Sends pending elevation requests for every tenant to one address,
        replacing any existing rules.

    .EXAMPLE
        $current = Get-EvoNotificationTypeRule -Key 'elevation.request_pending'
        $current.enabled = $false
        $operation = $current | Set-EvoNotificationTypeRule
        Get-EvoAsyncOperation -Id $operation.operationId

        Turns the notification type off while keeping its rules.

    .EXAMPLE
        Set-EvoNotificationTypeRule -Key 'elevation.request_pending' -ClearRules

        Removes every rule of the notification type.
    #>
    [CmdletBinding(SupportsShouldProcess = $true, DefaultParameterSetName = 'Rules')]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [Alias('NotificationTypeKey')]
        [string]$Key,

        [Parameter(ParameterSetName = 'Rules', ValueFromPipelineByPropertyName = $true)]
        [Alias('Rules')]
        [AllowEmptyCollection()]
        [object[]]$Rule,

        [Parameter(ParameterSetName = 'Clear', Mandatory = $true)]
        [switch]$ClearRules,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [bool]$Enabled,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('psa_enabled')]
        [bool]$PsaEnabled
    )

    process {
        # The API treats a missing rule list as "delete every rule", so never send one by accident.
        if ($PSCmdlet.ParameterSetName -eq 'Rules' -and -not $PSBoundParameters.ContainsKey('Rule')) {
            throw 'Pass -Rule with the full rule list (see Get-EvoNotificationTypeRule), or -ClearRules to remove every rule. Sending no rules deletes them all.'
        }

        # Send only the fields the API accepts, so rules from Get-EvoNotificationTypeRule
        # (which also carry recipient_lists and notification_type_key) go back as-is.
        $writableFields = 'delivery_channel', 'enabled', 'recipient_spec', 'tenant_scope', 'time_window'
        $rules = foreach ($r in @($Rule)) {
            if ($null -eq $r) { continue }
            $source = if ($r -is [System.Collections.IDictionary]) { $r } else { $r.PSObject.Properties | ForEach-Object -Begin { $h = @{} } -Process { $h[$_.Name] = $_.Value } -End { $h } }
            $clean = [ordered]@{}
            foreach ($field in $writableFields) {
                if ($source.Contains($field)) { $clean[$field] = $source[$field] }
            }
            $clean
        }

        # Assigned from a variable: an if-expression would unwrap a one-rule array into an object.
        $ruleList = @()
        if (-not $ClearRules.IsPresent) { $ruleList = @($rules) }

        $body = [ordered]@{
            notification_type_key = $Key
            rules                 = $ruleList
        }

        if ($PSBoundParameters.ContainsKey('Enabled')) {
            $body['enabled'] = $Enabled
        }

        if ($PSBoundParameters.ContainsKey('PsaEnabled')) {
            $body['psa_enabled'] = $PsaEnabled
        }

        $action = if ($ClearRules.IsPresent) { 'Remove every delivery rule' } else { "Replace delivery rules with $(@($rules).Count) rule(s)" }
        if (-not $PSCmdlet.ShouldProcess("Notification type $Key", $action)) {
            return
        }

        $response = Invoke-EvoApiRequest -Method 'PATCH' -Path '/v1/notification-type-rules' -Body $body

        if ($null -ne $response -and $response.PSObject.Properties['data']) {
            $operation = $response.data
            if ($operation -is [pscustomobject]) {
                $operation.PSObject.TypeNames.Insert(0, 'Evo.AsyncOperation')
            }
            Write-Output $operation
        }
        else {
            Write-Output $response
        }
    }
}
