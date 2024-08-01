// SPDX-License-Idetifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;



import {Script} from "forge-std/Script.sol";
import {UniswapAggregatorChainflip_V1} from "../src/UniswapAggregatorChainflip_V1.sol";

contract DeploySepolia is Script{
    address constant WETH = 0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9;
    address constant CF_VAULT = 0x36eaD71325604DC15d35FAE584D7b50646D81753;
    address constant swapRouter02 = 0x3bFA4769FB09eefC5a80d6E87c3B9C650f7Ae48E;
    function run() external returns (address) {
        vm.startBroadcast();
        UniswapAggregatorChainflip_V1 aggregator = new UniswapAggregatorChainflip_V1(
            address(0x67ff09c184d8e9e7B90C5187ED04cbFbDba741C8),
            CF_VAULT,
            swapRouter02,
           WETH 
        );
        vm.stopBroadcast();
        return address(aggregator);

    }
}

contract DeployMainnet is Script{
    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address constant CF_VAULT = 0xF5e10380213880111522dd0efD3dbb45b9f62Bcc;
    address constant swapRouter02 = 0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45;

    function run() external returns (address) {
        vm.startBroadcast();
        UniswapAggregatorChainflip_V1 aggregator = new UniswapAggregatorChainflip_V1(
            address(0x5d17166A223aeE00472543eED7449a4F03648F54),
            CF_VAULT,
            swapRouter02,
           WETH 
        );
        vm.stopBroadcast();
        return address(aggregator);

    }
}