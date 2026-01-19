const P = 21888242871839275222246405745257275088548364400416034343698204186575808495617n;
const r = 2736030358979909402780800718157159386076813972158567259200215660948447373041n;
const A = 168700n;
const D = 168696n;
const Gx = 5299619240641551281634865583518297030282874472190772894086521144482721001553n;
const Gy = 16950150798460657717958625567821834550301663161624707787222815936182638968203n;
const G = [Gx, Gy];
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

const C2 = [];
let index = 0;
for (let i = 0; i < 3; i++) {
    C2.push([BigInt(args[index++]), BigInt(args[index++])]);
}

const Si = [];
for (let i = 0; i < 5; i++) {
    const si = [];
    for (let j = 0; j < 3; j++) {
        si.push([BigInt(args[index++]), BigInt(args[index++])]);
    }
    Si.push(si);
}

const calLamda = (shareholderIndices) => {
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

const mulPointScalar = (point, scalar) => {
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

const negatePoint = (point) => {
    return [modulo(-point[0], P), point[1]];
};

// start
const result = [];

for (let i = 0; i < choiceshareholder.length; i++) {
    const shareholderIndices = choiceshareholder[i];
    const lamda = calLamda(shareholderIndices);
    const currentCount = [];

    for (let j = 0; j < 3; j++) {
        let count = [0n, 1n];
        for (let k = 0; k < 3; k++) {
            const tempSi = Si[shareholderIndices[k]-1][j]; 
            if (k === 0) {
                count = mulPointScalar(tempSi, lamda[k]);
            } else {
                count = addPoint(count, mulPointScalar(tempSi, lamda[k]));
            }
        }
        const negS = negatePoint(count);
        const M = addPoint(C2[j], negS);
        let tempPoint = [0n, 1n];
        for (let l = 0; l <= 10**2; l++) {
            if (M[0] === tempPoint[0] && M[1] === tempPoint[1]) {
                currentCount[j] = l;
                break;
            }
            tempPoint = addPoint(tempPoint, G);
        }
    }
    if (i !== 0) {
        if (currentCount[0] === result[0] && currentCount[1] === result[1] && currentCount[2] === result[2]) {
            continue;
        } else {
            result = [0,0,0];
            break;
        }
    } else {
        result[0] = currentCount[0];
        result[1] = currentCount[1];
        result[2] = currentCount[2];
    }
}

const toBytes32 = (num) => BigInt(num).toString(16).padStart(64, '0');
const offset = toBytes32(32);
const length = toBytes32(result.length);
const encodedValues = result.map(v => toBytes32(v)).join('');
const hexString = offset + length + encodedValues;
const encodedResult = new Uint8Array(hexString.length / 2);
for (let i = 0; i < hexString.length; i += 2) {
    encodedResult[i / 2] = parseInt(hexString.substr(i, 2), 16);
}
return encodedResult;