Push-Location -StackName 'DirStack'
Set-Location .\lib\diamond
cargo build
Pop-Location -StackName 'DirStack'
Copy-Item .\lib\diamond\target\debug\diamond.dll .\game
