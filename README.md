# Azure Tests

This repository is meant to share some [Pester](https://github.com/pester/Pester) tests to keep an eye and validate your [Azure](https://azure.microsoft.com/en-us/) infrastructure.

For now it's available just a test for validating an app registration against a set of resource groups.

## Dependencies

- PowerShell 5.1 or higher
- Pester 5.1.1 or higher

## Configure

Just edit `appregistration_tests_data.json`:

```json
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
  [+] Can connect 2.34s (2.27s|78ms)
Setting context to Subscription ID '170cf92d-760c-4921-baec-29748a9753fa'.
  [+] Can switch subscription 1.86s (1.85s|3ms)
  [+] Can read 1.78s (1.78s|3ms)
Attempting creation: testowTerhEYo3N1gQ80qFzS (GROUPONE-Europe-QTA).
Attempting creation: test3aaeKRveD3hd0aawB8YN (GROUPTWO-Europe-QTA-win).
  [+] Can write 50.99s (50.98s|6ms)
Attempting test resources removal.
Tests completed in 70.18s
Tests Passed: 4, Failed: 0, Skipped: 0 NotRun: 0
```
