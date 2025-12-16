function Set-EvoLocalAdminAccountPasswordRotationConfig {
    <#
    .SYNOPSIS
        Update a password rotation configuration for a local admin account.

    .DESCRIPTION
        Updates the password rotation configuration via the
        /v1/local_admin_accounts/{id}/password_rotation_config endpoint.

    .PARAMETER LocalAdminAccountId
        The ID of the local admin account.

    .PARAMETER RotationFrequency
        Rotation frequency in days (1-24).

    .PARAMETER Enabled
        Whether password rotation is enabled.

    .EXAMPLE
        Set-EvoLocalAdminAccountPasswordRotationConfig -LocalAdminAccountId 'account-id' -RotationFrequency 14

        Updates the password rotation frequency to 14 days.

    .EXAMPLE
        Set-EvoLocalAdminAccountPasswordRotationConfig -LocalAdminAccountId 'account-id' -Enabled $false

        Disables password rotation for the account.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('Id')]
        [string]$LocalAdminAccountId,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(1, 24)]
        [Nullable[int]]$RotationFrequency,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Nullable[bool]]$Enabled
    )

    process {
        $body = @{}

        if ($PSBoundParameters.ContainsKey('RotationFrequency') -and $null -ne $RotationFrequency) {
            $body['rotationFrequency'] = $RotationFrequency
        }

        if ($PSBoundParameters.ContainsKey('Enabled') -and $null -ne $Enabled) {
            $body['enabled'] = $Enabled
        }

        if ($body.Count -eq 0) {
            Write-Verbose 'No updatable fields were provided.'
            return
        }

        if (-not $PSCmdlet.ShouldProcess("Local admin account $LocalAdminAccountId", 'Update password rotation config')) {
            return
        }

        $path = "/v1/local_admin_accounts/$LocalAdminAccountId/password_rotation_config"
        $response = Invoke-EvoApiRequest -Method 'PUT' -Path $path -Body $body

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
