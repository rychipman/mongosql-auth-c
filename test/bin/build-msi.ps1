<#
.SYNOPSIS
    Builds an MSI for mongosqd.exe and mongodrdl.exe.
.DESCRIPTION
    .
.PARAMETER ProjectName
    The name to use when referring to the project.
.PARAMETER VersionLabel
    The label to use when referring to this version of the
    project.
.PARAMETER WixPath
    The path to the WIX binaries.
#>
Param(
  [string]$ProjectName,
  [string]$VersionLabel,
  [string]$WixPath
)

$wixUiExt = "$WixPath\WixUIExtension.dll"
$sourceDir = pwd
$resourceDir = "$sourceDir\installers\msi\mongosql-auth\"
$artifactsDir = "$sourceDir\test\artifacts\"
$objDir = "$artifactsDir\out\"
$binDir = "$artifactsDir\out\"

if (-not ($VersionLabel -match "(\d\.\d).*")) {
    throw "invalid version specified: $VersionLabel"
}
$version = $matches[1]

$upgradeCode = "3f021824-c333-49f5-9cbf-d6de9b6adacc"

# compile wxs into .wixobjs
& $WixPath\candle.exe -wx `
    -dProductId="*" `
    -dUpgradeCode="$upgradeCode" `
    -dVersion="$version" `
    -dVersionLabel="$VersionLabel" `
    -dProjectName="$ProjectName" `
    -dSourceDir="$sourceDir" `
    -dResourceDir="$resourceDir" `
    -dSslDir="$binDir" `
    -dBinaryDir="$binDir" `
    -dTargetDir="$objDir" `
    -dTargetExt=".msi" `
    -dTargetFileName="release" `
    -dOutDir="$objDir" `
    -dConfiguration="Release" `
    -arch "x64" `
    -out "$objDir" `
    -ext "$wixUiExt" `
    "$resourceDir\Product.wxs" `
    "$resourceDir\FeatureFragment.wxs" `
    "$resourceDir\BinaryFragment.wxs" `
    "$resourceDir\LicensingFragment.wxs" `
    "$resourceDir\UIFragment.wxs"

if(-not $?) {
    exit 1
}

# link wixobjs into an msi
& $WixPath\light.exe -wx `
    -cultures:en-us `
    -out "$artifactsDir\release.msi" `
    -ext "$wixUiExt" `
    $objDir\Product.wixobj `
    $objDir\FeatureFragment.wixobj `
    $objDir\BinaryFragment.wixobj `
    $objDir\LicensingFragment.wixobj `
    $objDir\UIFragment.wixobj
