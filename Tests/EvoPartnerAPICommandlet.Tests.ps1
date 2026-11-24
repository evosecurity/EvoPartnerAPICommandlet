$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$moduleRoot = Split-Path $here -Parent
$manifestPath = Join-Path $moduleRoot 'EvoPartnerAPICommandlet.psd1'

Import-Module $manifestPath -Force

Describe 'EvoPartnerAPICommandlet module' {
    BeforeAll {
        # Use dummy values so tests never require real credentials
        Set-EvoPartnerApiConfig -ApiKey 'TEST-KEY' -BaseUri 'https://example.invalid' -DefaultPageSize 5
    }

    It 'imports without error' {
        Get-Module EvoPartnerAPICommandlet | Should -Not -BeNullOrEmpty
    }

    Context 'HTTP mocking layer' {
        BeforeEach {
            Mock -CommandName Invoke-RestMethod -ModuleName EvoPartnerAPICommandlet -MockWith {
                [pscustomobject]@{
                    data       = @()
                    pagination = [pscustomobject]@{
                        page       = 1
                        totalPages = 1
                    }
                }
            }
        }

        It 'Get-EvoUser uses mocked HTTP and does not throw' {
            { Get-EvoUser -Limit 1 } | Should -Not -Throw
        }

        It 'Test-EvoPartnerApiHealth uses mocked HTTP and does not throw' {
            { Test-EvoPartnerApiHealth } | Should -Not -Throw
        }

        It 'Get-EvoWebhook uses mocked HTTP and does not throw' {
            { Get-EvoWebhook } | Should -Not -Throw
        }
    }

    Context 'RBAC v2 cmdlets' {
        BeforeEach {
            Mock -CommandName Invoke-RestMethod -ModuleName EvoPartnerAPICommandlet -MockWith {
                [pscustomobject]@{
                    success    = $true
                    data       = @()
                    pagination = [pscustomobject]@{ page = 1; totalPages = 1 }
                }
            }
        }

        It 'exposes a cmdlet for every RBAC v2 endpoint' {
            $expected = @(
                'Get-EvoRbacRole','New-EvoRbacRole','Set-EvoRbacRole','Remove-EvoRbacRole',
                'Get-EvoPermission','Get-EvoPermissionCatalog',
                'Get-EvoRbacRoleAssignedUser','Add-EvoRbacRoleAssignedUser','Remove-EvoRbacRoleAssignedUser',
                'Get-EvoRbacRoleAssignedGroup','Add-EvoRbacRoleAssignedGroup','Remove-EvoRbacRoleAssignedGroup',
                'Get-EvoUserRbacRole','Add-EvoUserRbacRole','Remove-EvoUserRbacRole',
                'Add-EvoUserRbacRoleBulk','Remove-EvoUserRbacRoleBulk',
                'Get-EvoGroupRbacRole','Add-EvoGroupRbacRole','Remove-EvoGroupRbacRole',
                'Add-EvoGroupRbacRoleBulk','Remove-EvoGroupRbacRoleBulk'
            )

            foreach ($name in $expected) {
                Get-Command -Module EvoPartnerAPICommandlet -Name $name -ErrorAction SilentlyContinue |
                    Should -Not -BeNullOrEmpty -Because "$name should be exported"
            }
        }

        It 'read cmdlets use mocked HTTP and do not throw' {
            { Get-EvoRbacRole } | Should -Not -Throw
            { Get-EvoPermission } | Should -Not -Throw
            { Get-EvoPermissionCatalog } | Should -Not -Throw
            { Get-EvoUserRbacRole -UserId '11111111-1111-1111-1111-111111111111' } | Should -Not -Throw
            { Get-EvoGroupRbacRole -GroupId '11111111-1111-1111-1111-111111111111' } | Should -Not -Throw
            { Get-EvoRbacRoleAssignedUser -RbacRoleId '11111111-1111-1111-1111-111111111111' } | Should -Not -Throw
            { Get-EvoRbacRoleAssignedGroup -RbacRoleId '11111111-1111-1111-1111-111111111111' } | Should -Not -Throw
        }

        It 'write cmdlets use mocked HTTP and do not throw' {
            { New-EvoRbacRole -Name 'Test' -PermissionKeyList @('view_dashboard') -Confirm:$false } | Should -Not -Throw
            { Set-EvoRbacRole -Id '11111111-1111-1111-1111-111111111111' -Name 'Test' -Confirm:$false } | Should -Not -Throw
            { Remove-EvoRbacRole -Id '11111111-1111-1111-1111-111111111111' -Confirm:$false } | Should -Not -Throw
            { Add-EvoUserRbacRole -UserId '11111111-1111-1111-1111-111111111111' -RbacRoleIdList @('22222222-2222-2222-2222-222222222222') -Confirm:$false } | Should -Not -Throw
            { Add-EvoGroupRbacRole -GroupId '11111111-1111-1111-1111-111111111111' -RbacRoleIdList @('22222222-2222-2222-2222-222222222222') -Confirm:$false } | Should -Not -Throw
        }

        It 'Set-EvoRbacRole refuses a no-op update' {
            { Set-EvoRbacRole -Id '11111111-1111-1111-1111-111111111111' -Confirm:$false } |
                Should -Throw -ExpectedMessage '*Nothing to update*'
        }
    }

    Context 'Notification delivery rule cmdlets' {
        BeforeEach {
            # t-1 is active; t-2 is deactivated (the GET still lists it, /v1/tenants does not); null is deleted.
            Mock -CommandName Invoke-RestMethod -ModuleName EvoPartnerAPICommandlet -ParameterFilter { $Uri -like '*/v1/tenants*' } -MockWith {
                [pscustomobject]@{
                    success    = $true
                    data       = @([pscustomobject]@{ id = 't-1' })
                    pagination = [pscustomobject]@{ page = 1; totalPages = 1 }
                }
            }
            Mock -CommandName Invoke-RestMethod -ModuleName EvoPartnerAPICommandlet -ParameterFilter { $Uri -notlike '*/v1/tenants*' } -MockWith {
                [pscustomobject]@{
                    success = $true
                    data    = [pscustomobject]@{
                        enabled     = $true
                        psa_enabled = $false
                        rules       = @(
                            [pscustomobject]@{
                                notification_type_key = 'elevation.request_pending'
                                delivery_channel      = 'email'
                                enabled               = $true
                                tenant_scope          = [pscustomobject]@{ all_tenants = $false; tenant_ids = @('t-1', $null, 't-2') }
                                recipient_lists       = [pscustomobject]@{
                                    users       = @([pscustomobject]@{ id = 'u-1' }, [pscustomobject]@{ id = $null })
                                    groups      = @([pscustomobject]@{ id = 'g-1' })
                                    role_groups = @([pscustomobject]@{ uuid = 'rg-1'; name = 'Admins' }, [pscustomobject]@{ uuid = 'rg-gone'; name = $null })
                                    roles       = @()
                                    emails      = @('soc@example.com')
                                }
                            },
                            [pscustomobject]@{
                                notification_type_key = 'elevation.request_pending'
                                delivery_channel      = 'in_app'
                                enabled               = $true
                                tenant_scope          = [pscustomobject]@{ all_tenants = $false; tenant_ids = @('t-2') }
                                recipient_lists       = [pscustomobject]@{
                                    users = @([pscustomobject]@{ id = 'u-1' }); groups = @(); role_groups = @(); roles = @(); emails = @()
                                }
                            }
                        )
                    }
                }
            }
        }

        It 'Get-EvoNotificationTypeRule leaves out deleted recipients, deleted role groups and deleted or deactivated tenants' {
            $result = Get-EvoNotificationTypeRule -Key 'elevation.request_pending' -WarningAction SilentlyContinue
            $result.NotificationTypeKey | Should -Be 'elevation.request_pending'
            $rule = $result.rules[0]
            @($rule.recipient_spec.user_ids) | Should -Be @('u-1')
            @($rule.recipient_spec.group_uuids) | Should -Be @('g-1')
            @($rule.recipient_spec.role_group_uuids) | Should -Be @('rg-1')
            @($rule.recipient_spec.emails) | Should -Be @('soc@example.com')
            @($rule.tenant_scope.tenant_ids) | Should -Be @('t-1')
        }

        It 'Get-EvoNotificationTypeRule drops, with a warning, a rule whose tenants are all gone' {
            $result = Get-EvoNotificationTypeRule -Key 'elevation.request_pending' -WarningVariable warnings -WarningAction SilentlyContinue
            @($result.rules).Count | Should -Be 1
            $result.rules[0].delivery_channel | Should -Be 'email'
            @($warnings).Count | Should -Be 1
            "$($warnings[0])" | Should -BeLike "*'in_app'*deleted or deactivated*"
        }

        It 'Get-EvoNotificationTypeRule reads the active tenant list once' {
            Get-EvoNotificationTypeRule -Key 'elevation.request_pending' -WarningAction SilentlyContinue | Out-Null
            Should -Invoke -CommandName Invoke-RestMethod -ModuleName EvoPartnerAPICommandlet -ParameterFilter { $Uri -like '*/v1/tenants*' } -Times 1 -Exactly
        }

        It 'Set-EvoNotificationTypeRule refuses to send no rules unless -ClearRules is given' {
            { Set-EvoNotificationTypeRule -Key 'elevation.request_pending' -Enabled $false -Confirm:$false } |
                Should -Throw -ExpectedMessage '*Sending no rules deletes them all*'
            { Set-EvoNotificationTypeRule -Key 'elevation.request_pending' -ClearRules -Confirm:$false } | Should -Not -Throw
        }

        It 'Set-EvoNotificationTypeRule sends only writable rule fields when rules are piped back' {
            Get-EvoNotificationTypeRule -Key 'elevation.request_pending' -WarningAction SilentlyContinue | Set-EvoNotificationTypeRule -Confirm:$false

            Should -Invoke -CommandName Invoke-RestMethod -ModuleName EvoPartnerAPICommandlet -ParameterFilter {
                $Method -eq 'PATCH' -and $Body -notmatch 'recipient_lists' -and
                $Body -match '"rules":\s*\[' -and $Body -match '"user_ids":\s*\[\s*"u-1"\s*\]' -and $Body -match '"tenant_ids":\s*\[\s*"t-1"\s*\]'
            } -Times 1 -Exactly
        }

        It 'Set-EvoNotificationTypeRule -ClearRules sends an empty rule list' {
            Set-EvoNotificationTypeRule -Key 'elevation.request_pending' -ClearRules -Confirm:$false

            Should -Invoke -CommandName Invoke-RestMethod -ModuleName EvoPartnerAPICommandlet -ParameterFilter {
                $Method -eq 'PATCH' -and $Body -match '"rules":\s*\[\s*\]'
            } -Times 1 -Exactly
        }
    }
}

