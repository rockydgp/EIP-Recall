// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {RWAToken} from "./RWAtoken.sol";
import {TokenFactory} from "./TokenFactory.sol";

contract RWAVault {
    address public owner;
    address public rwaAddress;
    address public rwaTokenAddress;
    address public rwaTokenFactory;
    uint256 public tokenID;
    uint256 public totalShares;
    uint256 public price_ITO;
    uint256 public price_recall;
    uint256 public tokens_distributed;
    uint256 public recall_time;
    uint256 public creation_time;

    event NFTDeposited(
        address indexed depositor,
        address indexed nftContract,
        uint256 indexed tokenId
    );
    event NFTWithdrawn(
        address indexed withdrawer,
        address indexed nftContract,
        uint256 indexed tokenId
    );

    constructor(address _rwaTokenFactory) {
        owner = msg.sender;
        rwaTokenFactory = _rwaTokenFactory;
        creation_time = block.timestamp;
    }

    // @dev  price_ITO and price_recall should be in wei
    // _recall_time in uint256
    function depositRWA(
        address _rwa,
        uint256 _tokenId,
        uint256 _shares,
        uint256 _price_ITO,
        uint256 _price_recall,
        uint256 _recall_time
    ) external {
        require(_shares != 0, "shares should be greater than 0");
        require(_price_ITO > 0, "ITO price should be greater than 0");
        require(
            _price_recall > _price_ITO,
            "recall price should be greater than ITO price"
        );
        IERC721 rwa = IERC721(_rwa);
        require(rwa.ownerOf(_tokenId) == msg.sender, "You must own the NFT");
        rwa.safeTransferFrom(msg.sender, address(this), _tokenId);
        rwaAddress = _rwa;
        totalShares = _shares;
        price_ITO = _price_ITO;
        price_recall = _price_recall;
        recall_time = _recall_time;
        TokenFactory tokenFactory = TokenFactory(rwaTokenFactory);
        tokenFactory.CreateNewToken(totalShares);
        emit NFTDeposited(msg.sender, _rwa, _tokenId);
    }

    function buyToken(uint256 _amount) external payable {
        require(
            _amount < totalShares,
            "amount should be less than total shares"
        );
        require(
            msg.value == (_amount * price_ITO),
            "payment should be exactly equal to _amount"
        );
        RWAToken token = RWAToken(rwaTokenAddress);
        tokens_distributed += _amount;
        token.transfer(msg.sender, _amount);
    }

    //code to distribute amount and get back tokens
    function withdrawRWA(address _nftContract) external payable {
        require(
            recall_time <= block.timestamp - creation_time,
            "can not withdraw before recall time"
        );
        require(
            rwaAddress != address(0),
            "No NFT deposited from this contract"
        );
        require(
            msg.value == (tokens_distributed * price_recall),
            "payment should be exactly equal to recall amount"
        );

        RWAToken token = RWAToken(rwaTokenAddress);
        address[] memory allHolders = token.getAllHolders();
        for (uint256 i = 0; i < allHolders.length; i++) {
            uint256 dist_amount = token.balanceOf(allHolders[i]) * price_recall;
            payable(allHolders[i]).transfer(dist_amount);
        }
        token.burnAllTokens();

        IERC721 nftContract = IERC721(_nftContract);
        nftContract.safeTransferFrom(address(this), msg.sender, tokenID);
        tokenID = 0;
        rwaAddress = address(0);
        emit NFTWithdrawn(msg.sender, _nftContract, tokenID);
    }
}
