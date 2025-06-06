# 初始化計數器
$i = 1

function Run-TTS {
    param(
        [string]$Speaker,
        [string]$Text,
        [string]$Instructions
    )

    # 匯出環境變數（供 gemini-tts 使用）
    $env:INSTRUCTIONS = $Instructions
    $env:TEXT         = $Text

    # 產生兩位數遞增檔名
    $outputFile = "output-{0}.wav" -f $i.ToString("D2")

    # 構建完整的命令字串，確保參數正確引用
    $escapedInstructions = $Instructions -replace '"', '\"'
    $escapedText = $Text -replace '"', '\"'
    $escapedSpeaker = $Speaker -replace '"', '\"'

    $commandString = "gemini-tts --instructions `"$escapedInstructions`" --speaker1 `"$escapedSpeaker`" --text `"$escapedText`" --outputfile `"$outputFile`""

    # 印出指令方便除錯
    Write-Host $commandString

    # 非同步執行
    Start-Process -FilePath "cmd" -ArgumentList "/c", $commandString -NoNewWindow -Wait

    # 遞增計數器
    $script:i++
}

Run-TTS achernar      '歡迎收聽 NotebookLM 錦囊妙計特別氣劃！這集我們找來一群朋友，一起聊聊為什麼這門課值得期待。 ' 'Read aloud in a fast, joyful, exciting, welcoming tone'
Run-TTS aoede         '我我我，我上次想用 NotebookLM 來整理考試筆記，結果搞了半天還是不會用！這堂課程會教我嗎？ ' 'Read aloud in a nervous, hesitant, slightly anxious tone'
Run-TTS autonoe       '我當初也是這樣，不過我上了那堂「NotebookLM 錦囊妙計」課後就完全開竅了！ ' 'Read aloud in a reassuring, confident, friendly tone'
Run-TTS callirrhoe    '欸真的假的？那堂課有教什麼？ ' 'Read aloud in a curious, surprised, upbeat tone'
Run-TTS despina       '超多啊！什麼對話提問技巧、整理 PDF 的方法，還有語音摘要都講得很清楚。 ' 'Read aloud in an enthusiastic, informative, energetic tone'
Run-TTS erinome       '我就是靠那個「把 GitHub 專案變知識庫」技巧，把公司專案搞懂的！ ' 'Read aloud in a proud, slightly boastful, excited tone'
Run-TTS gacrux        '所以看起來用途很廣欸，我好奇 NotebookLM 真的能幫我整理 LINE 群組裡的資訊嗎？我群組超亂的。 ' 'Read aloud in a skeptical, genuinely curious, casual tone'
Run-TTS kore          '可以啊！還教你怎麼快速找出群組裡的關鍵訊息跟人物，超實用。 ' 'Read aloud in a helpful, practical, confident tone'
Run-TTS laomedeia     '對對對，我有試過，幫我省了超多整理時間。 ' 'Read aloud in a relieved, grateful, honest tone'
Run-TTS leda          '我其實比較想知道，怎麼避免筆記中出現中國用語，那個對我來說很煩。 ' 'Read aloud in a slightly annoyed, concerned, thoughtful tone'
Run-TTS sulafat       '那也有講到欸，有一整段都在教怎麼讓筆記更本地化，超台～ ' 'Read aloud in a playful, cheerful, local accent tone'
Run-TTS zephyr        '我其實蠻怕 NotebookLM 給錯答案...這課會教怎麼「提問」嗎？ ' 'Read aloud in a worried, cautious, sincere tone'
Run-TTS vindemiatrix  '會的。我朋友上過，保哥說你只要會說人話就好，我覺得也蠻有道理的，哈哈哈～ ' 'Read aloud in a relaxed, humorous, reassuring tone'
Run-TTS pulcherrima   '聽起來很像在訓練一個 AI 助理耶！ ' 'Read aloud in a fascinated, imaginative, lighthearted tone'
Run-TTS achird        '哈哈沒錯。我還用它幫我整理三份 PDF 文件，然後請它幫我「產出一份比較」。結果比我人工做的還快。 ' 'Read aloud in a proud, amused, slightly competitive tone'
Run-TTS algenib       '我純粹是來觀望的，如果真的這麼好用，應該會想立刻買課。 ' 'Read aloud in a reserved, skeptical, neutral tone'
Run-TTS algieba       '那這堂課會教怎麼把實體書或 PDF 整理成知識庫嗎？我很常買書，但都看不完，希望能更有效率學習！ ' 'Read aloud in a hopeful, earnest, slightly overwhelmed tone'
Run-TTS alnilam       '會的，保哥有教我們怎麼把整本書變成 PDF，然後丟進 NotebookLM 還能接著提問！ ' 'Read aloud in an encouraging, supportive, excited tone'
Run-TTS charon        '真的假的？有人用過 NotebookLM 來整理面試資料嗎？ ' 'Read aloud in a surprised, doubtful, curious tone'
Run-TTS enceladus     '有啊有啊，那個人資篇就很強，還教你怎麼從雲端硬碟抓檔案來整理。 ' 'Read aloud in an enthusiastic, knowledgeable, slightly fast tone'
Run-TTS fenrir        '我是用在製作 Podcast，超好用的欸，音訊總覽配合語音摘要超神！ ' 'Read aloud in a passionate, energetic, creative tone'
Run-TTS iapetus       '如果語音摘要能自然唸出台灣人的語氣，我真的會超感動！ ' 'Read aloud in a hopeful, emotional, sincere tone'
Run-TTS orus          '現在完全做得到喔！想知道效果如何？等一下你就會親耳聽到，用台灣國語唸出來真的超自然！ ' 'Read aloud in an excited, teasing, confident tone'
Run-TTS puck          'YouTube 影片那麼長，有沒有教怎麼快速吸收重點？我常常只是想抓個重點就得看 40 分鐘。如果可以直接幫我整理出精華片段和摘要，我追蹤的頻道就能更有效率學習了！ ' 'Read aloud in a frustrated, overwhelmed, eager tone'
Run-TTS rasalgethi    '有喔，這堂課會教你怎麼把 YouTube 影片的網址加進 NotebookLM，讓它自動幫你生成重點摘要，甚至整理出 Q&A 清單！ ' 'Read aloud in an informative, enthusiastic, slightly fast tone'
Run-TTS sadachbia     '哇，那我追課程影片也不用快轉到頭昏了，這對我這種看課懶人超友善～ ' 'Read aloud in a relieved, grateful, playful tone'
Run-TTS sadaltager    '我用 NotebookLM 主要是整理網站資料，但 SPA 網站真的有夠難搞。 ' 'Read aloud in a frustrated, slightly complaining, honest tone'
Run-TTS schedar       '有交技巧喔！還有一小節教你怎麼用爬蟲方式輔助抓資料。 ' 'Read aloud in a helpful, practical, slightly proud tone'
Run-TTS umbriel       '大家是不是都很厲害？我連語音摘要超過 30 分鐘都不會處理。 ' 'Read aloud in a self-deprecating, embarrassed, honest tone'
Run-TTS zubenelgenubi '那個新單元也有教欸，重點是步驟簡單、還能自訂語音長度。 ' 'Read aloud in an encouraging, practical, upbeat tone'
Run-TTS achernar      '可是那堂課那麼多內容，我會不會看不完？ ' 'Read aloud in a worried, overwhelmed, slightly anxious tone'
Run-TTS aoede         '放心啦，保哥的線上課程可以看三個月，還有 Discord 社群可以隨時許願，推薦課程還可以加長看課騎限，超讚！ ' 'Read aloud in a reassuring, calm, friendly tone'
Run-TTS autonoe       '那我現在報名來得及嗎？ ' 'Read aloud in a hopeful, slightly anxious, eager tone'
Run-TTS callirrhoe    '當然來得及啊，去搜尋「NotebookLM 錦囊妙計」就能報名了，一起成為筆記大師吧！ ' 'Read aloud in an excited, inviting, cheerful tone'
