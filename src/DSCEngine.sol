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
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DSCEngine is ReentrancyGuard {
    /////////////////
    // Errors ///////
    /////////////////
    error DSCEngine_EnterValueGreaterThanZero();
    error DSCEngine_EnterValidToken();
    error DSCEngine_TokenAddressesAndPriceFeedAddressesMustHaveSameLength();
    error DSCEngine_TokenNotAllowed();
    error DscEngine_COllateralTranferFailed();
    error DSCEngine__BreakHeathFactor(uint256 healthFactor);
    error DSCEngine__NotMinted();

    ////////////////////////
    // State Variables ////
    ///////////////////////
    mapping(address token => address priceFeed) private s_tokenToPriceFeed;
    mapping(address user => mapping(address token => uint256 amount)) private s_userToTokenCollateral;
    DecStableCoin private immutable i_dsc;
    mapping(address user => uint256 amount) private s_userToDscMinted;
    address[] private s_collateralTokens;
    uint256 private constant ADDITIONAL_FEES = 1e10;
    uint256 private constant PRECISION = 1e18;
    uint256 private constant LIQUIDATION_THRESHOLD = 50;
    uint256 private constant LIQUIDATION_APPROXIMATOR = 100;
    uint256 private constant MINIMUM_HEALTH_FACTOR = 1;

    ////////////////////////
    //       Events    ////
    ///////////////////////
    event DepositedCollateral(address indexed user, address indexed token, uint256 amount);

    /////////////////
    // Modifiers ////
    /////////////////
    modifier moreThanZero(uint256 _amount) {
        if (_amount == 0) {
            revert DSCEngine_EnterValueGreaterThanZero();
        }
        _;
    }

    modifier isAllowedToken(address _token) {
        if (s_tokenToPriceFeed[_token] == address(0)) {
            revert DSCEngine_TokenNotAllowed();
        }
        _;
    }

    //////////////////
    // Functions ////
    /////////////////
    constructor(address[] memory tokenAddresses, address[] memory priceFeedAddresses, address dscAddress) {
        if (tokenAddresses.length != priceFeedAddresses.length) {
            revert DSCEngine_TokenAddressesAndPriceFeedAddressesMustHaveSameLength();
        }
        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            s_tokenToPriceFeed[tokenAddresses[i] = priceFeedAddresses[i]];
            s_collateralTokens.push(tokenAddresses[i]);
            i_dsc = DecStableCoin(dscAddress);
        }
    }

    function depositCollateralToMintDsc() external {}

    function depositCollateral(address tokenColateralAddress, uint256 amountColateral)
        external
        isAllowedToken(tokenColateralAddress)
        nonReentrant
    {
        s_userToTokenCollateral[msg.sender][tokenColateralAddress] += amountColateral;
        emit DepositedCollateral(msg.sender, tokenColateralAddress, amountColateral);

        bool success = IERC20(tokenColateralAddress).transferFrom(msg.sender, address(this), amountColateral);
        if (!success) {
            revert DscEngine_COllateralTranferFailed();
        }
    }

    function redeemCollateralToBurnDsc() external {}

    function redeemCollateral() external {}

    function mintDsc(uint256 amountDscMinted) external moreThanZero(amountDscMinted) nonReentrant {
        s_userToDscMinted[msg.sender] += amountDscMinted;
        // Need to revert if amount of Dsc minted is greater than the value of the collateral.
        _revertIfHealthFactorIsBroken(msg.sender);

        bool minted = i_dsc.mint(msg.sender, amountDscMinted);
        if (!minted) {
            revert DSCEngine__NotMinted();
        }
    }

    function burnDsc() external {}

    /* Treshhold for burning 150%
    Collateral of $100 ETH
    DSC of $50

    So when the value collateral goes down to $74, that is undercollaterized. The system gives ppl opportunity for other users to liquidate the position of the careless users who lets their position be undercollateralized. This way the liuidate party looses the $74 worth of ETH.
    */

    function liquidatePosition() external {}

    function getHealthFactor() external view {}

    /////////////////////////////////////
    // Internal & Private Functions ////
    ///////////////////////////////////
    function _getAccountInformation(address user)
        private
        view
        returns (uint256 dscMinted, uint256 totalCollateralInUsd)
    {
        dscMinted = s_userToDscMinted[user];
        // Need to convert collateral to USD since collateral can be in WETH, WBTC, so we need to tap in from price feed.
        totalCollateralInUsd = getAccountCollateralValueInUsd(user);
    }

    function _healthFactor(address user) private view returns (uint256) {
        (uint256 dscMinted, uint256 totalCollateralInUsd) = _getAccountInformation(user);

        uint collateralAdjustedForThreshold = (totalCollateralInUsd * LIQUIDATION_THRESHOLD) / LIQUIDATION_APPROXIMATOR;

        return (collateralAdjustedForThreshold * PRECISION) / dscMinted;
    }

    function _revertIfHealthFactorIsBroken(address user) internal view {
        uint256 _actualHealthFactor = _healthFactor(user);
        if(_actualHealthFactor < MINIMUM_HEALTH_FACTOR) {
            revert DSCEngine__BreakHeathFactor(_actualHealthFactor);
        }
    }


    /////////////////////////////////////
    // Public & External Functions ////
    ///////////////////////////////////
    function getAccountCollateralValueInUsd(address user) public view returns (uint256 totalCollateralInUsd) {
        for(uint256 i = 0; i < s_collateralTokens.length; i++) {
            address token = s_collateralTokens[i];
            uint256 amount = s_userToTokenCollateral[user][token];
            totalCollateralInUsd += getUsdValue(token, amount);
        }

        return totalCollateralInUsd;
    }

    function getUsdValue(address token, uint256 amount) public view returns(uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(s_tokenToPriceFeed[token]);
        (,int256 price,,,) = priceFeed.latestRoundData();

        return((uint256(price) * ADDITIONAL_FEES) * amount) / PRECISION; // 1000 * 1e8 *(1e10) * 1000 * 1e18; 
    }
}
