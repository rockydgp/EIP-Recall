//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.19;

import {RWAVault} from "./Vault.sol";
import "./interfaces/IAnonAadhaarVerifier.sol";

contract VaultFactory {
    mapping(address => RWAVault[]) public vaultMapping;
    address public anonAadhaarVerifierAddr;

    function CreateNewVault(address _tokenfactory, uint256[2] calldata _pA, uint[2][2] calldata _pB, uint[2] calldata _pC, uint[34] calldata _pubSignals) public {
        require(verify(_pA, _pB, _pC, _pubSignals), "Your idendity proof is not valid");
        RWAVault vault = new RWAVault(_tokenfactory);
        vaultMapping[msg.sender].push(vault);
    }

    function verify(uint256[2] calldata _pA, uint[2][2] calldata _pB, uint[2] calldata _pC, uint[34] calldata _pubSignals) public view returns (bool) {
        return IAnonAadhaarVerifier(anonAadhaarVerifierAddr).verifyProof(_pA, _pB, _pC, _pubSignals);
    }
}
