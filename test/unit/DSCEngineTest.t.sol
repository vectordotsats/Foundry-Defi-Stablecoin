// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {DeployDecStableCoin} from "../../script/DeployDecStableCoin.sol";
import {DecStableCoin} from "../../src/DecStableCoin.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
 
contract DSCEngineTest is Test {

    DeployDecStableCoin deployer;
    DecStableCoin dsc;
    DSCEngine engine;
    HelperConfig config;
    address ethUsdPriceFeed;
    address weth;

    function setUp() public {
        deployer = new DeployDecStableCoin(); 
        (dsc, engine, config) = deployer.run();
        (ethUsdPriceFeed,, weth,,) = config.activeNetworkConfig();
    }

    /////////////////////
    /// Price Tests ///// 
    ////////////////////

    function testGetUsdValue() public {
        uint256 ethAmount = 15e18;
        //15e18 * 2000 = 30000e18;
        uint256 expectedUsd = 30000e18;

        uint256 actualUsd = engine.getUsdValue(weth, ethAmount);
        assertEq(actualUsd, expectedUsd);
        console.log("Actual USD:", actualUsd);
        console.log("Expected USD:", expectedUsd);
    }
}