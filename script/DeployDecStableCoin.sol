// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {DecStableCoin} from "../src/DecStableCoin.sol";
import {DSCEngine} from "../src/DSCEngine.sol";

contract DeployDecStableCoin is Script {

    function run() public returns (DecStableCoin, DSCEngine) {
        vm.startBroadcast();
        DecStableCoin decStableCoin = new DecStableCoin();
        DSCEngine engine = new DSCEngine();
        vm.stopBroadcast();

        // return decStableCoin;
    }
}
