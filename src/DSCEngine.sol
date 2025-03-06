// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

/**
 * @title DecStableCoin
 * @author Vectordotsats
 * @notice This contract is the DSCEngine that governs this Stable Coin.
 *
 * This system is designed to be as minimal as possible, where the token maintain a 1 token to $1 peg
 *
 * Our Dsc System should always be overcollateralized. For no reason should the value of the collateral ever be less than the value of Dsc.
 *
 * This StableCoin has the properties of:
 * - Exogenous Collateral.
 * - Dollar Pegged.
 * - Algorithmically stable.
 *
 * It is similar to DAI if DAI had no governance, no fees and was only backed by WETH and WBTC.
 *
 * This contract is the DSCEngine that governs this Stable Coin. It handles all the Logic including minting, burning as well as depositing and withrawing collateral.
 * @notice this contract is very loosely based on the MarkerDAO DSS (DAI) system.
 */

import {DecStableCoin} from "./DecStableCoin.sol";

contract DSCEngine {
    /////////////////
    // Errors ////
    /////////////////
    error DSCEngine_EnterValueGreaterThanZero();

    /////////////////
    // Modifiers ////
    /////////////////
    modifier moeThanZero(uint256 _amount) {
        if (_amount == 0) {
            revert DSCEngine_EnterValueGreaterThanZero();
        }
        _;
    }

    // function depositCollateralToMintDsc() external {}

    function depositCollateral(
        address tokenColateralAddress,
        uint256 amountColateral
    ) external {}

    // function redeemCollateralToBurnDsc(uint256 _amount) external {}

    // function redeemCollateral() external {}

    // function mintDsc() external {}

    // function burnDsc(uint256 _amount) external {}

    /* Treshhold for burning 150%
    Collateral of $100 ETH
    DSC of $50

    So when the value collateral goes down to $74, that is undercollaterized. The system gives ppl opportunity for other users to liquidate the position of the careless users who lets their position be undercollateralized. This way the liuidate party looses the $74 worth of ETH.
    */

    // function liquidatePosition() external {}

    // function getHealthFactor() external view {}
}
