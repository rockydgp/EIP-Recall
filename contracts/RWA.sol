// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyRWA is ERC721, Ownable {
    constructor()
        ERC721("myRWA", "RWA")
        Ownable(msg.sender)
    {
        _safeMint(msg.sender, 0);
    }
}