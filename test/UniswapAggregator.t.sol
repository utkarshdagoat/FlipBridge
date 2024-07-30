// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import "forge-std/console.sol";
import {UniswapAggregatorChainflip_V1} from "../src/UniswapAggregatorChainflip_V1.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract UniswapCCMTest is Test {
    address constant swapRouter = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
    address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant CF_VAULT = 0xF5e10380213880111522dd0efD3dbb45b9f62Bcc;
    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    UniswapAggregatorChainflip_V1 aggregator;

    function setUp() public {
        address[] memory tokens = new address[](2);
        tokens[0] = WETH;
        tokens[1] = USDC;
        aggregator = new UniswapAggregatorChainflip_V1(
            swapRouter,
            address(this),
            tokens,
            CF_VAULT
        );
    }

    function testCfReceive() public {
        vm.startPrank(CF_VAULT);
        // IERC20 dai = IERC20(DAI);
        IERC20 wETH = IERC20(WETH);
        IERC20 usdc = IERC20(USDC);
        address me = 0x67ff09c184d8e9e7B90C5187ED04cbFbDba741C8;
        uint256 balanceBefore = wETH.balanceOf(me);
        uint256 balanceBeforeUSDC = usdc.balanceOf(address(aggregator));
        console.log("balance of me for Wrapped Ether ", balanceBefore);
        console.log("balance of contract for USDC ", balanceBeforeUSDC);
        deal(USDC, address(aggregator), 1e6 * 1e6 );

        uint256 balanceAfterUSDC = usdc.balanceOf(address(aggregator));
        console.log("balanceAfterUSDC ", balanceAfterUSDC);

        bytes memory message = abi.encode(
            uint32(2),
            uint32(1),
            uint256(10e6),
            uint256(0),
            uint24(3000),
            me
        );
        bytes memory srcAddr = abi.encode(CF_VAULT);
        // console.log("srcAddr ", srcAddr);
        // console.log("message ", message);
        uint256 amountOut = aggregator.cfReceive(
            1,
            srcAddr,
            message,
            WETH,
            10e6
        );
        console.log("uniswap amountOut ", amountOut);
        uint256 balanceAfter = wETH.balanceOf(me);
        console.log("balance of me after uniswap swap", balanceAfter);
        vm.stopPrank();
    }
}
