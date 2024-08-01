// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import "forge-std/console.sol";
import {UniswapAggregatorChainflip_V1} from "../src/UniswapAggregatorChainflip_V1.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ISwapRouter} from "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

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
    address constant me = 0x67ff09c184d8e9e7B90C5187ED04cbFbDba741C8;
    uint24 public constant poolFee = 3000;

    address constant PEPE = 0x6982508145454Ce325dDbE47a25d4ec3d2311933;

    UniswapAggregatorChainflip_V1 aggregator;

    ISwapRouter router;

    function setUp() public {
        address[] memory tokens = new address[](2);
        tokens[0] = PEPE;
        tokens[1] = WETH;
        router = ISwapRouter(swapRouter);
        aggregator = new UniswapAggregatorChainflip_V1(
            swapRouter,
            address(this),
            tokens,
            CF_VAULT,
            swapRouter02
        );
    }

    // function testCfReceiveSingleHop() public {
    //     vm.startPrank(CF_VAULT);
    //     // IERC20 dai = IERC20(DAI);
    //     IERC20 pepe = IERC20(PEPE);
    //     IERC20 usdc = IERC20(USDC);
    //     IERC20 wETH = IERC20(WETH);

    //     uint256 balanceBefore = pepe.balanceOf(me);
    //     uint256 balanceBeforeUSDC = wETH.balanceOf(address(aggregator));

    //     console.log("balance of me for Wrapped Ether ", balanceBefore);
    //     console.log("balance of contract for wETH", balanceBeforeUSDC);

    //     deal(WETH, address(aggregator), 1e6 * 1e18);

    //     uint256 balanceAfterUSDC =wETH.balanceOf(address(aggregator));
    //     console.log("balanceAfterUSDC ", balanceAfterUSDC);

    //     bytes memory swapPath = abi.encode(2, 3000, 1);

    //     bytes memory message = abi.encode(
    //         swapPath,
    //         uint256(1e17),
    //         uint256(0),
    //         me,
    //         true
    //     );
    //     bytes memory srcAddr = abi.encode(CF_VAULT);
    //     // console.log("srcAddr ", srcAddr);
    //     // console.log("message ", message);
    //     uint256 amountOut = aggregator.cfReceive(
    //         1,
    //         srcAddr,
    //         message,
    //         PEPE,
    //         10e6
    //     );
    //     console.log("uniswap amountOut ", amountOut);
    //     uint256 balanceAfter = pepe.balanceOf(me);
    //     console.log("balance of me after uniswap swap", balanceAfter/1e18);
    //     vm.stopPrank();
    // }

    // function testCfRecieveMultiHop() public {
    //     vm.startPrank(CF_VAULT);
    //     IERC20 dai = IERC20(DAI);
    //     IERC20 wETH = IERC20(WETH);
    //     IERC20 usdc = IERC20(USDC);

    //     uint256 balanceDaiBefore = dai.balanceOf(me);
    //     console.log("balance of me for DAI ", balanceDaiBefore);

    //     deal(USDC, address(aggregator), 1e6 * 1e6);

    //     bytes memory path = abi.encodePacked(USDC, poolFee, WETH, poolFee, DAI);

    //     bytes memory message = abi.encode(
    //         path,
    //         uint256(10e6),
    //         uint256(0),
    //         me,
    //         false
    //     );

    //     bytes memory srcAddr = abi.encode(CF_VAULT);

    //     uint256 amountOut = aggregator.cfReceive(1, srcAddr, message, USDC, 0);

    //     console.log("uniswap amountOut ", amountOut);

    //     uint256 balanceDaiAfter = dai.balanceOf(me);
    //     console.log("balance of me after uniswap swap", balanceDaiAfter);
    //     assertEq(balanceDaiAfter, amountOut);

    //     vm.stopPrank();
    // }

    // function testCfRecieveDataFromRouter() public {
    //     IERC20 usdc = IERC20(USDC);
    //     // Swap data for WETH -> USDC from router sdk by uniswap v3
    //     bytes memory swapData = "0x5ae401dc0000000000000000000000000000000000000000000000000000000066a98b7700000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000e404e45aaf000000000000000000000000c02aaa39b223fe8d0a0e5c4f27ead9083c756cc2000000000000000000000000a0b86991c6218b36c1d19d4a2e9eb0ce3606eb4800000000000000000000000000000000000000000000000000000000000001f4000000000000000000000000f39fd6e51aad88f6f4ce6ab8827279cfffb922660000000000000000000000000000000000000000000000000de0b6b3a764000000000000000000000000000000000000000000000000000000000000c1862a84000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";

    //     console.log("swapData ", swapData);
    //     uint256 balanceBeforeUSDC = usdc.balanceOf(me);
    //     console.log("before ", balanceBeforeUSDC);

    //     vm.startPrank(CF_VAULT);
    //     deal(WETH, address(aggregator), 100 * 1e18);

    //     bytes memory message = abi.encode(
    //         swapData,
    //         uint256(10e6),
    //         uint256(0),
    //         me,
    //         false
    //     );

    //     bytes memory srcAddr = abi.encode(CF_VAULT);

    //     uint256 amountOut = aggregator.cfReceive(1, srcAddr, message, USDC, 0);

    //     console.log("uniswap amountOut ", amountOut);

    //     uint256 balanceAfterUSDC = usdc.balanceOf(me);
    //     console.log("after ", balanceAfterUSDC);
    // }

    // function testDirect() public {
    //     IERC20 Dai = IERC20(DAI);
    //     IERC20 link = IERC20(LINK);
    //     uint256 balanceBeforeDai = Dai.balanceOf(me);
    //     console.log("before ", balanceBeforeDai);
    //     deal(LINK, address(this), 100 * 1e18);

    //     link.approve(swapRouter02, 100 * 1e18);

    //     bytes
    //         memory path = hex"5ae401dc0000000000000000000000000000000000000000000000000000000066aae77600000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000e4472b43f30000000000000000000000000000000000000000000000000de0b6b3a7640000000000000000000000000000000000000000000000000000b4438a9dd121d6c0000000000000000000000000000000000000000000000000000000000000008000000000000000000000000067ff09c184d8e9e7B90C5187ED04cbFbDba741C80000000000000000000000000000000000000000000000000000000000000002000000000000000000000000514910771af9ca656af840dff83e8264ecf986ca0000000000000000000000006b175474e89094c44da98b954eedeac495271d0f00000000000000000000000000000000000000000000000000000000";
    //     // ISwapRouter.ExactInputParams memory params = abi.decode(path, (ISwapRouter.ExactInputParams));
    //     (bool success, bytes memory data) = swapRouter02.call(path);
    //     require(success, "swap failed");
    //     console.log("amount ", abi.decode(data, (uint256)));
    //     uint256 balanceAfterDai = Dai.balanceOf(me);
    //     console.log("after ", balanceAfterDai);
    // }

    function testCfRecieve() public {
        vm.startPrank(CF_VAULT);
        IERC20 link = IERC20(LINK);
        IERC20 dai = IERC20(DAI);
        uint256 balanceBeforeDai = dai.balanceOf(me);
        console.log("before ", balanceBeforeDai);
        deal(LINK, address(aggregator), 100 * 1e18);
        bytes memory srcAddr = abi.encode(CF_VAULT);
        bytes
            memory path = hex"5ae401dc0000000000000000000000000000000000000000000000000000000066ab178200000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000e4472b43f30000000000000000000000000000000000000000000000000de0b6b3a7640000000000000000000000000000000000000000000000000000b4438a9dd121d6c0000000000000000000000000000000000000000000000000000000000000008000000000000000000000000067ff09c184d8e9e7b90c5187ed04cbfbdba741c80000000000000000000000000000000000000000000000000000000000000002000000000000000000000000514910771af9ca656af840dff83e8264ecf986ca0000000000000000000000006b175474e89094c44da98b954eedeac495271d0f00000000000000000000000000000000000000000000000000000000";
        aggregator.cfReceive(1, srcAddr, path, LINK, 100*1e18);
        uint256 balanceAfterDai = dai.balanceOf(me);
        console.log("after ", balanceAfterDai);
        vm.stopPrank();
    }
}
