# Module version: 0.1.0
Set-StrictMode -Version Latest

$script:DevOps = $false

function Set-Environment {
    [OutputType([void])]
    param (
        [Parameter(Mandatory)] [switch] $DevOps
    )
    $script:DevOps = $DevOps
}

function Out-Section {
    [OutputType([void])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)] [string] $Message
    )
    if ($scirpt:DevOps) { "##[section]$Message" | Write-Host } else { $Message  | Write-Host -ForegroundColor Green }
}

function Out-Warning {
    [OutputType([void])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)] [string] $Message
    )
    if ($scirpt:DevOps) { "##[warning]$Message" | Write-Host } else { $Message | Write-Warning }
}

function Out-Error {
    [OutputType([void])]
    param (
        [Parameter(ValueFromPipeline)] [string] $Message,
        [switch] $StdOut
    )
    if ($scirpt:DevOps) { "##[error]$Message"  | Write-Host } else {
        if ($StdOut) { $Message | Write-Host -ForegroundColor Red } else { $Message | Write-Error }
    }
}

function Out-Highlight {
    [OutputType([void])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)] [string] $Message
    )
    if ($scirpt:DevOps) { "##[section]$Message" | Write-Host } else { $Message | Write-Host -ForegroundColor Cyan }
}

function Get-RandomString {
    [OutputType([string])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)] [int] $Length,
        [bool] $Alphanumeric = $true,
        [bool] $NoQuotes = $false
    )
    [char[]] $alphanumericChars = 'abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    [char[]] $allChars = "abcdefghijklmnopqrstuvwxyz0123456789!`"#$%&'()*@[\\]^_``{|}~ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    [char[]] $allCharsNoQuotes = 'abcdefghijklmnopqrstuvwxyz0123456789!#$%&()*@[\\]^_{|}~ABCDEFGHIJKLMNOPQRSTUVWXYZ'

    if ($NoQuotes -and $Alphanumeric) { throw '-NoQuotes cannot be true when -Alphanumeric is true.' }
    $chars = if ($Alphanumeric) { $alphanumericChars } else {
                if ($NoQuotes) { $allCharsNoQuotes } else { $allChars } }
    $result = [System.Text.StringBuilder]::new($Length)
    $random = [System.Random]::new()
    for ($i = 0; $i -lt $Length; $i++) {
        $result.Append($chars[$random.Next($chars.Length)]) | Out-Null
    }
    $result.ToString()
}

function Hide {
    [CmdletBinding(DefaultParameterSetName = 'show')]
    [OutputType([string])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string] $Text,
        [Parameter(Mandatory, ParameterSetName = 'show')]
        [int] $Show,
        [Parameter(Mandatory, ParameterSetName = 'sensitive')]
        [switch] $HighlySensitive,
        [object] $Pad
    )
    if ($PSCmdlet.ParameterSetName -ceq 'show') {
        $plain = $Text.Substring(0, $Show);
        $hidden = '*' * ($Text.Length - $Show)
        $Result = "$($plain)$($hidden)"
        if ($Pad) {
            $Result = $Result.PadRight($Pad, '*')
        }
        return $Result
    }
    if ($HighlySensitive) {
        $Text | Hide -Show 3 -Pad $Pad
    } else {
        $Text | Hide -Show ($Text.Length / 3) -Pad $Pad 
    }
}

function Connect-Azure {
    [CmdletBinding(DefaultParameterSetName = 'default')]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory, ParameterSetName = 'default')] [ValidateScript({
            try { [System.Guid]::Parse($_) | Out-Null; $true } catch { $false }
        })] [string] $TenantId,
        [Parameter(ParameterSetName = 'default')] [ValidateScript({
            if (-not $_) { $true }; try { [System.Guid]::Parse($_) | Out-Null; $true } catch { $false }
        })] [string] $SubscriptionId,
        [Parameter(Mandatory, ParameterSetName = 'default')] [string] [ValidateScript({
            try { [System.Guid]::Parse($_) | Out-Null; $true } catch { $false }
        })] [string] $ApplicationId,
        [Parameter(Mandatory, ParameterSetName = 'default')]  [ValidatePattern('^\S+$')]
            [string] $ApplicationSecret,
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'object')] [PSCustomObject] $InputObject
    )
    if ($PSCmdlet.ParameterSetName -ceq 'default') {
        'Attempting connection.' | Write-Host
        "Tenant ID:          $TenantId" | Write-Host
        "Subscription ID:    $(if ($SubscriptionId) { $SubscriptionId } else { '-' })" | Write-Host
        "Application ID:     $($ApplicationId | Hide -HighlySensitive:$false)" | Write-Host
        "Application Secret: $($ApplicationSecret | Hide -HighlySensitive -Pad 36)`n" | Write-Host
        $password = ConvertTo-SecureString $ApplicationSecret -AsPlainText -Force
        $credential = [System.Management.Automation.PSCredential]::new($ApplicationId, $password)
        try {
            switch (-not $SubscriptionId) {
                default { Connect-AzAccount -Credential $credential -Tenant $TenantId -ServicePrincipal | Out-Null }
                $false  { Connect-AzAccount -Credential $credential -Tenant $TenantId -ServicePrincipal -Subscription $SubscriptionId | Out-Null }
            }
        }
        catch {
            "Unable to connect to Azure.`n$_" | Out-Error
            return $false
        }
        return $true
    }
    return Connect-Azure -TenantId $InputObject.tenantId -SubscriptionId $InputObject.subscriptionId `
                         -ApplicationId $InputObject.applicationId -ApplicationSecret $InputObject.applicationSecret
}

function Set-Subscription {
    [OutputType([bool])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)] [string] $Id
    )
    "Setting context to Subscription ID '$Id'." | Write-Host
    try {
        Set-AzContext -SubscriptionId $Id | Out-Null
    } catch {
        "Unable to set context with Subscription ID '$Id'.`n$?" | Out-Error
        return $false
    }
    $true
}

Export-ModuleMember -Function Set-Environment, Out-Section, Out-Warning, Out-Error, Out-Highlight, Get-RandomString, Hide, `
    Set-Subscription, Connect-Azure