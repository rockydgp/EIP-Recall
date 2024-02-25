// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RWAToken is ERC20, ERC20Burnable, Ownable {
    address[] public holders;

    constructor(
        address _owner,
        uint256 _amount
    ) ERC20("RWAToken", "RTKN") Ownable(_owner) {
        _mint(_owner, _amount);
    }

    function burnAllTokens() public onlyOwner {
        // Iterate through all token holders and burn their tokens
        for (uint256 i = 0; i < holders.length; i++) {
            address holder = holders[i];
            uint256 balance = balanceOf(holder);
            _burn(holder, balance);
        }
    }

    function getAllHolders() external view returns (address[] memory) {
        return holders;
    }

    function transfer(
        address to,
        uint256 value
    ) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value);
        bool isRecipientExists = false;
        for (uint256 i = 0; i < holders.length; i++) {
            if (holders[i] == to) {
                isRecipientExists = true;
                break;
            }
        }
        if (!isRecipientExists) holders.push(to);

        // If sender's balance is zero, remove from holders list
        if (balanceOf(owner) == 0) {
            for (uint256 i = 0; i < holders.length; i++) {
                if (holders[i] == owner) {
                    holders[i] = holders[holders.length - 1];
                    holders.pop();
                    break;
                }
            }
        }
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        bool isRecipientExists = false;
        for (uint256 i = 0; i < holders.length; i++) {
            if (holders[i] == to) {
                isRecipientExists = true;
                break;
            }
        }
        if (!isRecipientExists) holders.push(to);

        // If sender's balance is zero, remove from holders list
        if (balanceOf(spender) == 0) {
            for (uint256 i = 0; i < holders.length; i++) {
                if (holders[i] == spender) {
                    holders[i] = holders[holders.length - 1];
                    holders.pop();
                    break;
                }
            }
        }
        return true;
    }
}
