// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {DeployDecStableCoin} from "../../script/DeployDecStableCoin.sol";
import {DecStableCoin} from "../../src/DecStableCoin.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
 
contract DSCEngineTest is Test {

    DeployDecStableCoin deployer;
    DecStableCoin dsc;
    DSCEngine engine;
    HelperConfig config;

    function setUp() public {
        deployer = new DeployDecStableCoin(); 
        (dsc, engine, config) = deployer.run();
    }

    /////////////////////
    /// Price Tests ///// 
    ////////////////////

    function testGetUsdValue() public {

    }
}