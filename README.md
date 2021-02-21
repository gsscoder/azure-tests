# Azure Tests

This repository is meant to share some [Pester](https://github.com/pester/Pester) tests to keep an eye and validate your [Azure](https://azure.microsoft.com/en-us/) infrastructure.

For now it's available just a test for validating an app registration against a set of resource groups.

## Dependencies

- PowerShell 5.1 or higher
- Pester 5.1.1 or higher

## Configure

Just edit `appregistration_tests_data.json`:

```yaml
{
    "production": {
        "authTenantId": "{your_authentication_tenant}",
        "targetSubsciptionId": "{your_target_subscription}",
        "appRegId": "{your_app_registration_id}",
        "appRegSecret": "{your_app_registration_secret}",
        "resGroups": [
            "{your_resource_group_one}",
            "{your_resource_group_two}" ]
    },
    "quality": {
        "authTenantId": "{your_authentication_tenant}",
        "targetSubsciptionId": "{your_target_subscription}",
        "appRegId": "{your_app_registration_id}",
        "appRegSecret": "{your_app_registration_secret}",
        "resGroups": [
            "{your_resource_group_one}",
            "{your_resource_group_two}" ]
    }
}
```

Each root property defines a different Azure enviroment.

## Execute

Invoke `appregistration_run.ps1` specifying the `-Environment` parameter:

```powershell
$ .\appregistration_run.ps1 -e quality

Starting discovery in 1 files.
Discovering in C:\sources\azure-tests\appregistration_tests.ps1.
Found 4 tests. 168ms
Discovery finished in 289ms.

Running tests from 'C:\sources\azure-tests\appregistration_tests.ps1'
Describing Production
Attempting connection.
Tenant ID:          f81961d8-919a-49f5-977c-10fc8d15ad8d
Subscription ID:    -
Application ID:     ja75IABSasAS************************
Application Secret: mmh*********************************

WARNING: The provided service principal secret will be included in the 'AzureRmContext.json' file found in the user profile ( C:\Users\coder\.Azure ). Please ensure that this directory has appropriate protections.
WARNING: TenantId 'f81961d8-919a-49f5-977c-10fc8d15ad8d' contains more than one active subscription. First one will be selected for further use. To select another subscription, use Set-AzContext.
  [+] Can connect 3.63s (3.56s|77ms)
Setting context to Subscription ID '61ef86a4-bbfd-425a-a8a0-ab024791e4bd'.
  [+] Can switch subscription 1.85s (1.84s|3ms)
  [+] Can read 1.89s (1.87s|27ms)
Attempting creation: testCKa6XqP0XEJ71FyxxZ3u (INTRANETAI-Europe-DEV-SH).
  [+] Can write 26.57s (26.56s|1ms)
Attempting removal: testCKa6XqP0XEJ71FyxxZ3u (INTRANETAI-Europe-DEV-SH).
  [+] Can delete 4.83s (4.78s|43ms)
Tests completed in 39.68s
Tests Passed: 5, Failed: 0, Skipped: 0 NotRun: 0
```
