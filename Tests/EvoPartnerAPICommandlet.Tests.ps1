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
}
