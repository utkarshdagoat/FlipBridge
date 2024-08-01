// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import "forge-std/console.sol";
import {UniswapAggregatorChainflip_V1} from "../src/UniswapAggregatorChainflip_V1.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ISwapRouter} from "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import {IVault} from "@chainflip-interfaces/IVault.sol";

contract UniswapCCMTest is Test {
    address constant swapRouter = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
    address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant CF_VAULT = 0xF5e10380213880111522dd0efD3dbb45b9f62Bcc;
    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public constant WETH9 = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public constant UNIVERSAL_ROUTER =
        0x3fC91A3afd70395Cd496C647d5a6CC9D4B2b7FAD;
    address public constant LINK = 0x514910771AF9Ca656af840dff83E8264EcF986CA;
    address public constant swapRouter02 =
        0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45;
    address constant me = 0x5d17166A223aeE00472543eED7449a4F03648F54;
    uint24 public constant poolFee = 3000;

    address constant PEPE = 0x6982508145454Ce325dDbE47a25d4ec3d2311933;

    UniswapAggregatorChainflip_V1 aggregator;

    ISwapRouter router;

    uint256 ethForkId;
    uint256 arbitrumForkId;

    function setUp() public {
        string memory ethRpc = vm.rpcUrl("ethereum");
        string memory arbitrumRpc = vm.rpcUrl("arbitrum");
        ethForkId = vm.createFork(ethRpc);
        arbitrumForkId = vm.createFork(arbitrumRpc);
        router = ISwapRouter(swapRouter);
        aggregator = new UniswapAggregatorChainflip_V1(
            address(this),
            CF_VAULT,
            swapRouter02,
            WETH
        );
    }

    function testCfRecieve() public {
        vm.startPrank(CF_VAULT);
        IERC20 link = IERC20(LINK);
        IERC20 dai = IERC20(PEPE);
        uint256 balanceBeforeDai = dai.balanceOf(me);
        console.log("before ", balanceBeforeDai);
        deal(address(aggregator), 100 * 1e18);
        bytes memory srcAddr = abi.encode(CF_VAULT);
        bytes
            memory path = hex"5ae401dc0000000000000000000000000000000000000000000000000000000066ae6f7b00000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000e404e45aaf000000000000000000000000c02aaa39b223fe8d0a0e5c4f27ead9083c756cc20000000000000000000000006982508145454ce325ddbe47a25d4ec3d23119330000000000000000000000000000000000000000000000000000000000000bb800000000000000000000000067ff09c184d8e9e7b90c5187ed04cbfbdba741c80000000000000000000000000000000000000000000000000de0b6b3a764000000000000000000000000000000000000000000000116d4b6a50f8644840234a2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
        bytes memory message = abi.encode(path, me);
        aggregator.cfReceive{value: 1e18}(1, srcAddr, message, WETH, 1 * 1e18);
        uint256 balanceAfterDai = dai.balanceOf(me);
        console.log("after ", balanceAfterDai);
        vm.stopPrank();
    }

    address constant aggregatorAddr =
        0xA8C9718d3a790604311206d1748a1E17334EeF8B;
    address constant vaultArbitrum = 0x79001a5e762f3bEFC8e5871b42F6734e00498920;
    address constant vaultEth = 0xF5e10380213880111522dd0efD3dbb45b9f62Bcc;

    function testMainnetDeployment() public {
        vm.selectFork(ethForkId);
        IERC20 pepe = IERC20(PEPE);
        uint256 balanceBefor = pepe.balanceOf(me);
        console.log("before ", balanceBefor);

        deal(address(this), 100 * 1e18);
        bytes memory addr = abi.encode(aggregatorAddr);
        bytes memory message = hex"00000000000000000000000000000000000000000000000000000000000000400000000000000000000000005d17166a223aee00472543eed7449a4f03648f5400000000000000000000000000000000000000000000000000000000000001a45ae401dc0000000000000000000000000000000000000000000000000000000066af15a000000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000e404e45aaf000000000000000000000000c02aaa39b223fe8d0a0e5c4f27ead9083c756cc20000000000000000000000006982508145454ce325ddbe47a25d4ec3d23119330000000000000000000000000000000000000000000000000000000000000bb80000000000000000000000005d17166a223aee00472543eed7449a4f03648f5400000000000000000000000000000000000000000000000000038d7ea4c680000000000000000000000000000000000000000000000047c8f101b1d9d996da6900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
        // IVault(vaultArbitrum).xCallNative{value:1 ether}(
        //     1,
        //     addr,
        //     1,
        //     message,
        //     160000 * (40 gwei),
        //     ""
        // );
        bytes memory call = abi.encodeWithSignature(
            "cfReceive(uint32,bytes,bytes,address,uint256)",
            1,
            addr,
            message,
            1 ether
        );
        uint256 gas = 2500000 * 2 gwei;
        vm.startPrank(vaultEth);
        (bool success,) =    aggregatorAddr.call{value:(0.01 ether +  gas) }(call);
        console.log("success ", success);
        uint256 balanceAfter = pepe.balanceOf(me);
        console.log("after ", balanceAfter);

    }
}
