---
name: gemini-tts-cli
description: Gemini TTS 命令列工具使用指南，涵蓋單句與批次文字轉語音、列出聲音、合併 WAV、stdout 輸出、API key 設定、快取與併發等。當使用者詢問 gemini-tts、Gemini TTS CLI、list-voices、merge、GEMINI_API_KEY、文字轉語音或相關參數時使用。
---

# Gemini TTS CLI

## Overview
使用本指南快速掌握 `gemini-tts` 的指令、參數與常見流程，完成文字轉語音、批次處理、合併 WAV 與基本排錯。

## Quick Start
設定 API key（PowerShell）：
```powershell
$env:GEMINI_API_KEY = "your-api-key-here"
```

設定 API key（CMD）：
```cmd
set GEMINI_API_KEY=your-api-key-here
```

設定 API key（bash/zsh）：
```bash
export GEMINI_API_KEY="your-api-key-here"
```

單句轉語音：
```bash
gemini-tts -t "Hello world"
```

指定指令與聲音：
```bash
gemini-tts -i "Read aloud in a warm, professional and friendly tone" -s zephyr -t "Hello" -o hello.wav
```

批次檔案（合併輸出）：
```bash
gemini-tts -f "input.txt" -s achird -c 5 -m -o merged.wav
```

列出所有聲音：
```bash
gemini-tts list-voices
```

合併 WAV：
```bash
gemini-tts merge "*.wav"
```

## Commands
- `gemini-tts`：主命令，單句或批次文字轉語音。
- `gemini-tts list-voices`：列出可用聲音。
- `gemini-tts merge <pattern>`：合併 WAV，支援 glob pattern。

## Core Options
- `-t`, `--text`：要轉語音的文字。與 `--file` 擇一。
- `-f`, `--file`：批次輸入檔案路徑（僅 `.txt` 或 `.md`）。與 `--text` 擇一。
- `-i`, `--instructions`：指令提示，預設為 `Read aloud in a warm, professional and friendly tone`。
- `-s`, `--speaker1`：聲音名稱，大小寫不敏感，預設隨機。
- `-o`, `--outputfile`：輸出 WAV 名稱，預設 `output.wav`。單句模式可用 `-` 輸出到 stdout。
- `-c`, `--concurrency`：批次併發數，預設 `1`。
- `-m`, `--merge`：批次完成後合併成單一 WAV。
- `--no-cache`：關閉快取並強制重新生成。

## Input Rules
- `--text` 與 `--file` 只能擇一，且必須提供其一。
- `-t` 參數若以 `@` 或 `"@` 開頭，會被視為檔案參考，例如 `-t @input.txt` 或 `-t "@input with spaces.txt"`。
- 批次檔案僅支援 `.txt` 或 `.md`，檔案必須存在。
- 會忽略空行與只含符號的行，至少要有一行包含字母或數字。

## Output Behavior
- 單句模式輸出單一 WAV，`-o -` 會把 WAV 直接寫到 stdout，可用管線輸出。
- 批次模式未啟用 `--merge` 時，輸出為 `basename-01.wav`、`basename-02.wav`…（基底來自 `--outputfile`）。
- 批次模式啟用 `--merge` 時，先產生暫存檔再合併成 `--outputfile`。
- `merge` 子命令在目前工作目錄比對 pattern，pattern 必須包含 `.wav`。

## Merge Pattern Defaults
- `*.wav` 預設輸出 `merged.wav`。
- `**/*.wav` 預設輸出 `all-merged.wav`。
- `trial03-*.wav` 預設輸出 `trial03-merged.wav`。

## Voices
Female: achernar, aoede, autonoe, callirrhoe, despina, erinome, gacrux, kore, laomedeia, leda, sulafat, zephyr, pulcherrima, vindemiatrix

Male: achird, algenib, algieba, alnilam, charon, enceladus, fenrir, iapetus, orus, puck, rasalgethi, sadachbia, sadaltager, schedar, umbriel, zubenelgenubi

## Cache
- 預設會使用快取避免重複生成，快取 key 由 `instructions + voice + text` 組成並儲存在系統暫存目錄。
- 需要強制重新生成時，使用 `--no-cache`。

## Examples
單句輸出到 stdout：
```bash
gemini-tts -t "Hello world" -o - > output.wav
```

以檔案參考批次處理：
```bash
gemini-tts -t @input.txt -s zephyr -c 3
```

批次輸出不合併（產生編號檔案）：
```bash
gemini-tts -f "input.txt" -s zephyr -c 3
```

合併指定模式：
```bash
gemini-tts merge "trial03-*.wav" -o trial03-merged.wav
```

## Troubleshooting
- 出現缺少 API key 錯誤時，設定 `GEMINI_API_KEY` 環境變數。
- 出現無效聲音錯誤時，先執行 `gemini-tts list-voices` 確認名稱。
- 批次檔案錯誤時，確認副檔名為 `.txt` 或 `.md`，且檔案存在。
- 合併找不到檔案時，確認 pattern 包含 `.wav` 且在目前工作目錄可匹配。
