# --------------------------------------------------------------------------------------------- # 
# Author(s)    : Peter Klapwijk - www.InTheCloud247.com, Andrew Meyercord			#
# Original: https://github.com/PeterKlapwijk/PowerShell/tree/main/ActivateEmbeddedProductKey	#
# Version      : 1.0                                                                            #
#                                                                                               #
# Description  : Detection script to be used with Microsoft Intune, determines if Windows 	#
#			is Activated								#
#                										#
# Changes      :v1.1 optimized WMI query and updated activation status check			#
#		v1.0 Initial version	                                                        #
#                										#
# --------------------------------------------------------------------------------------------- #

$windowsProduct = Get-WmiObject SoftwareLicensingProduct -Filter "partialproductkey is not null" | Where-Object {$_.ApplicationID -eq '55c92734-d682-4d71-983e-d6ec3f16059f'}

if {$windowsProduct.LicenseStatus -eq '1'){
	$productKeyChannel = $windowsProduct.ProductKeyChannel
 	if ("OEM:DM", "Retail" -contains $productKeyChannel){
 		write-host "Correct ProductKeyChannel found = "$productKeyChannel""
   		exit 0
   	} else {
    		write-host "ERROR: Wrong ProductKeyChannel found =  "$productKeyChannel""
      		exit 1
      	}
} else {
	write-host "ERROR: Not activated"
 	exit 2
}
