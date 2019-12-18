
. '.\PowerShell\Settings.ps1'

docker login "bcinsider.azurecr.io" -u "2151f4c8-8fc2-4c87-a360-4f6c73ed8636" -p "6=8EOnWN7yqV7?H/u?301O6nP05grB:N"

New-BCContainer `
    -accept_eula `
    -containerName $InsiderContainerName `
    -imageName $InsiderImageName `
    -alwaysPull `
    -licenseFile $LicenseFile `
    -auth NavUserPassword `
    -updateHosts `
    -Credential $Credential #`
    #-alwaysPull `
    #-isolation hyperv `
    #-doNotExportObjectsToText #`
    #-includeTestToolkit `

