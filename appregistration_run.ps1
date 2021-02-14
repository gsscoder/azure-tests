# Script version: 0.1.0
param (
    [Alias('e', 'env')] [Parameter(Mandatory)] [string] $Environment
)

Set-StrictMode -Version Latest

$container = New-PesterContainer -Path 'appregistration_tests.ps1' `
    -Data @{
        TestDataPath = 'appregistration_tests_data.json'
        Environment =  $Environment }

Invoke-Pester -Container $container -Output Detailed