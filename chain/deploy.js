import { ethers } from "ethers";
import fs from "fs";
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

async function main() {
  const provider = new ethers.JsonRpcProvider("http://127.0.0.1:8545");
  
  const privateKey = process.env.DEPLOYER_WALLET_PRIVATE_KEY;
  const wallet = new ethers.Wallet(privateKey, provider); // wallet private key

  // deploy verifier contract
  const contractPath = join(__dirname, "../artifacts/contracts/verifier.sol/Groth16Verifier.json");
  const contractJson = JSON.parse(fs.readFileSync(contractPath, "utf8"));
  const factory = new ethers.ContractFactory(contractJson.abi, contractJson.bytecode, wallet);
  const verifier = await factory.deploy();
  await verifier.waitForDeployment();
  const verifierAddress = await verifier.getAddress();
  // console.log("合約部署成功！");
  // console.log("合約地址:", address);
  // console.log("部署錢包地址:", wallet.address);

  const latestNonce = await wallet.getNonce();
  console.log("當前最新 Nonce 應該為:", latestNonce);

  const privateKey01 = process.env.DEPLOYER_WALLET_PRIVATE_KEY01;
  // const wallet01 = new ethers.Wallet(privateKey01, provider); // wallet private key

  // deploy ballotManager contract
  const ballotManagerPath = join(__dirname, "../artifacts/contracts/ballotManager.sol/ballotManager.json");    
  const ballotManagerJson = JSON.parse(fs.readFileSync(ballotManagerPath, "utf8"));
  const ballotFactory = new ethers.ContractFactory(ballotManagerJson.abi, ballotManagerJson.bytecode, wallet);
  const args = [
    verifierAddress, // verifier's address
    "1957502675450735006995294171749393708380816510550016513572325377928709312799", // root
    "222222", // nullifier
    ["10209775308811493123219977751870536028325781179662633829382233991134085591271", "10463201402378381645770001492167936758751449996873528340577630879574526767592"], // pk
    ["LIN", "KUAN", "HAO"], // names
    ["QmHashA123", "QmHashB456", "QmHashC789"], // ipfsCID
    60, // durationTime
    ["0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266", "0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC", "0x70997970C51812dc3A010C7d01b50e0d17dc79C8", "0x90F79bf6EB2c4f870365E785982E1f101E93b906", "0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65"]
  ];
  const ballotManager = await ballotFactory.deploy(...args, { nonce: latestNonce });
  await ballotManager.waitForDeployment();
  const ballotManagerAddress01 = await ballotManager.getAddress();
  console.log("合約部署成功！地址:", ballotManagerAddress01);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("部署錯誤:", error.message);
    console.error(error);
    process.exit(1);
  });
