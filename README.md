# Evo Partner API PowerShell Module

This repository contains the `EvoPartnerAPICommandlet` PowerShell module, a
namespaced, MSP-friendly wrapper around the Evo Partner API.

The module exposes strongly-typed, verb–noun cmdlets for all routes in the
`evo-partner-api-swagger.json` specification. It is designed to be easy for
non-developers to use while remaining powerful for automation and scripting.

---

## 1. Installation

### 1.1 Local installation

1. Build/clone the repository so the module folder exists somewhere:

   ```text
   C:\EvoPartnerAPICommandlet\
     EvoPartnerAPICommandlet.psd1
     EvoPartnerAPICommandlet.psm1
     Public\*.ps1
     Private\*.ps1
   ```

2. Copy the module folder into a path on `$env:PSModulePath`, for example:

   ```powershell
   $target = "$Env:ProgramFiles\WindowsPowerShell\Modules\EvoPartnerAPICommandlet"
   Copy-Item -Recurse 'g:\Evo\commandlet\EvoPartnerAPICommandlet' $target
   ```

3. Import the module:

   ```powershell
   Import-Module EvoPartnerAPICommandlet
   ```

### 1.2 Install from GitHub Packages

MSPs or technicians can install the module directly from GitHub instead of copying files around if desired.
This makes getting updates significantly easier as well.

> You need a free GitHub account and a personal access token (PAT) with
> `read:packages` permission. The source repository can remain public.

1. **Create a GitHub personal access token (classic)**

   1. Sign in to GitHub.
   2. Go to **Settings → Developer settings → Personal access
      tokens → Tokens (classic)** or open:

      <https://github.com/settings/tokens>

   3. Click **Generate new token (classic)**.
   4. Give it a name like `EvoPartnerAPICommandlet-packages`.
   5. Set an expiration that matches your security policy.
   6. Check the **`read:packages`** scope (you do **not** need full
      `repo` access just to install packages).
   7. Click **Generate token** and **copy the token value** somewhere
      safe. You will not be able to see it again.

2. **Add credentials and install the module**

   Save the following to a Powershell script, replacing the
   placeholders with your own GitHub username and the PAT from step 1.
   Run the script in an elevated terminal. Nuget is required to install the
   module, the script will download it automatically if it is missing:

```powershell
   # --- Config ---
   $owner       = "evosecurity"
   $user        = "<YOUR_GITHUB_USERNAME>"
   $token       = "<PAT_FROM_STEP_1>"
   $packageName = "EvoPartnerAPICommandlet"

   # --- Ensure nuget.exe exists ---
   $nuget = "$env:LOCALAPPDATA\nuget\nuget.exe"
   if (!(Test-Path $nuget)) {
       Invoke-WebRequest "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe" -OutFile $nuget
   }

   # --- Add GitHub Packages feed ---
   $sourceExists = (& $nuget sources List) -match "GitHubPackages"
   if (-not $sourceExists) {
       & $nuget sources Add `
           -Name "GitHubPackages" `
           -Source "https://nuget.pkg.github.com/$owner/index.json" `
           -UserName $user `
           -Password $token `
           -StorePasswordInClearText | Out-Null
   }

   # --- Download package to temp folder ---
   $temp = Join-Path $env:TEMP "psmodule"
   Remove-Item $temp -Recurse -Force -ErrorAction Ignore
   New-Item $temp -ItemType Directory | Out-Null

   & $nuget install $packageName -Source GitHubPackages -OutputDirectory $temp | Out-Null

   # --- Find the downloaded folder ---
   $pkg = Get-ChildItem $temp | Where-Object { $_.Name -like "$($packageName.ToLower())*" }

   # --- Destination (global) ---
   $dest = "C:\Program Files\WindowsPowerShell\Modules\$packageName"

   # Remove old version if it exists
   if (Test-Path $dest) { Remove-Item $dest -Recurse -Force }

   # Copy module to destination
   Copy-Item -Recurse $pkg.FullName $dest

   # --- Import module ---
   Import-Module $dest -Force

   Write-Host "Module installed and imported from $dest" -ForegroundColor Green
```

After installing, `Import-Module EvoPartnerAPICommandlet` can be used on the machine at any time to start up the module.

---

## 2. Configuration & Authentication

Before calling the API you must configure the base URL and API key.

### 2.1 One-time config per session

```powershell
Set-EvoPartnerApiConfig -ApiKey '<YOUR_API_KEY>'
```

Optional parameters:

- `-BaseUri` (default `https://partner-api.evosecurity.com`)
- `-DefaultPageSize` (for paginated list operations)
- `-RetryOnRateLimit` (enables simple automatic retry for HTTP 429)

View the current configuration (API key is redacted):

```powershell
Get-EvoPartnerApiConfig
```

### 2.2 Environment variables

You can also configure the module via environment variables:

- `EVO_PARTNER_API_URL` – base URI
- `EVO_PARTNER_API_KEY` – API key

When present, these values are loaded when the module is imported.

---

## 3. Error Handling & Rate Limiting

All cmdlets use a shared HTTP helper and:

