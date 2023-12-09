# --------------------------------------------------------------------------------------------- # 
# Author(s)    : Peter Klapwijk - www.InTheCloud247.com, Andrew Meyercord	                #
# Version      : 1.1                                                                            #
#                                                                                               #
# Description  : Script retrieves the firmware-embedded product key and activates Windows       #
#                with this key									#
#                										#
# Changes      : v1.1 replaced cscript with native cmdlets, optimized WMI query			#
#		 v1.0 Initial version	                                                        #
#                										#
# --------------------------------------------------------------------------------------------- #

# Start Transcript
$Transcript = "C:\programdata\Microsoft\IntuneManagementExtension\Logs$($(Split-Path $PSCommandPath -Leaf).ToLower().Replace(".ps1",".log"))"
Start-Transcript -Path $Transcript | Out-Null

#Get Licensing service instance
try {
    $service = get-wmiObject -query "select * from SoftwareLicensingService
} catch {
    write-host "ERROR: failed to obtain licensing service instance"
    Exit 1
}
 
#Get firmware-embedded product key
try {
    $EmbeddedKey=$service.OA3xOriginalProductKey
    write-host "Firmware-embedded product key: $EmbeddedKey"
} catch {
    write-host "ERROR: Failed to retrieve firmware-embedded product key"
    Exit 2
}

#Install embedded key
try {
    $service.installproductkey($EmbeddedKey)
    write-host "Installed license key"
} catch {
    write-host "ERROR: Changing license key failed"
    Exit 3
}

#Active embedded key
try {
    $service.RefreshLicenseStatus()
    $windowsProduct | get-ciminstance #refresh product attributes
    if ($windowsProduct.LicenseStatus -eq '1'){ 
    	write-host "Activated - ProductKeyChannel $($windowsProduct.ProductKeyChannel)"
     	exit 0
     } else {
     	throw "Activation failed"
      	exit 4
      }
} catch {
    write-host "ERROR: Unable to verify activation"
    Exit 5
}

<# Don't care about the product key channel as long as it's activated
# Check Product Key Channel
$getreg = Get-WmiObject SoftwareLicensingProduct -Filter "partialproductkey is not null" | Where-Object {$_.ApplicationID -eq '55c92734-d682-4d71-983e-d6ec3f16059f' -and $_.LicenseStatus -eq '1'}
$ProductKeyChannel=$getreg.ProductKeyChannel
    if ($getreg.ProductKeyChannel -eq "OEM:DM") {
        write-host "Windows activated, ProductKeyChannel = $ProductKeyChannel"
		Exit 0
    } else {
		write-host "ERROR: Wrong ProductKeyChannel: $ProductKeyChannel"
		Exit 5
    }
#>
Stop-Transcript
