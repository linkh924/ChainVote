// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./verifier.sol";
// import "./babyJub.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import {FunctionsClient} from "@chainlink/contracts/src/v0.8/functions/v1_0_0/FunctionsClient.sol";
import {FunctionsRequest} from "@chainlink/contracts/src/v0.8/functions/v1_0_0/libraries/FunctionsRequest.sol";

contract ballotManager is FunctionsClient{
    using Strings for uint256;
    using FunctionsRequest for FunctionsRequest.Request;
    Groth16Verifier public verifier;
    uint256 constant Q = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    uint256 constant A = 168700;
    uint256 constant D = 168696;
    uint256 constant R = 2736030358979909402780800718157159386076813972158567259200215660948447373041;

    struct candidate{
        string name;
        string ipfsCID;
        uint256[2][2] voteCount;
    }
    candidate[] public candidates;
    uint256 public root;
    uint256 public nullifier;
    mapping(uint256 => bool) public hasVoted_nullifier;
    uint256[2] public pk;
    uint256 public votingDeadline;

    uint256 public totalSubmit = 0;
    // bool public hasCal = false;
    uint256 public subscriptionId;
    string public oracleSourceCode; // js
    uint256[] public resultVoting;
    address router = 0xb83E47C2bC239B3bf370bc41e1459A34b41238D0;
    bytes32 donId = 0x66756e2d657468657265756d2d7365706f6c69612d3100000000000000000000;
    

    struct shareholder{
        uint256 shareholderId;
        bool isActive;
    }
    struct shareholderSi{
        uint256[2][3] Si;
        bool isSubmitted;
    }
    mapping(address => shareholder) public whiteList;
    mapping(uint256 => shareholderSi) public shareholderSubmitInfo;

    event Vote(uint256 indexed nullifierHash, uint256[2][2] vote01Count, uint256[2][2] vote02Count, uint256[2][2] vote03Count);

    // verifier.sol's address
    constructor(
        address _verifierAddress,
        uint256 _officialRoot, 
        uint256 _nullifier,
        uint256[2] memory _pk,
        string[] memory _names,
        string[] memory _ipfsCID,
        uint256 _durationTime,
        address[5] memory _shareholderAddress,
        uint256 _subscriptionId,
        string memory _oracleSourceCode
    )FunctionsClient(router){
        verifier = Groth16Verifier(_verifierAddress);
        root = _officialRoot;
        nullifier = _nullifier;
        pk = _pk;
        votingDeadline = block.timestamp + (_durationTime * 1 minutes);
        for(uint256 i = 0; i < _names.length; i++){
            uint256[2][2] memory initCount;
            initCount[0][0] = 0;
            initCount[0][1] = 1;
            initCount[1][0] = 0;
            initCount[1][1] = 1;
            candidates.push(candidate({
                name: _names[i],
                ipfsCID: _ipfsCID[i],
                voteCount: initCount
            }));
        }
        for(uint256 i = 0; i < _shareholderAddress.length; i++){
            whiteList[_shareholderAddress[i]] = shareholder({
                shareholderId: i+1,
                isActive: true
            });
            uint256[2][3] memory initCount;
            initCount[0][0] = 0;
            initCount[0][1] = 1;
            initCount[1][0] = 0;
            initCount[1][1] = 1;
            initCount[2][0] = 0;
            initCount[2][1] = 1;
            shareholderSubmitInfo[i+1] = shareholderSi({
                Si: initCount,
                isSubmitted: false
            });
        }
        subscriptionId = _subscriptionId;
        oracleSourceCode = _oracleSourceCode;
    }

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

    function vote(
        uint[2] memory _proofa,
        uint[2][2] memory _proofb,
        uint[2] memory _proofc,
        uint[17] memory _input
    ) public{
        // check
        // require(block.timestamp < votingDeadline, "Voting period has ended!!!");
        require(_input[14] == root, "Invalid root!!!");
        require(_input[13] == nullifier, "Invalid nullifier!!!");
        require(_input[15] == pk[0] && _input[16] == pk[1], "Invalid public key!!!");
        require(!hasVoted_nullifier[_input[0]], "You have voted already!!!");
        require(verifier.verifyProof(_proofa, _proofb, _proofc, _input), "Invalid proof!!!");
        
        // update state
        hasVoted_nullifier[_input[0]] = true;
        for(uint256 i = 0; i < candidates.length; i++){
            // c1
            (candidates[i].voteCount[0][0], candidates[i].voteCount[0][1]) = babyAdd(_input[i*2+1], _input[i*2+2], candidates[i].voteCount[0][0], candidates[i].voteCount[0][1]);
            // c2
            (candidates[i].voteCount[1][0], candidates[i].voteCount[1][1]) = babyAdd(_input[i*2+7], _input[i*2+8], candidates[i].voteCount[1][0], candidates[i].voteCount[1][1]);
        }
        emit Vote(_input[0], candidates[0].voteCount, candidates[1].voteCount, candidates[2].voteCount);
    }

    function getCandidates() public view returns(candidate[] memory){
        return candidates;
    }

    function submitSi(uint256[2][3] memory _S) public{
        // require(block.timestamp > votingDeadline, "Voting period has not ended!!!");
        require(whiteList[msg.sender].isActive, "You are not the shareholder.");
        // require(!shareholderSubmitInfo[whiteList[msg.sender].shareholderId].isSubmitted, "You have already submitted.");
        // require(!hasCal, "The final result has been calculated.");
        if (!shareholderSubmitInfo[whiteList[msg.sender].shareholderId].isSubmitted){
            totalSubmit += 1;
        }
        shareholderSubmitInfo[whiteList[msg.sender].shareholderId].Si = _S;
        shareholderSubmitInfo[whiteList[msg.sender].shareholderId].isSubmitted = true;
        if (totalSubmit == 5) {
            requestOracleCal();
        }
    }

    function requestOracleCal() internal{
        // hasCal = true;
        FunctionsRequest.Request memory req;
        req.initializeRequestForInlineJavaScript(oracleSourceCode);
        string[] memory args = new string[](36);
        // c2, 0-5
        for (uint256 i = 0; i < candidates.length; i++){
            args[i*2] = Strings.toString(candidates[i].voteCount[1][0]);
            args[i*2+1] = Strings.toString(candidates[i].voteCount[1][1]);
        }
        // Si. 6-35
        for (uint256 j = 0; j < 5; j++){
            for (uint256 k = 0; k < 3; k++){
                args[6*j+2*k+6] = Strings.toString(shareholderSubmitInfo[j+1].Si[k][0]);
                args[6*j+2*k+7] = Strings.toString(shareholderSubmitInfo[j+1].Si[k][1]);
            }
        }
        req.setArgs(args);
        _sendRequest(req.encodeCBOR(), uint64(subscriptionId), uint32(300000), donId);
    }

    function fulfillRequest(bytes32 requestId, bytes memory response, bytes memory err) internal override {
        resultVoting = abi.decode(response, (uint256[]));
    }

    function getShares(uint256 _shareholderId) public view returns(uint256[2][3] memory){
        return shareholderSubmitInfo[_shareholderId].Si;
    }
}