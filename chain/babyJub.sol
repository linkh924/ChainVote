// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library babyJub{
    uint256 constant Q = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    uint256 constant A = 168700;
    uint256 constant D = 168696;
    uint256 constant R = 2736030358979909402780800718157159386076813972158567259200215660948447373041;
    
    /*
    add
    x3 = (x1y2 + y1x2) / (1 + Dx1x2y1y2)
    y3 = (y1y2 - Ax1x2) / (1 - Dx1x2y1y2)
    */
    function babyAdd(uint256 x1, uint256 y1, uint256 x2, uint256 y2) public pure returns (uint256 x3, uint256 y3){
        uint256 x1x2 = mulmod(x1, x2, Q);
        uint256 y1y2 = mulmod(y1, y2, Q);
        uint256 dx1x2y1y2 = mulmod(D, mulmod(x1x2, y1y2, Q), Q);

        uint256 x3_num = addmod(mulmod(x1, y2, Q), mulmod(y1, x2, Q), Q);
        uint256 y3_num = addmod(y1y2, Q - mulmod(A, x1x2, Q), Q);

        uint256 x3_den_inv = modInverse(addmod(1, dx1x2y1y2, Q), Q);
        uint256 y3_den_inv = modInverse(addmod(1, Q - dx1x2y1y2, Q), Q);

        x3 = mulmod(x3_num, x3_den_inv, Q);
        y3 = mulmod(y3_num, y3_den_inv, Q);
    }

    // a^(p-2) ≡ a^-1 (mod p)
    function modInverse(uint256 n, uint256 mod) internal pure returns (uint256){
        return power(n, mod - 2, mod);
    }

    function power(uint256 base, uint256 exp, uint256 mod) internal pure returns (uint256 res){
        res = 1;
        base = base % mod;
        while (exp > 0) {
            if (exp % 2 == 1) res = mulmod(res, base, mod);
            base = mulmod(base, base, mod);
            exp = exp >> 1;
        }
    }

    function babyMul(uint256 k, uint256[2] memory P) public pure returns(uint256[2] memory){
        uint256[2] memory result = [uint256(0), uint256(1)];
        uint256[2] memory base = P;

        while (k > 0) {
            if (k & 1 == 1) {
                (result[0], result[1]) = babyAdd(result[0], result[1], base[0], base[1]);
            }
            (base[0], base[1]) = babyAdd(base[0], base[1], base[0], base[1]);
            k >>= 1;
        }
        return result;
    }

    // function negS(uint256[2] memory _S) public pure returns(uint256[2] memory _negS){
    //     uint256 negX;
    //     if(_S[0] == 0){
    //         negX = 0; 
    //     }else{
    //         negX = Q - _S[0];
    //     }
    //     return [negX, _S[1]];
    // }
}