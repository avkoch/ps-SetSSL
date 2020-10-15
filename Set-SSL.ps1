# To update registry files it required to preliminary rename and configure
# respective files in "Parameters" folder

if (-not (Test-Path .\..\ps_CommonScripts\Import-JSONtoRegistry.ps1)) {
    Write-Warning ("Required script '..\ps_CommonScripts\Import-JSONtoRegistry.ps1' not found")
    exit
}

. .\..\ps_CommonScripts\Import-JSONtoRegistry.ps1

#-------------------------------------------------------------------------------
function Set-SecProtocols {
    if (-not (Test-Path .\Parameters\Protocols.ps1)) {
        Write-Warning "No config file for protocols was found"
        return
    }

    . .\Parameters\Protocols.ps1

    $Result = Import-JSONtoRegistry $Protocols $ProtocolsPath

    if (-not $Result) {Write-Warning "Unable to set protocols"}
}
#-------------------------------------------------------------------------------
function Set-SecNetFX {
    if (-not (Test-Path .\Parameters\NetFX.ps1)) {
        Write-Warning "No config file for NetFx was found"
        return
    }

    . .\Parameters\NetFX.ps1

    $NetFxPath | ForEach-Object {
        $Result = Import-JSONtoRegistry $NetFX $_
        if (-not $Result) {Write-Warning "Unable to set NetFx security"}
    }
}
#-------------------------------------------------------------------------------
function Set-SecCyphers {
    if (-not (Test-Path .\Parameters\Cyphers.ps1)) {
        Write-Warning "No config file for cyphers was found"
        return
    }

    . .\Parameters\Cyphers.ps1

    $Result = Import-JSONtoRegistry $Cyphers $SChannelPath

    if (-not $Result) {Write-Warning "Unable to set cyphers"}
}
#-------------------------------------------------------------------------------
function Set-SecHashes {
    if (-not (Test-Path .\Parameters\Hashes.ps1)) {
        Write-Warning "No config file for hashes was found"
        return
    }

    . .\Parameters\Hashes.ps1

    $Result = Import-JSONtoRegistry $Hashes $SChannelPath

    if (-not $Result) {Write-Warning "Unable to set hashes"}
}#-------------------------------------------------------------------------------
function Set-SecKeyExchange {
    if (-not (Test-Path .\Parameters\KeyExchange.ps1)) {
        Write-Warning "No config file for key exchange was found"
        return
    }

    . .\Parameters\KeyExchange.ps1

    $Result = Import-JSONtoRegistry $KeyExchange $SChannelPath

    if (-not $Result) {Write-Warning "Unable to set key exchange"}
}
#-------------------------------------------------------------------------------
function Set-SecWinHttpAPI {
    if (-not (Test-Path .\Parameters\WinHttpAPI.ps1)) {
        Write-Warning "No config file for WinHttpAPI was found"
        return
    }

    . .\Parameters\WinHttpAPI.ps1

    $WinHttpPath | ForEach-Object {
        $Result = Import-JSONtoRegistry $WinHttpAPI $_
        if (-not $Result) {Write-Warning "Unable to set WinHttpAPI security"}
    }
}
#===============================================================================
Set-SecProtocols
Set-SecNetFX
Set-SecCyphers
Set-SecHashes
Set-SecKeyExchange
Set-SecWinHttpAPI