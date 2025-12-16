#include <tokenizers_cpp.h>

#include <cassert>
#include <chrono>
#include <fstream>
#include <iostream>
#include <string>

using tokenizers::Tokenizer;

std::string LoadBytesFromFile(const std::string& path) {
  std::ifstream fs(path, std::ios::in | std::ios::binary);
  if (fs.fail()) {
    std::cerr << "Cannot open " << path << std::endl;
    exit(1);
  }
  std::string data;
  fs.seekg(0, std::ios::end);
  size_t size = static_cast<size_t>(fs.tellg());
  fs.seekg(0, std::ios::beg);
  data.resize(size);
  fs.read(data.data(), size);
  return data;
}

void PrintEncodeResult(const std::vector<int>& ids) {
  std::cout << "tokens=[";
  for (size_t i = 0; i < ids.size(); ++i) {
    if (i != 0) std::cout << ", ";
    std::cout << ids[i];
  }
  std::cout << "]" << std::endl;
}

void TestTokenizer(std::unique_ptr<Tokenizer> tok, bool print_vocab = false,
                   bool check_id_back = true, bool add_special_tokens = false) {

  std::vector<std::string> prompts = {
    "What is the capital of Canada?",
    "What is the capital of Canada",
    "I love my wife Ritsu"
  };

  for (auto& prompt : prompts) {
    // Convert prompt to lowercase
    for (auto& c : prompt) {
      c = std::tolower(static_cast<unsigned char>(c));
    }
    // Remove any non-space, non-alphabet characters from the prompt (character is not present at all)
    prompt.erase(
      std::remove_if(prompt.begin(), prompt.end(),
        [](unsigned char c) {
          return !(std::isalpha(c) || c == ' ');
        }),
      prompt.end()
    );

    std::cout << "Prompt: " << prompt << std::endl; 
    std::vector<int> ids = tok->Encode(prompt, add_special_tokens);
    PrintEncodeResult(ids);
    
    // Debug: Print first few token strings
    std::cout << "First 10 token strings: [";
    for (size_t i = 0; i < std::min(ids.size(), size_t(10)); ++i) {
      if (i != 0) std::cout << ", ";
      std::cout << "\"" << tok->IdToToken(ids[i]) << "\"";
    }
    std::cout << "]" << std::endl;

    // Check #3. GetVocabSize
    auto vocab_size = tok->GetVocabSize();
    std::cout << "vocab_size=" << vocab_size << std::endl;

    std::cout << std::endl;
  }
  
}

// HF tokenizer
// - dist/tokenizer.json
void MyTokenizer() {
  std::cout << "Tokenizer: Mine" << std::endl;

  auto start = std::chrono::high_resolution_clock::now();

  // Read blob from file.
  auto blob = LoadBytesFromFile("dist/myTokenizer.json");
  // Note: all the current factory APIs takes in-memory blob as input.
  // This gives some flexibility on how these blobs can be read.
  auto tok = Tokenizer::FromBlobJSON(blob);

  auto end = std::chrono::high_resolution_clock::now();
  auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(end - start).count();

  std::cout << "Load time: " << duration << " ms" << std::endl;

  TestTokenizer(std::move(tok), false, true, true);  // Use add_special_tokens=true to match Python behavior
}


int main(int argc, char* argv[]) {
  // HuggingFaceTokenizerExample();
  MyTokenizer();
  // HuggingFaceBPETokenizerExample();
}