- Throw terminating errors on HTTP failures (use `try { } catch { }`).
- Surface error messages from the Evo Partner API response.
- Propagate rate-limit details for 429 responses, including headers
  such as `RateLimit-Limit`, `RateLimit-Remaining`, and `RateLimit-Reset`.

Example pattern:

```powershell
try {
    Get-EvoUser -All
}
catch {
    Write-Warning "Evo Partner API call failed: $($_.Exception.Message)"
}
```

If `-RetryOnRateLimit` is enabled via `Set-EvoPartnerApiConfig`, the module
will perform a simple retry for 429 responses based on server hints.

### 3.1 Debugging when scripting cmdlets

When you are writing automation or runbooks, it can be useful to see the
exact JSON being sent to and returned from the Evo Partner API.

- **Verbose HTTP error details**

  The shared HTTP helper writes the raw JSON error body as verbose output
  when the API returns an error. Run any cmdlet with `-Verbose` to see it:

  ```powershell
  try {
      Get-EvoUser -Id 'BAD_ID' -Verbose
  }
  catch {
      # High-level message
      Write-Host $_.Exception.Message -ForegroundColor Red
  }
  ```

  On failure you will see a line similar to:

  ```text
  [Invoke-EvoApiRequest] Raw error body:
  {"code":"ValidationError","message":"Validation failed",...}
  ```

- **Inspect error JSON in scripts**

  If you need to branch logic based on the error code/message, you can
  parse the JSON inside `catch`:

  ```powershell
  try {
      Get-EvoUser -Id 'BAD_ID'
  }
  catch {
      $raw = $_.Exception.InnerException.ErrorDetails.Message
      $errorJson = $null
      if ($raw) {
          $errorJson = $raw | ConvertFrom-Json -ErrorAction SilentlyContinue
      }

      if ($errorJson -and $errorJson.code -eq 'ValidationError') {
          Write-Warning "Validation error from Evo API: $($errorJson.message)"
      }
      else {
          Write-Warning "Evo API call failed: $($_.Exception.Message)"
      }
  }
  ```

- **Seeing bulk request bodies**

  Bulk cmdlets such as `New-EvoUserBulk` log the request body as verbose
  output before calling the API. This is extremely helpful when debugging
  CSV imports:

  ```powershell
  Import-Csv .\users.csv | New-EvoUserBulk -Verbose
  ```

  The verbose output includes a JSON representation of the `users` array
  being posted to `/v1/users/bulk`.

- **Bulk operations and partial failures**

  Bulk endpoints return HTTP 201 even when some items fail. The response
  body includes a `failedItems` array. Bulk cmdlets in this module:

  - Return the full API response object.
  - Emit `Write-Warning` messages when `failedItems` is non-empty.

  Example scripting pattern:

  ```powershell
  $response = Import-Csv .\users.csv | New-EvoUserBulk

  $failed = @($response.data.failedItems)
  if ($failed.Count -gt 0) {
      foreach ($fi in $failed) {
          Write-Host "Failed: $($fi.email) -> $($fi.error)" -ForegroundColor Red
      }

      # Treat partial success as an error if desired
      throw "Bulk user create completed with $($failed.Count) failed item(s)."
  }
  ```

  You can also capture the warnings produced by the bulk cmdlets using
  `-WarningVariable` if you prefer not to throw.

---

## 4. Core Usage by Area

### 4.1 Users

#### List users

```powershell
# First page
Get-EvoUser

# All users with auto-pagination
Get-EvoUser -All

# Filter by tenant and directory
Get-EvoUser -TenantId 'TENANT_GUID' -DirectoryId 'DIRECTORY_GUID'

# Search
Get-EvoUser -Query 'alice'
```

#### Create, update, delete user

```powershell
# Create user
$newUser = New-EvoUser `
  -Email 'user@example.com' `
  -FirstName 'Alice' `
  -LastName 'Admin' `
  -IsAdmin $true `
  -DirectoryId 'DIRECTORY_GUID'

# Update user
Set-EvoUser -Id $newUser.id -FirstName 'Alicia'

# Delete user
Remove-EvoUser -Id $newUser.id -Confirm:$false
```

#### Tenant access and role groups

```powershell
# Grant tenant access to a user
Add-EvoUserTenantAccess -UserId $newUser.id -TenantIdList 'TENANT_GUID'

# Assign role groups
Add-EvoUserRoleGroup -UserId $newUser.id -RoleGroupIdList 'ROLE_GROUP_GUID'
```

#### Bulk users from CSV

```powershell
Import-Csv .\users.csv | New-EvoUserBulk
```

Where `users.csv` has headers like:

```text
Email,FirstName,LastName,IsAdmin,DirectoryId,LicenseIds,RoleGroupIds,SendWelcomeEmail
```

#### Welcome emails

```powershell
Get-EvoUser -Query 'newuser' | Select-Object -ExpandProperty id | `
  Send-EvoUserWelcomeEmail
```

---

### 4.2 Tenants & Directories

#### List and manage tenants

