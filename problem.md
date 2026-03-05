# Troubleshooting

## Q: Hardhat 環境

Hardhat 新版本需要 Node.js 22.10+, 要求 ESM

## Q: 兩個合約在本地部署遇到節點問題

用不同錢包部署，部署時鏈節點出錯，記得是鏈不同步，解法用同一個錢包部署，懶得找問題...

## Q: 容器部署節點連線問題

如果 network mode 不是 host ，連線環境要設定環境，不能用 localhost 去連線。

## Q: 網頁資料 Error

環境重開後會有暫存，要把網頁都關掉再開啟就行，這問題找很久，結果是開了兩個分頁，一個關了另一個沒關，所以一直抓舊的資料。

## Q: Chainlink 預言機調用失敗

Gas Limit 需要確認是否足夠，在呼叫oracle前都屬於觸發者的費用。

## Q: Chainlink 預言機呼叫合約問題

Chainlink Functions 的 Oracle JavaScript 有很多限制，沒有套件、模組和編碼工具，所以只能用純 js 實作。呼叫合約辦法：

1. 合約直接 args 給 oracle，所以是預先給資料。用這個解決～
2. 使用 RPC，但需要手動編碼、解析，且需要注意 timeout。

## Q: IPFS 網關載入失敗

CID 的檔案沒有有效緩存，檔案太大，因此訪問或載入會 timeout，所以永遠失敗。將檔案分割成小文件，降低單檔案的大小，解決 IPFS 網關的 timeout 問題。
