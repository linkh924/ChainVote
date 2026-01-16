<script setup>
import { ref, computed, watch } from 'vue'
import { useRoute } from 'vue-router'
import greenLogo from './img/green.png'
import blueLogo from './img/blue.png'
import whiteLogo from './img/white.png'
import { ethers } from 'ethers';

const route = useRoute()
const currentIndex = computed(() => route.query.index || '1')
const P = 21888242871839275222246405745257275088548364400416034343698204186575808495617n;
const r = 2736030358979909402780800718157159386076813972158567259200215660948447373041n;
const A = 168700n;
const D = 168696n;
const Gx = 5299619240641551281634865583518297030282874472190772894086521144482721001553n;
const Gy = 16950150798460657717958625567821834550301663161624707787222815936182638968203n;

const choiceshareholder = [
    [1, 2, 3],
    [1, 2, 4],
    [1, 2, 5],
    [1, 3, 4],
    [1, 3, 5],
    [1, 4, 5],
    [2, 3, 4],
    [2, 3, 5],
    [2, 4, 5],
    [3, 4, 5]
];

const candidates = ref([{ name: 'LIN', votes: 0 }, { name: 'KUAN', votes: 0 }, { name: 'HAO', votes: 0 }]);
const candidateColors = ['#008000', '#0000AA', '#28C8C8'];
const candidateLogos = [greenLogo, blueLogo, whiteLogo];

const getTotalVotes = () => {
    return candidates.value.reduce((sum, c) => sum + (c.votes || 0), 0);
}

const getPercentage = (votes) => {
    const total = getTotalVotes();
    return total === 0 ? 0 : Math.round((votes / total) * 100);
}

const getC2 = async (contract) => {
    const candidatesData = await contract.getCandidates();
    const c2Values = [];
    for (let i = 0; i < candidatesData.length; i++) {
        const voteCount = candidatesData[i].voteCount;
        c2Values[i] = [];
        c2Values[i][0] = voteCount[1][0];
        c2Values[i][1] = voteCount[1][1];
    }
    return c2Values;
}

const getSi = async (contract, shareholderIndices) => {
    const siValues = [];
    for (let i = 0; i < shareholderIndices.length; i++) {
        const siData = await contract.getShares(shareholderIndices[i]);
        siValues[i] = [];
        for (let j = 0; j < 3; j++) {
            siValues[i][j] = [];
            siValues[i][j][0] = siData[j][0];
            siValues[i][j][1] = siData[j][1];
        }
    }
    return siValues;
}

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

const getLamda = (shareholderIndices) => {
    const lamda = [];
    for (let i = 0; i < shareholderIndices.length; i++) {
        let result = 1n;
        const xi = BigInt(shareholderIndices[i]);
        for (let j = 0; j < shareholderIndices.length; j++) {
            if (i !== j) {
                const xj = BigInt(shareholderIndices[j]);
                const numerator = modulo(-xj, r);
                const denominator = modulo(xi - xj, r);
                const denominatorInv = modInverse(denominator, r);
                result = modulo(result * numerator % r * denominatorInv % r, r);
            }
        }
        lamda[i] = result;
    }
    return lamda;
}

const modulo = (a, m) => {
    const result = a % m;
    return result >= 0n ? result : result + m;
};

