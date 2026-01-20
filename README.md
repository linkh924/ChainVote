# ChainVote

A blockchain-based anonymous voting platform using Ethereum and zero-knowledge proofs, combining homomorphic encryption and threshold encryption to ensure voting privacy and verifiability.

## Core

### Zero-Knowledge Proofs

Implements Groth16 zero-knowledge proofs using snarkjs and circom. Uses Merkle Tree to verifier voting eeligibility and prevent identity exposure. Then, nullifier  prevents duplicate voting.

### Homomorphic Encryption

Employs Elgamal homomorphic encryption on elliptic curve Baby JubHub. It protects voting selection and supports direct accumuation of ciphertext, eliminating the the need for on-chain decrytion of individual data.

### Threshold Encryption

Uses shamir secret sharing to distribute decrytion permissions. It implements a robust **$k$**-out-of-**$n$** threshold logic to decentralize the decrtytion authority.

## Structure

```
chainvote/
├── chain/   
│   ├── contracts/
|   |   ├── ballotManager.sol # main contract
│   |   └── verifier.sol # validator
|   ├── contracts/
|   |   └── deploy_sepolid_eth.js # deploy
|   ├── hardhat.config.js
|   └── ... 
|
├── frontend/   
│   ├── src/
|   ├── public/
|   |   └── zk/
|   |       ├── zkp.wasm
│   |       └── zkp_final.zkey
|   └── ... 
│
├── oracle/   
|   ├── api/
│   |   └── verify.js
|   ├── package.json
|   └── ... 
|
├── docker-compose.yml # env setting  
└── README.md # doc 
```
