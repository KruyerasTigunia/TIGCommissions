
. '.\PowerShell\Settings.ps1'

New-BCContainer `
    -accept_eula `
    -containerName $TestContainerName `
    -imageName $ImageName `
    -licenseFile $LicenseFile `
    -auth NavUserPassword `
    -updateHosts `
    -Credential $Credential `
    -includeTestToolkit #`
    #-isolation hyperv `
    #-doNotExportObjectsToText #`

