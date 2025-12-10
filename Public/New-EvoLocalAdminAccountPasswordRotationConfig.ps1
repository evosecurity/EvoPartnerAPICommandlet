function New-EvoLocalAdminAccountPasswordRotationConfig {
    <#
    .SYNOPSIS
        Create a password rotation configuration for a local admin account.

    .DESCRIPTION
        Creates a scheduled password rotation configuration via the
        /v1/local_admin_accounts/{id}/password_rotation_config endpoint.

    .PARAMETER LocalAdminAccountId
        The ID of the local admin account.

    .PARAMETER RotationFrequency
        Rotation frequency in days (1-24).

    .PARAMETER Enabled
        Whether password rotation is enabled. Defaults to true.

    .EXAMPLE
        New-EvoLocalAdminAccountPasswordRotationConfig -LocalAdminAccountId 'account-id' -RotationFrequency 7

        Creates a password rotation config with 7-day frequency.

    .EXAMPLE
        New-EvoLocalAdminAccountPasswordRotationConfig -LocalAdminAccountId 'account-id' -RotationFrequency 14 -Enabled $false

        Creates a disabled password rotation config with 14-day frequency.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('Id')]
        [string]$LocalAdminAccountId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(1, 24)]
        [int]$RotationFrequency,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [bool]$Enabled = $true
    )

    process {
        if (-not $PSCmdlet.ShouldProcess("Local admin account $LocalAdminAccountId", 'Create password rotation config')) {
            return
        }

        $body = @{
            rotationFrequency = $RotationFrequency
            enabled           = $Enabled
        }

        $path = "/v1/local_admin_accounts/$LocalAdminAccountId/password_rotation_config"
        $response = Invoke-EvoApiRequest -Method 'POST' -Path $path -Body $body

        if ($null -ne $response -and $response.PSObject.Properties['data']) {
            $config = $response.data

            if ($config -is [pscustomobject]) {
                $config.PSObject.TypeNames.Insert(0, 'Evo.PasswordRotationConfig')
            }

            Write-Output $config
        }
        else {
            Write-Output $response
        }
    }
}
