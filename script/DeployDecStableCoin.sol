// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {DecStableCoin} from "../src/DecStableCoin.sol";
import {DSCEngine} from "../src/DSCEngine.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployDecStableCoin is Script {
    address[] public tokenAddresses;
    address[] public priceFeedAddresses;

    function run() public returns (DecStableCoin, DSCEngine) {
        HelperConfig config = new HelperConfig();
        (address wethUsdPriceFeed, address wbtcUsdPriceFeed, address weth, address wbtc, uint256 deployerKey) = config.activeNetworkConfig();

        tokenAddresses = [weth, wbtc];
        priceFeedAddresses = [wethUsdPriceFeed, wbtcUsdPriceFeed];

        vm.startBroadcast(deployerKey);
        DecStableCoin decStableCoin = new DecStableCoin();
        DSCEngine engine = new DSCEngine(tokenAddresses, priceFeedAddresses, address(decStableCoin));

        decStableCoin.transferOwnership(address(engine));
        vm.stopBroadcast();

        return (decStableCoin, engine);
    }
}
