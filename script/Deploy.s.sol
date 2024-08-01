// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;



import {Script} from "forge-std/Script.sol";
import {UniswapAggregatorChainflip_V1} from "../src/UniswapAggregatorChainflip_V1.sol";

contract Deploy is Script{
    function run() external{
        vm.startBroadcast();
        address[] memory tokens = new address[](2);
        tokens[0] = 0x6982508145454Ce325dDbE47a25d4ec3d2311933;
        tokens[1] = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    }
}