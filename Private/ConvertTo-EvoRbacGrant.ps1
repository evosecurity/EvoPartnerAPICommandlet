function ConvertTo-EvoRbacGrant {
    <#
    .SYNOPSIS
        Internal helper that builds the RBAC v2 grants payload.

    .DESCRIPTION
        Normalizes the convenience key parameters (-PermissionKeyList,
        -CategoryKeyList, -GroupKeyList) and the raw -Grants hashtable into the
        single grants object the API expects. Returns $null when the caller
        supplied nothing, so callers can omit the property entirely rather than
        sending an empty object -- on update an empty object clears all grants.

    .PARAMETER Grants
        Raw grants hashtable supplied by the caller. Wins over the key lists.

    .PARAMETER PermissionKeyList
        Individual permission keys.

    .PARAMETER CategoryKeyList
        Category keys granted in full.

    .PARAMETER GroupKeyList
        Permission group keys granted in full.

    .OUTPUTS
        Hashtable with any of the permissions/categories/groups buckets, or $null.
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [hashtable]$Grants,

        [Parameter()]
        [string[]]$PermissionKeyList,

        [Parameter()]
        [string[]]$CategoryKeyList,

        [Parameter()]
        [string[]]$GroupKeyList
    )

    if ($Grants) {
        $allowed = @('permissions','categories','groups')
        $unknown = @($Grants.Keys | Where-Object { $allowed -notcontains $_ })

        if ($unknown.Count -gt 0) {
            throw "grants may only contain permissions, categories, groups; got $($unknown -join ', ')."
        }

        return $Grants
    }

    $payload = @{}

    if ($PermissionKeyList) { $payload['permissions'] = @($PermissionKeyList) }
    if ($CategoryKeyList)   { $payload['categories']  = @($CategoryKeyList) }
    if ($GroupKeyList)      { $payload['groups']      = @($GroupKeyList) }

    if ($payload.Count -eq 0) {
        return $null
    }

    return $payload
}
