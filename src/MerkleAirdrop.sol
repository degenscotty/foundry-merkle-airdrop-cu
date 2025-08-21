// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MerkleAirdrop {
    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/
    error MerkleAirdrop__InvalidProof();

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/
    event Claim(address account, uint256 amount);

    /*//////////////////////////////////////////////////////////////
                                 STATE VARIABLES
    //////////////////////////////////////////////////////////////*/
    address[] claimers;
    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_airdropToken;

    /*//////////////////////////////////////////////////////////////
                                 FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    constructor(bytes32 merkleRoot, IERC20 airdropToken) {
        i_airdropToken = airdropToken;
        i_merkleRoot = merkleRoot;
    }

    function claim(address account, uint256 amount, bytes32[] calldata merkleProof) external {
        // calculate using the account and the amount, the hash -> leaf node
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encodePacked(account, amount))));

        if (!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
            revert MerkleAirdrop__InvalidProof();
        }

        emit Claim(account, amount);
        i_airdropToken.transfer(account, amount);
    }
}