```powershell
# List tenants
Get-EvoTenant

# Get a tenant by Id
Get-EvoTenant -Id 'TENANT_GUID'

# Create tenant
$newTenant = New-EvoTenant -Name 'customer-01'

# Update display name
Set-EvoTenant -Id $newTenant.id -DisplayName 'Customer 01'

# Delete
Remove-EvoTenant -Id $newTenant.id -Confirm:$false
```

#### Bulk tenants

```powershell
@(
  [pscustomobject]@{ Name = 'customer-02' },
  [pscustomobject]@{ Name = 'customer-03' }
) | New-EvoTenantBulk
```

#### Directories

```powershell
# Create Cloud Directory
New-EvoDirectory -Name 'Dir-Customer-01' -TenantId $newTenant.id

# List directories
Get-EvoDirectory -TenantIdList $newTenant.id
```

---

### 4.3 Licenses

#### List and inspect licenses

```powershell
Get-EvoLicense       # paged
Get-EvoLicense -Id 'LICENSE_GUID'
```

#### License usage

```powershell
# All tenants in environment
Get-EvoLicenseUsage

# Single tenant
Get-EvoTenantLicenseUsage -TenantId $newTenant.id
```

#### Assign/remove licenses

```powershell
# Assign license to multiple users
Add-EvoLicenseAssignment -LicenseId 'LICENSE_GUID' -UserIdList $userIds

# Remove license from multiple users
Remove-EvoLicenseAssignment -LicenseId 'LICENSE_GUID' -UserIdList $userIds
```

---

### 4.4 Groups & Role Groups

```powershell
# Create a group and add members
$newGroup = New-EvoGroup -TenantId $newTenant.id -Name 'Helpdesk'
Add-EvoGroupMember -GroupId $newGroup.id -UserIdList $userIds

# List role groups
Get-EvoRoleGroup -Query 'Help Desk'

# Assign role groups to a group
Add-EvoGroupRoleGroup -GroupId $newGroup.id -RoleGroupIdList 'ROLE_GROUP_GUID'
```

---

### 4.5 Tenant Accesses (User & Group)

```powershell
# User-based
Add-EvoUserTenantAccess -UserId $userId -TenantIdList $tenantIds
Remove-EvoUserTenantAccess -UserId $userId -TenantIdList $tenantIds

# Group-based
Add-EvoGroupTenantAccess -GroupId $groupId -TenantIdList $tenantIds
Remove-EvoGroupTenantAccess -GroupId $groupId -TenantIdList $tenantIds

# Tenant-centric
Get-EvoTenantAccess -TenantId $newTenant.id
```

---

### 4.6 Access Tokens

```powershell
# List tokens
Get-EvoAccessToken -Type endpoint_agent -Active 'true'

# Create token
$newToken = New-EvoAccessToken -Name 'Endpoint Agent 1' -DirectoryId 'DIRECTORY_GUID' -Type endpoint_agent

# Update / disable token
Set-EvoAccessToken -Id $newToken.id -Active $false

# Delete token
Remove-EvoAccessToken -Id $newToken.id -Confirm:$false
```

---

### 4.7 Elevated Assignments

```powershell
# Create elevated assignment
$elev = New-EvoElevatedAssignment -Name 'Tier 2 Support' -Description 'Technician elevation'

# Add members
Add-EvoElevatedAssignmentUser -ElevatedAssignmentId $elev.id -UserIdList $userIds
Add-EvoElevatedAssignmentGroup -ElevatedAssignmentId $elev.id -GroupIdList $groupIds

# Add domain accounts
Add-EvoElevatedAssignmentDomainAccount -ElevatedAssignmentId $elev.id -DomainAccountIdList $domainAccountIds
```

---

### 4.8 Domain Accounts

```powershell
# List domain accounts
Get-EvoDomainAccount -Type manual -Active 'true'

# Get a specific domain account
Get-EvoDomainAccount -Id 'DOMAIN_ACCOUNT_GUID'
```

---

### 4.9 Health Check

```powershell
Test-EvoPartnerApiHealth
```

---

## 5. MSP Scenario Examples

### 5.1 Onboard a new tenant end-to-end

1. **Create tenant**

   ```powershell
   $tenant = New-EvoTenant -Name 'customer-01'
   ```

2. **Create Evo Cloud Directory** (Only if you are not using AzureAD, LDAP, Google Workspace directory)

   ```powershell
   $dir = New-EvoDirectory -Name 'Customer-01-Directory' -TenantId $tenant.id
   ```

3. **Import users from CSV & create them**

   ```powershell
   Import-Csv .\customer01-users.csv | New-EvoUserBulk
   ```

4. **Assign licenses (per tenant or globally)**

   ```powershell
   $license = Get-EvoLicense -Id 'LICENSE_GUID'
   $userIds = Get-EvoUser -All | Where-Object { $_.directory.id -eq $dir.id } | Select-Object -ExpandProperty id
   Add-EvoLicenseAssignment -LicenseId $license.id -UserIdList $userIds
   ```

5. **Grant tenant access**

   ```powershell
   Add-EvoTenantAccess -TenantId $tenant.id -UserIdList $userIds
   ```

6. **Send welcome emails**

   ```powershell
   $userIds | Send-EvoUserWelcomeEmail
   ```

---
