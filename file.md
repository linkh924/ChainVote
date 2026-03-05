| 檔案                                   | 說明                                         |
| :------------------------------------- | :------------------------------------------- |
| ./chain/contracts/ballotManager.sol    | 主要投票合約                                 |
| ./chain/contracts/verifier.sol         | zkp驗證的合約                                |
| ./chain/scripts/deploy_seopolid_eth.js | 部署合約到以太測試鏈                         |
| ./chain/args.js                        | 用於驗證合約的參數                           |
| ./chain/deploy.js                      | 用於本地部署的                               |
| ./chain/deploy.md                      | 驗證合約的指令                               |
| ./chain/hardhat.config.js              | Hardhat 配置                                 |
| ./circuits/compile.md                  | 合約編譯指令說明                             |
| ./circuits/test.md                     | 編譯過的參數, 包含私鑰,加密過的值...         |
| ./circuits/zkp.circom                  | zkp的電路                                    |
| ./frontend/*                           | 前端檔案                                     |
| ./frontend/zk/zkp_final.zkey           | 零知識證明 proving key                       |
| ./frontend/zk/zkp.wasm                 | 零知識證明生成器                             |
| ./oracle/decrypt*.js                   | 這幾個都是解密測試用的, 有不同格式           |
| ./oracle/keygen*.js                    | 這幾個都是密鑰生成用的                       |
| ./oracle/oracle.js                     | 預言機執行的部分, 但實際要放在合約           |
| ./oracle/server.js                     | 模擬身份驗證                                 |
| ./scaffold-eth-2/                      | 合約本地測試的工具, 有 ui 可以操作           |
| ./env.temp                             | .env 模板                                    |
| ./docker-compose.yml                   | 加入預言幾以前都可以用, 後續需要改檔案設定～ |
| ./problem.md                           | 遇到的一些問題, 有記住的                     |