InModuleScope EvoPartnerAPICommandlet {
    Describe 'Invoke-EvoApiRequest error handling' {
        It 'retries on HTTP 429 when RetryOnRateLimit is enabled' {
            $script:EvoPartnerApiConfig.RetryOnRateLimit = $true

            $callCount = 0
            Mock -CommandName Invoke-RestMethod -ModuleName EvoPartnerAPICommandlet -MockWith {
                $script:callCount++

                if ($script:callCount -lt 2) {
                    $response = [pscustomobject]@{
                        StatusCode        = 429
                        StatusDescription = 'Too Many Requests'
                        Headers           = @{
                            'RateLimit-Limit'     = '10'
                            'RateLimit-Remaining' = '0'
                            'RateLimit-Reset'     = '1'
                        }
                    }

                    $ex = New-Object System.Net.WebException 'Too Many Requests'
                    $ex | Add-Member -NotePropertyName Response -NotePropertyValue $response -Force
                    throw $ex
                }

                [pscustomobject]@{ data = @() }
            }

            { Invoke-EvoApiRequest -Method 'GET' -Path '/v1/users' } | Should -Not -Throw
            $script:callCount | Should -Be 2
        }
    }

    Describe 'ConvertTo-EvoRbacGrant' {
        It 'returns $null when no grants are supplied, so callers can omit the property' {
            ConvertTo-EvoRbacGrant | Should -BeNullOrEmpty
        }

        It 'builds only the buckets that were supplied' {
            $grants = ConvertTo-EvoRbacGrant -PermissionKeyList @('view_dashboard') -CategoryKeyList @('billing')
            $grants.permissions | Should -Be @('view_dashboard')
            $grants.categories  | Should -Be @('billing')
            $grants.ContainsKey('groups') | Should -BeFalse
        }

        It 'passes a raw grants hashtable straight through' {
            $raw = @{ permissions = @('view_keys') }
            (ConvertTo-EvoRbacGrant -Grants $raw).permissions | Should -Be @('view_keys')
        }

        It 'rejects unknown grant buckets' {
            { ConvertTo-EvoRbacGrant -Grants @{ nope = @('x') } } |
                Should -Throw -ExpectedMessage '*may only contain*'
        }
    }
}
