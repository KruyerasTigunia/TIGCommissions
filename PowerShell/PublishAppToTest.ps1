
. '.\PowerShell\Settings.ps1'

Publish-BCContainerApp `
    -containerName $TestContainerName `
    -appFile $AppFileName `
    -sync `
    -install `
    -skipVerification
