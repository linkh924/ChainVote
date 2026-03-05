# Setup Guide

Zero-knowledge proofs were implemented using Circom and SnarkJS. These include generating commitments using the secret, preventing double-spending using the nullifier, and storing commitments using the merkle trees.

## Setup Kit

### 1. Install Circom

```bash
# macOS
brew install circom
# other
git clone ...circom
```

### 2. Install Node.js

```bash
npm install
npm install circomlib
```

## SnarkJS implement Groth16 algorithm

### 1. Circuit compliation

Output:

* .r1cs
* .wasm
* .sym

```bash
circom zkp.circom --r1cs --wasm --sym
```

### 2. Trusted Setup

Begin a new Powers of Tau, then add randomness and prepare phase 2.

```bash
npx snarkjs powersoftau new bn128 15 pot15_0000.ptau -v
npx snarkjs powersoftau contribute pot15_0000.ptau pot15_0001.ptau --name="First contribution" -v
npx snarkjs powersoftau prepare phase2 pot15_0001.ptau pot15_final.ptau -v
```

### 3. Circuit setup

The combination of trusted setup and zkp.r1cs, then add randomness and export proof. Finally, generate the verifier's smart contract.

```bash
npx snarkjs groth16 setup zkp.r1cs pot15_final.ptau zkp_0000.zkey
npx snarkjs zkey contribute zkp_0000.zkey zkp_final.zkey --name="LKH Second Contribution" -v
npx snarkjs zkey export verificationkey zkp_final.zkey verification_key.json
npx snarkjs zkey export solidityverifier zkp_final.zkey verifier.sol
```

### 4. Generate proof and verify (Optional)

Inputs for calculating the circuit witness and generating proof data. Test proof validity and convert solidity's parameters format.

```bash
node zkp_js/generate_witness.js zkp_js/zkp.wasm input.json zkp_js/witness.wtns
npx snarkjs groth16 prove zkp_final.zkey zkp_js/witness.wtns proof.json public.json
npx snarkjs groth16 verify verification_key.json public.json proof.json
npx snarkjs generatecall
```
