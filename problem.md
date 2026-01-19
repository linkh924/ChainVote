# Troubleshooting

## Q: Hardhat 環境

Hardhat 新版本需要 Node.js 22.10+, 要求 ESM

## Q: 兩個合約在本地部署遇到節點問題

用不同錢包部署，部署時鏈節點出錯，結法用同一個錢包部署，懶得找問題...

## Q: 容器部署節點連線問題

如果 network mode 不是 host ，連線環境要設定環境，不能用 localhost 去連線。

## Q: 網頁資料 Error

環境重開後會有暫存，要把網頁都關掉再開啟就行，這問題找很久，結果是開了兩個分頁，一個關了另一個沒關，所以一直抓舊的資料。

## Q: Chainlink 預言機調用失敗

Gas Limit 需要確認是否足夠，在呼叫oracle前都屬於觸發者的費用。

## Q: Chainlink 預言機呼叫合約問題

Chainlink Functions 的 Oracle JavaScript 有很多限制，沒有套件、模組和編碼工具，所以只能用純 js 實作。呼叫合約辦法：

1. 合約直接 args 給 oracle，所以是預先給資料，其他解法。
2. 使用 RPC，但需要手動編碼、解析，且需要注意 Timeout。
