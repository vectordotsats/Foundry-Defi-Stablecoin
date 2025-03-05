// SPDX-License-Identifier: MIT

// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

pragma solidity ^0.8.18;

/**
 * @title DecStableCoin
 * @author Vectordotsats
 * @notice Collateral: Exxogenous(ETH, BTC)
 * Stability Mechanism: Algorithmically adjusted
 * Relative Stability: Pegged to 1USD
 *
 * This contract is meant to be governed by DSCEngine. This contract is a contract is an ERC20 implementation of the stablecoin system.
 */

// IMPORTS
import {ERC20Burnable, ERC20} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
//Ownable in the sense that the Stable coin is governed by our Logic.

// ERRORS
error StableCoin_MustBeGreaterThanZero();
error StableCoin_BalanceIsTooLow();
error StableCoin_NotZeroAddress();

contract DecStableCoin is ERC20Burnable, Ownable {
    constructor() ERC20("DecStableCoin", "DSC") Ownable(msg.sender) {}

    function burn(uint256 _amount) public override onlyOwner {
        //override overrides the Burn function in ERC20Burnable
        uint256 balance = balanceOf(msg.sender);
        if (balance <= 0) {
            revert StableCoin_MustBeGreaterThanZero();
        }
        if (balance < _amount) {
            revert StableCoin_BalanceIsTooLow();
        }
        super.burn(_amount);
        //The "super" keyword accesses the parent contract's functions of only the function that is attatch to the "super" keyword.
    }

    function mint(
        address _to,
        uint256 _amount
    ) external onlyOwner returns (bool) {
        if (_to == address(0)) {
            revert StableCoin_NotZeroAddress();
        }
        if (_amount <= 0) {
            revert StableCoin_MustBeGreaterThanZero();
        }
        _mint(_to, _amount);

        return true;
    }
}
