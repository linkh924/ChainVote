<script setup>
import { ref } from 'vue'
import { ethers } from 'ethers'

const P = 21888242871839275222246405745257275088548364400416034343698204186575808495617n;
const A = 168700n;
const D = 168696n;

const sk = ref('');

const modulo = (a, m) => {
    const result = a % m;
    return result >= 0n ? result : result + m;
};

const modInverse = (a, m) => {
    a = ((a % m) + m) % m;
    let [oldR, r] = [a, m];
    let [oldS, s] = [1n, 0n];
    while (r !== 0n) {
        const quotient = oldR / r;
        [oldR, r] = [r, oldR - quotient * r];
        [oldS, s] = [s, oldS - quotient * s];
    }
    return oldS < 0n ? oldS + m : oldS;
};

const addPoint = (p1, p2) => {
    const [x1, y1] = p1;
    const [x2, y2] = p2;
    
    const x1y2 = modulo(x1 * y2, P);
    const y1x2 = modulo(y1 * x2, P);
    const x1x2 = modulo(x1 * x2, P);
    const y1y2 = modulo(y1 * y2, P);
    
    const dx1x2 = modulo(D * x1x2, P);
    const dx1x2y1y2 = modulo(dx1x2 * y1y2, P);
    
    const x3_num = modulo(x1y2 + y1x2, P);
    const x3_den = modulo(1n + dx1x2y1y2, P);
    const x3 = modulo(x3_num * modInverse(x3_den, P), P);
    
    const ax1x2 = modulo(A * x1x2, P);
    const y3_num = modulo(y1y2 - ax1x2, P);
    const y3_den = modulo(1n - dx1x2y1y2, P);
    const y3 = modulo(y3_num * modInverse(y3_den, P), P);
    
    return [x3, y3];
};

const mulPointEscalar = (point, scalar) => {
    let result = [0n, 1n];
    let temp = point;
    let s = scalar;
    
    while (s > 0n) {
        if (s & 1n) {
            result = addPoint(result, temp);
        }
        temp = addPoint(temp, temp);
        s >>= 1n;
    }
    
    return result;
};

const cal = async (skValue) => {
    try {
        const skBigInt = BigInt(skValue);
        const provider = new ethers.BrowserProvider(window.ethereum);
        const signer = await provider.getSigner();
        // const contractAddress = '0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512';
        const contractAddress = '0xf0E68007824159E2a8f6e11417B13FfD4f542386';
        const abi = [
            "function getCandidates() public view returns (tuple(string name, string ipfsCID, uint256[2][2] voteCount)[] memory)",
            "function submitSi(uint256[2][3] memory _S) public"
        ];
        const contractWithSigner = new ethers.Contract(contractAddress, abi, signer);
        const candidatesData = await contractWithSigner.getCandidates();
        const siValues = [];
        
        for (let i = 0; i < candidatesData.length; i++) {
            const voteCount = candidatesData[i].voteCount;
            const c1Point = [BigInt(voteCount[0][0]), BigInt(voteCount[0][1])];
            const siPoint = mulPointEscalar(c1Point, skBigInt);
            siValues.push([siPoint[0], siPoint[1]]);
        }
        console.log('計算結果 (Si):', siValues);
        
        const tx = await contractWithSigner.submitSi(siValues, {gasLimit: null});
        console.log('交易發送:', tx.hash);
        await tx.wait();
        console.log('✅ Si 提交成功！');
        
    } catch (error) {
        console.error('❌ 計算或提交失敗:', error);
    }
}
</script>

<template>
<div class="container">
    <div class="form-box">
        <input v-model="sk" type="text" placeholder="請輸入私鑰" @keyup.enter="cal(sk)">
        <button @click="cal(sk)" :disabled="!sk">提交</button>
    </div>
</div>
</template>

<style scoped>
.container {
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 40px 0px;
}
.form-box {
    background: white;
    border-radius: 10px;
    box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
    padding: 40px;
    max-width: 400px;
    width: 100%;
}
input {
    width: 100%;
    padding: 12px 15px;
    border: 1px solid #ddd;
    border-radius: 8px;
    font-size: 14px;
    font-family: 'Courier New', monospace;
    margin-bottom: 15px;
    box-sizing: border-box;
}

input:focus {
    outline: none;
    border-color: #667eea;
}

button {
    width: 100%;
    padding: 12px;
    background: #667eea;
    color: white;
    border: none;
    border-radius: 8px;
    font-size: 16px;
    font-weight: 500;
    cursor: pointer;
}
button:hover:not(:disabled) {
    background: #5568d3;
}
button:disabled {
    opacity: 0.5;
    cursor: not-allowed;
}
</style>