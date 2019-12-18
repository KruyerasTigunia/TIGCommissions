
. '.\PowerShell\Settings.ps1'

New-BCContainer `
    -accept_eula `
    -containerName $DevContainerName `
    -imageName $ImageName `
    -licenseFile $LicenseFile `
    -auth NavUserPassword `
    -updateHosts `
    -Credential $Credential #`
    #-alwaysPull `
    #-isolation hyperv `
    #-doNotExportObjectsToText #`
    #-includeTestToolkit `

