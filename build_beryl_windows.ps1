function VsVarsAll() {
	$cmd = "vcvarsall.bat x64 & set"
	cmd /c $cmd | Foreach-Object {
		$p, $v = $_.split('=')
		Set-Item -path env:$p -value $v
	}
}

VsVarsAll
Push-Location -StackName 'DirStack'
Set-Location .\lib
New-Item -Name builddir -ItemType Directory -Force | Out-Null
meson builddir --backend ninja --buildtype release
Set-Location builddir
ninja
Pop-Location -StackName 'DirStack'
Copy-Item .\lib\builddir\beryl.dll .\game
