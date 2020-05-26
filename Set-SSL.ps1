# RunAs block. (c) Ben Armstrong (https://docs.microsoft.com/ru-ru/archive/blogs/virtual_pc_guy/a-self-elevating-powershell-script)

# Get the ID and security principal of the current user account
$myWindowsID = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal = new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
# Get the security principal for the Administrator role
$adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator
# Check to see if we are currently running "as Administrator"
if ($myWindowsPrincipal.IsInRole($adminRole)) {
    # We are running "as Administrator" - so change the title and background color to indicate this
    $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + " (ELEVATED)"
    $Host.UI.RawUI.BackgroundColor = "Black"
    Clear-Host
}
else {
    # We are not running "as Administrator" - so relaunch as administrator
    # Create a new process object that starts PowerShell
    $newProcess = New-Object System.Diagnostics.ProcessStartInfo "PowerShell"
    # Specify the current script path and name as a parameter
    $newProcess.Arguments = $myInvocation.MyCommand.Definition
    # Indicate that the process should be elevated
    $newProcess.Verb = "runas"
    # Start the new process
    [System.Diagnostics.Process]::Start($newProcess)
    # Exit from the current, unelevated, process
    exit
}

$Protocols = @{
    "SSL 2.0" = @{
        "Server" = $false;
        "Client" = $false;
    };
    "SSL 3.0" = @{
        "Server" = $false;
        "Client" = $false;
    };
    "TLS 1.0" = @{
        "Server" = $false;
        "Client" = $false;
    };
    "TLS 1.1" = @{
        "Server" = $false;
        "Client" = $false;
    };
    "TLS 1.2" = @{
        "Server" = $true;
        "Client" = $true;
    };
}

$SChannel = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\" `
    + "SCHANNEL\Protocols"

try {
    foreach ($Protocol in $Protocols.Keys) {
        foreach ($Direction in $Protocols[$Protocol].Keys) {
            New-Item -Path "$SChannel\$Protocol\$Direction" -Type Directory -Force `
            | Out-Null
            New-ItemProperty -Path "$SChannel\$Protocol\$Direction"  `
                -Name "Enabled" -PropertyType "DWORD" `
                -Value ([int]$Protocols[$Protocol][$direction]) | Out-Null
            New-ItemProperty -Path "$SChannel\$Protocol\$Direction"  `
                -Name "DisabledByDefault" -PropertyType "DWORD" `
                -Value ([int]!$Protocols[$Protocol][$direction]) | Out-Null
        }
    }
    Write-Host "Protocols updated successfully" -ForegroundColor Green
} catch {
    Write-Warning "Unable to update registry values"
}

$UpdDotNet = Read-Host "Enforce TLS 1.2 for .Net Framework client? (y/n)"

if ($UpdDotNet.ToLower() -eq "y") {
    try {
        $RegPathX86 = "HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319"
        $RegPathX64 = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319"

        ($RegPathX64, $RegPathX86) | `
        ForEach-Object {New-ItemProperty -Path $_ -Name "SchUseStrongCrypto" `
        -PropertyType "DWORD" -Value 1 -Force | Out-Null}
        Write-Host ".Net Framework client TLS parameters updated successfully" -ForegroundColor Green
    } catch {
        Write-Warning "Unable to update .Net Framework client TLS parameters"
    }
}

Read-Host -Prompt "Press Enter to continue"