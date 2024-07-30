// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import "forge-std/console.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ISquidRouter} from "@squid-interfaces/ISquidRouter.sol";
import {ISquidMulticall} from "@squid-interfaces/ISquidMulticall.sol";


contract SquidAggregatorChainflip_V1Test is Test {
    address constant SquidRouter = 0xce16F69375520ab01377ce7B88f5BA8C48F8D666;
    address constant SquidMulticall = 0xEa749Fd6bA492dbc14c24FE8A3d08769229b896c;

    address constant CF_VAULT = 0xF5e10380213880111522dd0efD3dbb45b9f62Bcc;

    address constant AXLUSD =0xEB466342C4d449BC9f53A865D5Cb90586f405215;
    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant USDC_ARB = 0xaf88d065e77c8cC2239327C5EDb3A432268e5831;

    address constant me = 0x67ff09c184d8e9e7B90C5187ED04cbFbDba741C8;
    address constant native =0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    address constant AXL_ETH = 0xb829b68f57CC546dA7E5806A929e53bE32a4625D;
    ISquidRouter router;

    uint256 ethForkId;
    uint256 arbitrumForkId;

    function setUp() public {
        router = ISquidRouter(SquidRouter);
        string memory ethRpc = vm.rpcUrl("ethereum");
        string memory arbitrumRpc = vm.rpcUrl("arbitrum");
        ethForkId = vm.createFork(ethRpc);
        arbitrumForkId = vm.createFork(arbitrumRpc);
    }

    function testSquid() public {
        vm.startPrank(address(this));

        IERC20 axlUSDARB = IERC20(AXLUSD);
        IERC20 usdc = IERC20(USDC);
        IERC20 usdcArb = IERC20(USDC_ARB);
        vm.selectFork(arbitrumForkId);
        uint256 balanceBefore = axlUSDARB.balanceOf(me);
        console.log("balance before on arbitrum", balanceBefore);
        ISquidMulticall.Call[] memory calls = new ISquidMulticall.Call[](0); 

        vm.selectFork(ethForkId);
        deal(address(this),10e18);
        deal(USDC,address(this), 1e6 * 1e6 );
        deal(USDC,SquidRouter, 1e6 * 1e6 );
        
        bytes memory payload = abi.encode(calls,me,bytes32("hello"));
        bool success = usdc.approve(SquidRouter, 1e6 * 1e6);
        require(success, "approve failed");
        uint256 allownace = usdc.allowance(address(this),SquidMulticall);

        console.log("allowance", allownace);
        router.callBridgeCall(
            USDC,
            1e6,
            calls,
            "USDC",
            "arbitrum",
            "0x67ff09c184d8e9e7B90C5187ED04cbFbDba741C8",
            payload,
            me,
            true
        );

        IERC20 axlETH = IERC20(AXL_ETH);

        vm.selectFork(arbitrumForkId);
        uint256 balanceAfter = axlUSDARB.balanceOf(me);
        uint256 balanceAfterUSDC = usdcArb.balanceOf(me);
        uint256 balanceAfterAXL_ETH = axlETH.balanceOf(me);


        console.log("balance after on arbitrum", balanceAfter);
        console.log("balance after USDC on arbitrum", balanceAfterUSDC);
        console.log("balance after AXL_ETH on arbitrum", balanceAfterAXL_ETH);

        vm.stopPrank();
    }

}