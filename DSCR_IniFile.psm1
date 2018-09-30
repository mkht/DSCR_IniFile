$modulePath = $PSScriptRoot
$subModulePath = '\DSCResources\cIniFile\cIniFile.psm1'

Import-Module (Join-Path $modulePath $subModulePath)
