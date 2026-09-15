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
