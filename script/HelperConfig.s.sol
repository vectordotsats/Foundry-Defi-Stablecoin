// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {DSCEngine} from "../src/DSCEngine.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.t.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        address wethUsdPriceFeed;
        address wbtcUsdPriceFeed;
        address weth;
        address wbtc;
        uint256 deployerKey;
    }
    
    NetworkConfig public activeNetworkConfig;

    constructor () {
        if(block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        }
        else {
            activeNetworkConfig = getOrCreateAnvilConfig();
        }
    }

    function getSepoliaEthConfig() public view returns(NetworkConfig memory sepoliaEthConfig) {
        sepoliaEthConfig = NetworkConfig({
            wethUsdPriceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306,
            wbtcUsdPriceFeed: 0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43,
            wbtc: 0xdd13E55209Fd76AfE204dBda4007C227904f0a81,
            weth: 0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063,
            deployerKey: vm.envUint("PRIVATE_KEY")
        });

        return sepoliaEthConfig;
    }

    function getOrCreateAnvilConfig() public view returns(NetworkConfig memory anvilConfig) {
        
        // Check to see if we set the active config network.
        if(activeNetworkConfig.wethUsdPriceFeed != address(0)) {
            return activeNetworkConfig;
        }


    
    }
}