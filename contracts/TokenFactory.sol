//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.19;

import {RWAToken} from "./RWAtoken.sol";

contract TokenFactory {
    mapping(address => RWAToken) public tokenMapping;

    function CreateNewToken(uint256 _amount) public {
        RWAToken token = new RWAToken(msg.sender, _amount);
        tokenMapping[msg.sender] = token;
    }
}
