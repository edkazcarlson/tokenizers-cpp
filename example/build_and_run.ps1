# PowerShell build and run script for Windows

# build
if (-not (Test-Path "build")) {
    New-Item -ItemType Directory -Path "build" | Out-Null
}
Set-Location build
cmake ..
cmake --build . --config Release -j8
Set-Location ..

# get example files
if (-not (Test-Path "dist")) {
    New-Item -ItemType Directory -Path "dist" | Out-Null
}
Set-Location dist

if (-not (Test-Path "tokenizer.model")) {
    Invoke-WebRequest -Uri "https://huggingface.co/lmsys/vicuna-7b-v1.5/resolve/main/tokenizer.model" -OutFile "tokenizer.model"
}
if (-not (Test-Path "tokenizer.json")) {
    Invoke-WebRequest -Uri "https://huggingface.co/togethercomputer/RedPajama-INCITE-Chat-3B-v1/resolve/main/tokenizer.json" -OutFile "tokenizer.json"
}
if (-not (Test-Path "tokenizer_model")) {
    Invoke-WebRequest -Uri "https://github.com/BBuf/run-rwkv-world-4-in-mlc-llm/releases/download/v1.0.0/tokenizer_model.zip" -OutFile "tokenizer_model.zip"
    Expand-Archive -Path "tokenizer_model.zip" -DestinationPath "." -Force
}
if (-not (Test-Path "vocab.json")) {
    Invoke-WebRequest -Uri "https://huggingface.co/Qwen/Qwen2.5-3B-Instruct/resolve/main/vocab.json" -OutFile "vocab.json"
}
if (-not (Test-Path "merges.txt")) {
    Invoke-WebRequest -Uri "https://huggingface.co/Qwen/Qwen2.5-3B-Instruct/resolve/main/merges.txt" -OutFile "merges.txt"
}
Set-Location ..

# run
Write-Host "---Running example----"
$exePath = $null
if (Test-Path "build\Release\example.exe") {
    $exePath = "build\Release\example.exe"
} elseif (Test-Path "build\example.exe") {
    $exePath = "build\example.exe"
} elseif (Test-Path "build\Debug\example.exe") {
    $exePath = "build\Debug\example.exe"
}

if ($exePath) {
    & $exePath
} else {
    Write-Host "Error: example executable not found"
    Write-Host "Searched in:"
    Write-Host "  - build\Release\example.exe"
    Write-Host "  - build\example.exe"
    Write-Host "  - build\Debug\example.exe"
    exit 1
}

