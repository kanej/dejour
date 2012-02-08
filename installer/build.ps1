$wixcandle = 'C:\Program Files (x86)\Windows Installer XML v3.5\bin\candle.exe'
$wixlight = 'C:\Program Files (x86)\Windows Installer XML v3.5\bin\light.exe'
$wixheat = 'C:\Program Files (x86)\Windows Installer XML v3.5\bin\heat.exe'
$wixUIExtentsion = 'C:\Program Files (x86)\Windows Installer XML v3.5\bin\WixUIExtension.dll'

function generate-wixfragment-from-dir($sourcedir, $targetdir) {
  $capitalisedTargetDir= $targetdir.substring(0,1).ToUpper()+$targetdir.substring(1)
  $componentGroup = $capitalisedTargetDir + "ComponentGroup"
  $directoryVar = $targetdir + "Dir"

  & $wixheat dir .\$sourcedir -nologo -srd -gg -sfrag -template fragment -cg $componentGroup -dr $directoryVar -var var.$directoryVar -out tmp\$targetdir.wxs 
}

# Create a temporary folder for intermediary wix outputs
mkdir -force tmp | out-null

# Copy or generate all the wix fragments that will be used to build the installer
# into the tmp directory
cp .\installer\dejour.wxs .\tmp\dejour.wxs
cp .\installer\License.rtf .\tmp\License.rtf
cp -r .\installer\images .\tmp\images
generate-wixfragment-from-dir -sourcedir bin -targetdir bin
generate-wixfragment-from-dir -sourcedir examples -targetdir examples
generate-wixfragment-from-dir -sourcedir "downloads/complete-1.3.0" -targetdir lib

# Build the msi using wix
& $wixcandle -nologo .\tmp\*.wxs -o .\tmp\ -dbinDir=bin -dexamplesDir=examples "-dlibDir=downloads/complete-1.3.0" -dsyslibDir=downloads/jline

& $wixlight -nologo .\tmp\*.wixobj -o .\build\dejour.msi -ext $wixUIExtentsion

# Remove the no longer needed temporary folder
rm -r tmp | out-null
