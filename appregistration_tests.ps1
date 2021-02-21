# Script version: 0.1.3
param (
    [Parameter(Mandatory)] [string] $TestDataPath,
    [Parameter(Mandatory)] [string] $Environment
)

Set-StrictMode -Version Latest
Join-Path (Split-Path -parent $MyInvocation.MyCommand.Path) 'core.psm1' | Import-Module -Verbose:$false -DisableNameChecking

BeforeAll {
    $script:TestData = (Get-Content -Path $TestDataPath -Raw | ConvertFrom-Json).$Environment
    $script:Resources = @()
}

Describe 'Production' {
    It 'Can connect' {
        Connect-Azure -TenantId $script:TestData.authTenantId `
                      -ApplicationId $script:TestData.appRegId `
                      -ApplicationSecret $script:TestData.appRegSecret
    }

    It 'Can switch subscription' {
        $script:TestData.targetSubsciptionId | Set-Subscription
    }

    It 'Can read' {
        $outcome = Get-AzResource -ResourceGroupName $script:TestData.resGroups[0] -ErrorAction Ignore
        $outcome | Should -Not -BeNull
        $outcome.Count | Should -BeGreaterThan 0
    }

    It 'Can write' {
        foreach ($resGroup in $script:TestData.resGroups) {
            $resName = "test$(20 | Get-RandomString)"
            "Attempting creation: $resName ($resGroup)." | Out-Highlight
            $outcome = New-AzResource -ResourceGroupName $resGroup -Location (Get-AzResourceGroup -Name $resGroup).Location `
                -ResourceName $resName -Properties @{} -ResourceType 'Microsoft.Web/sites' -Tag @{'purpose' = 'test'} `
                -Force -ErrorAction Ignore
            $script:Resources += @{ resGroup = $resGroup; resName = $resName }
            $outcome | Should -Not -BeNull -Because "Cannot write to resource group '$resGroup'."
        }
    }

    It 'Can delete' {
        foreach ($resource in $script:Resources) {
            "Attempting removal: $($resource.resName) ($($resource.resGroup))." | Out-Highlight
            $outcome = Remove-AzResource -ResourceGroupName $resource.resGroup -ResourceName $resource.resName `
                -ResourceType 'Microsoft.Web/sites' -Force -ErrorAction Ignore
            $outcome | Should -BeTrue
        }
    }
}