const addPoint = (p1, p2) => {
    const [x1, y1] = p1;
    const [x2, y2] = p2;
    
    const x1y2 = modulo(x1 * y2, P);
    const y1x2 = modulo(y1 * x2, P);
    const x1x2 = modulo(x1 * x2, P);
    const y1y2 = modulo(y1 * y2, P);
    
    const dx1x2y1y2 = modulo(D * x1x2 * y1y2, P);
    
    const x3_num = modulo(x1y2 + y1x2, P);
    const x3_den = modulo(1n + dx1x2y1y2, P);
    const x3 = modulo(x3_num * modInverse(x3_den, P), P);
    
    const y3_num = modulo(y1y2 - A * x1x2, P);
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

const negatePoint = (point) => {
    return [modulo(-point[0], P), point[1]];
};

const pointsEqual = (p1, p2) => {
    return p1[0] === p2[0] && p1[1] === p2[1];
};

const fetchVotesFromContract = async () => {
    try {
        const provider = new ethers.BrowserProvider(window.ethereum);
        const contractAddress = '0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512';
        const abi = [
            "function getCandidates() public view returns (tuple(string name, string ipfsCID, uint256[2][2] voteCount)[] memory)",
            "function getShares(uint256) public view returns (uint256[2][3])"
        ];
        const contract = new ethers.Contract(contractAddress, abi, provider);
        const shareholderIndices = choiceshareholder[currentIndex.value-1];
        const c2Values = await getC2(contract);
        const siValues = await getSi(contract, shareholderIndices);
        const lamda = getLamda(shareholderIndices);
        const voteCounts = [];
        const G = [Gx, Gy];
        
        for (let i = 0; i < 3; i++) {
            const C2 = [BigInt(c2Values[i][0]), BigInt(c2Values[i][1])];
            let Stotal = null;
            
            for (let j = 0; j < 3; j++) {
                const Si = [BigInt(siValues[j][i][0]), BigInt(siValues[j][i][1])];
                const lambdaSi = mulPointEscalar(Si, lamda[j]);
                
                if (j === 0) {
                    Stotal = lambdaSi;
                } else {
                    Stotal = addPoint(Stotal, lambdaSi);
                }
            }
            const negS = negatePoint(Stotal);
            const M = addPoint(C2, negS);
            // console.log('Stotal:', Stotal);
            // console.log('negS:', negS);
            // console.log('C2:', C2);
            // console.log('M (解密後的點):', M);
            const zeroPoint = [0n, 1n];
            let tempPoint = zeroPoint;
            voteCounts[i] = 0;
            for (let j = 0; j <= 10**5; j++) {
                if (pointsEqual(M, tempPoint)) {
                    voteCounts[i] = j;
                    break;
                }
                tempPoint = addPoint(tempPoint, G);
            }
            // console.log(i+1, '號最終得票數:', voteCounts[i]);
        }
        // update candidates's vote counts
        candidates.value = candidates.value.map((candidate, index) => ({
            ...candidate,
            votes: voteCounts[index]
        }));
        
    } catch (error) {
        console.error('Error fetching votes:', error);
    }
}

watch(currentIndex, () => {
    fetchVotesFromContract();
}, { immediate: true });
</script>

<template>
<div class="vote-container">
    <div class="candidates-container">
          <div v-for="(candidate, index) in candidates" :key="index" 
              class="candidate-card"
              :style="{ backgroundColor: candidateColors[index] }">
              <div class="candidate-number">No.{{ index+1 }}</div>
              <div class="candidate-name">{{ candidate.name }}</div>
              <div class="candidate-ticket">
                  <div class="vote-count">{{ candidate.votes || 0 }} 票</div>
                  <div class="progress-bar">
                      <div class="progress-fill" :style="{ width: getPercentage(candidate.votes) + '%', backgroundColor: candidateColors[index] }"></div>
                  </div>
              </div>
              <img :src="candidateLogos[index]" class="candidate-logo" :alt="`Candidate ${index + 1}`" />
          </div>
    </div>
</div>
</template>

<style scoped>
.vote-container {
    max-width: 1400px;
    margin: 0 auto;
    padding: 80px 40px;
}
.candidates-container {
    display: flex;
    justify-content: center;
    gap: 120px;
    flex-wrap: wrap;
}
.candidate-card {
    width: 210px;
    height: 280px;
    border-radius: 30px;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    position: relative;
    padding: 40px;
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.15);
    transition: transform 0.3s ease;
}
.candidate-card:hover {
    transform: translateY(-8px);
}
.candidate-number {
    font-size: 32px;
    font-weight: bold;
    color: white;
}
.candidate-name {
    font-size: 32px;
    font-weight: bold;
    color: white;
    margin-bottom: 40px;
    letter-spacing: 4px;
}
.candidate-ticket {
    background-color: white;
    color: #333;
    border: none;
    padding: 40px 10px;
    font-size: 24px;
    font-weight: bold;
    border-radius: 20px;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
    width: 100%;
    /* z-index: 2; */
}
.candidate-ticket:hover {
    box-shadow: 0 6px 16px rgba(0, 0, 0, 0.2);
}
.vote-count {
    font-size: 20px;
    text-align: center;
    margin-bottom: 8px;
    white-space: nowrap;
}
.progress-bar {
    width: 80%;
    margin: 0 auto;
    height: 12px;
    background-color: #E0E0E0;
    border-radius: 6px;
    overflow: hidden;
}
.progress-fill {
    height: 100%;
    transition: width 0.5s ease;
    border-radius: 6px;
}
.candidate-logo {
    position: absolute;
    bottom: -40px;
    left: -40px;
    width: 80px;
    height: 80px;
    object-fit: contain;
}

@media (max-width: 1024px) {
    .candidates-container {
        gap: 50px;
    }
    .candidate-card {
        width: 150px;
        height: 220px;
        padding: 40px 30px;
    }
    .candidate-name {
        font-size: 32px;
    }
    .candidate-ticket {
        padding: 30px 10px;
    }
}

@media (max-width: 768px) {
    .vote-container {
        margin: 0 auto;
        padding: 40px 20px;
    }
    .candidates-container {
        gap: 60px;
    }
    .candidate-card {
        width: 120px;
        height: 150px;
    }
    .candidate-number {
        font-size: 26px;
    }
    .candidate-name {
        font-size: 26px;
        letter-spacing: 4px;
        margin-bottom: 30px;
    }
    .candidate-ticket {
        padding: 20px 10px;
    }
    .vote-count {
        font-size: 16px;
    }
    .candidate-logo {
        width: 70px;
        height: 70px;
        bottom: -35px;
        left: -35px;
    }
}

@media (max-width: 480px) {
    .vote-container {
        padding: 20px 20px;
    }
    .candidates-container {
        flex-direction: column;
        align-items: center;
        gap: 40px;
    }
    .candidate-card {
        width: 160px;
        height: 180px;
        padding: 20px 20px;
    }
    .candidate-number {
        font-size: 24px;
    }
    .candidate-name {
        font-size: 24px;
        letter-spacing: 3px;
        margin-bottom: 30px;
    }
    .candidate-logo {
        width: 62px;
        height: 62px;
        bottom: -31px;
        left: -31px;
    }
    .candidate-ticket {
        padding: 20px 0;
    }
}
</style>