set windows-shell := ["pwsh", "-NoLogo", "-NoProfileLoadTime", "-Command"]

path := if os() == 'windows' { env('PATH') + ";" + justfile_directory() + "/love" } else { env('PATH') }
export PATH := path
export LUA_CPATH := "./lib/target/release/lib?.so;./lib/target/release/?.dll"
lovec := if os() == 'windows' { "lovec" } else { "love" }

[parallel]
test: setup-love build
    {{ lovec }} runtime /test

[working-directory('lib')]
build:
    cargo build --release

[linux]
setup-love:
    @# Included in nix development shell
    which love

[windows]
setup-love:
    #!pwsh
    $ErrorActionPreference = 'Stop'
    if (Test-Path love) {
        Remove-Item -Path love -Recurse
    }
    New-Item -Type dir -Force love | Out-Null
    $love = Resolve-Path love

    $zip = New-TemporaryFile
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri "https://github.com/love2d/love/releases/download/11.5/love-11.5-win64.zip" -OutFile $zip
    Expand-Archive $zip -DestinationPath $love -Force
    Remove-Item $zip
    Get-ChildItem -Path $love -Recurse -File | Move-Item -Destination $love
    Get-ChildItem -Path $love -Recurse -Directory | Remove-Item
