$ErrorActionPreference = "Stop"

$status = (git status)
$clean = $status| select-string "working tree clean"

if ("$clean" -eq "")
{
  echo "Working copy is not clean. Cannot proceed."
  exit
}

pushd ..
if (Test-Path "Sustainsys.Saml2\bin\Release")
{
	del Sustainsys.Saml2\bin\Release\*.dll
}
if (Test-Path "Sustainsys.Saml2.Mvc\bin\Release")
{
	del Sustainsys.Saml2.Mvc\bin\Release\*.dll
}
if (Test-Path "Sustainsys.Saml2.Owin\bin\Release")
{
	del Sustainsys.Saml2.Owin\bin\Release\*.dll
}
if (Test-Path "Sustainsys.Saml2.HttpModule\bin\Release")
{
	del Sustainsys.Saml2.HttpModule\bin\Release\*.dll
}
if (Test-Path "Sustainsys.Saml2.AspNetCore2\bin\Release")
{
	del Sustainsys.Saml2.AspNetCore2\bin\Release\*.dll
}
echo "Creating nuspec files..."

$releaseNotesContent="`n $((get-content nuget\ReleaseNotes.txt) -join "`n`")`n";
$releaseNotes = "<releaseNotes>" + $releaseNotesContent + "</releaseNotes>";
function Create-Nuspec($projectName)
{
    (gc nuget\$projectName.nuspec) | 
		% { $_ -replace "<releaseNotes />", $releaseNotes } |
		set-content $projectName\$projectName.nuspec
}

function Update-Csproj($projectName)
{
    (gc $projectName\$projectName.csproj) | 
		% { $_ -replace '\$releaseNotes\$', $releaseNotesContent } |
		set-content $projectName\$projectName.csproj
}

copy Sustainsys.Saml2\Sustainsys.Saml2.csproj Sustainsys.Saml2\Sustainsys.Saml2.csproj.bak
copy Sustainsys.Saml2.AspNetCore2\Sustainsys.Saml2.AspNetCore2.csproj Sustainsys.Saml2.AspNetCore2\Sustainsys.Saml2.AspNetCore2.csproj.bak
Update-Csproj("Sustainsys.Saml2")
Create-Nuspec("Sustainsys.Saml2.Mvc")
Create-Nuspec("Sustainsys.Saml2.Owin")
Create-Nuspec("Sustainsys.Saml2.HttpModule")
Update-Csproj("Sustainsys.Saml2.AspNetCore2")

echo "Building packages..."

dotnet pack -c Release -o ..\nuget Sustainsys.Saml2\Sustainsys.Saml2.csproj /p:Version=0.24.999
dotnet pack -c Release -o ..\nuget Sustainsys.Saml2.AspNetCore2\Sustainsys.Saml2.AspNetCore2.csproj /p:Version=0.24.999

copy Sustainsys.Saml2\Sustainsys.Saml2.csproj.bak Sustainsys.Saml2\Sustainsys.Saml2.csproj
del Sustainsys.Saml2\Sustainsys.Saml2.csproj.bak 
copy Sustainsys.Saml2.AspNetCore2\Sustainsys.Saml2.AspNetCore2.csproj.bak Sustainsys.Saml2.AspNetCore2\Sustainsys.Saml2.AspNetCore2.csproj
del Sustainsys.Saml2.AspNetCore2\Sustainsys.Saml2.AspNetCore2.csproj.bak 

popd
