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

Describe 'Deployment token cmdlets' {
    BeforeAll {
        Set-EvoPartnerApiConfig -ApiKey 'TEST-KEY' -BaseUri 'https://example.invalid' -DefaultPageSize 5
    }

    BeforeEach {
        Mock -CommandName Invoke-RestMethod -ModuleName EvoPartnerAPICommandlet -MockWith {
            [pscustomobject]@{ data = [pscustomobject]@{ id = 'token-id' } }
        }
    }

    It 'New-EvoDeploymentToken posts the tenant, directory, UTC expiry and settings' {
        $token = New-EvoDeploymentToken -Name 'Acme' -TenantId 'tenant-id' -DirectoryId 'dir-id' `
            -ExpireAt ([datetime]::new(2027, 6, 1, 0, 0, 0, [System.DateTimeKind]::Utc)) -Settings @{ enableJit = $true }

        $token.PSObject.TypeNames[0] | Should -Be 'Evo.DeploymentToken'
        Should -Invoke Invoke-RestMethod -ModuleName EvoPartnerAPICommandlet -Times 1 -ParameterFilter {
            $sent = $Body | ConvertFrom-Json
            $Method -eq 'POST' -and $Uri -eq 'https://example.invalid/v1/deployment_tokens' -and
                $sent.tenantId -eq 'tenant-id' -and $sent.directoryId -eq 'dir-id' -and
                $sent.settings.enableJit -eq $true -and $Body -match '"expireAt":\s*"2027-06-01T00:00:00\.0000000Z"'
        }
    }

    It 'Set-EvoDeploymentToken -NeverExpire sends an explicit null expireAt' {
        Set-EvoDeploymentToken -Id 'token-id' -NeverExpire -Confirm:$false | Out-Null

        Should -Invoke Invoke-RestMethod -ModuleName EvoPartnerAPICommandlet -Times 1 -ParameterFilter {
            $Method -eq 'PUT' -and $Uri -eq 'https://example.invalid/v1/deployment_tokens/token-id' -and
                $Body -match '"expireAt":\s*null'
        }
    }

    It 'Set-EvoDeploymentToken sends nothing when no field is given' {
        Set-EvoDeploymentToken -Id 'token-id' | Out-Null

        Should -Invoke Invoke-RestMethod -ModuleName EvoPartnerAPICommandlet -Times 0
    }

    It 'Get-EvoDeploymentToken passes tenant filters as repeated keys' {
        Get-EvoDeploymentToken -TenantIdList 'a', 'b' -Active 'true' | Out-Null

        Should -Invoke Invoke-RestMethod -ModuleName EvoPartnerAPICommandlet -Times 1 -ParameterFilter {
            $Method -eq 'GET' -and $Uri -match '/v1/deployment_tokens\?' -and
                $Uri -match 'tenantIds%5B%5D=a' -and $Uri -match 'tenantIds%5B%5D=b' -and $Uri -match 'active=true'
        }
    }

    It 'Remove-EvoDeploymentToken deletes by id' {
        Remove-EvoDeploymentToken -Id 'token-id' -Confirm:$false | Out-Null

        Should -Invoke Invoke-RestMethod -ModuleName EvoPartnerAPICommandlet -Times 1 -ParameterFilter {
            $Method -eq 'DELETE' -and $Uri -eq 'https://example.invalid/v1/deployment_tokens/token-id'
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
