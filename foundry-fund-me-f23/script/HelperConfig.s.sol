//SPDX-License-Identifier: MIT

// 1. Deploy mock on anvil chain
// 2Keep track of contract address accross chains

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    //Constants
    NetworkConfig public activeNetworkConfig;
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    struct NetworkConfig {
        address priceFeed; //ETH/USD price feed address
    }

    constructor() {
        if (block.chainid == 5) {
            activeNetworkConfig = getGoerliEthConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getEthMainetConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getGoerliEthConfig() public pure returns (NetworkConfig memory) {
        // price feed address
        NetworkConfig memory goerliConfig = NetworkConfig({
            priceFeed: 0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496
        });
        return goerliConfig;
    }

    function getEthMainetConfig() public pure returns (NetworkConfig memory) {
        // price feed address
        NetworkConfig memory ethMainetConfig = NetworkConfig({
            priceFeed: 0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496
        });
        return ethMainetConfig;
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        //price feed address
        // 1 Deploy the mocks
        // 2 Return the mock address
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }

        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });
        return anvilConfig;
    }
}
