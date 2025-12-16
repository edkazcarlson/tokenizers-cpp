#!/bin/bash

# build
mkdir -p build
cd build
cmake ..
cmake --build . --config Release -j8
cd ..
# get example files

mkdir -p dist
cd dist
if [ ! -f "tokenizer.model" ]; then
    curl -fSL -o tokenizer.model https://huggingface.co/lmsys/vicuna-7b-v1.5/resolve/main/tokenizer.model
fi
if [ ! -f "tokenizer.json" ]; then
    curl -fSL -o tokenizer.json https://huggingface.co/togethercomputer/RedPajama-INCITE-Chat-3B-v1/resolve/main/tokenizer.json
fi
if [ ! -f "vocab.json" ]; then
    curl -fSL -o vocab.json https://huggingface.co/Qwen/Qwen2.5-3B-Instruct/resolve/main/vocab.json
fi
if [ ! -f "merges.txt" ]; then
    curl -fSL -o merges.txt https://huggingface.co/Qwen/Qwen2.5-3B-Instruct/resolve/main/merges.txt
fi
cd ..

# run
echo "---Running example----"
if [ "$OS" = "Windows_NT" ] || [ -n "$WINDIR" ]; then
    # Windows
    if [ -f "build/Release/example.exe" ]; then
        ./build/Release/example.exe
    elif [ -f "build/example.exe" ]; then
        ./build/example.exe
    else
        echo "Error: example executable not found"
        exit 1
    fi
else
    # Unix-like
    ./build/example
fi
