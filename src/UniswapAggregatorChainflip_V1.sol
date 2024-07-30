// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;
pragma abicoder v2;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ISwapRouter} from "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import {TransferHelper} from "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import {IVault} from "@chainflip-interfaces/IVault.sol";

contract UniswapAggregatorChainflip_V1 is Ownable {
    ISwapRouter router;
    IVault cfVault;

    event UniswapCCM(
        uint32 srcChain,
        bytes srcAddress,
        address token,
        uint256 amount
    );
    event Debug(string src);

    address constant ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    /// This is a mapping of token address to chain address to reduce the message and thus reducing the gas cost
    mapping(uint32 => address) public tokenToAddress;
    uint32 public tokenCount;

    constructor(
        address _router,
        address owner,
        address[] memory tokens,
        address _cfVault
    ) Ownable(owner) {
        router = ISwapRouter(_router);
        for (uint32 i = 1; i <= tokens.length; i++) {
            tokenToAddress[i] = tokens[i - 1];
        }
        cfVault = IVault(_cfVault);

        //TODO: Add safe cast for uint32->uint256
        tokenCount = uint32(tokens.length);
    }

    receive() external payable {}

    function setRouter(address _router) external onlyOwner {
        router = ISwapRouter(_router);
    }

    function getRouter() external view returns (address) {
        return address(router);
    }

    function addToken(address _token) external returns (uint256) {
        tokenCount++;
        tokenToAddress[tokenCount] = _token;
        return tokenCount;
    }

    function getToken(uint32 tokenId) external view returns (address) {
        return tokenToAddress[tokenId];
    }

    function cfReceive(
        uint32 srcChain,
        bytes calldata srcAddress,
        bytes calldata message,
        address token,
        uint256 amount
    ) external payable returns (uint256 amountOut) {
        require(msg.sender == address(cfVault), "only router");
        emit Debug("Called");
        (
            uint32 tokenIn,
            uint32 tokenOut,
            uint256 amountIn,
            uint256 amountOutMin,
            uint24 poolFee,
            address recipient
        ) = abi.decode(
                message,
                (uint32, uint32, uint256, uint256, uint24, address)
            );

        amountOut = _singleHopSwapExactInputAmount(
            amountIn,
            amountOutMin,
            tokenIn,
            tokenOut,
            poolFee,
            recipient
        );
        emit UniswapCCM(srcChain, srcAddress, token, amount);
    }

    function _singleHopSwapExactInputAmount(
        uint256 amountIn,
        uint256 amountOutMin,
        uint32 inputToken,
        uint32 outputToken,
        uint24 poolFee,
        address recipient
    ) internal returns (uint256) {
        address tokenIn = tokenToAddress[inputToken];
        address tokenOut = tokenToAddress[outputToken];

        _isNotZero(tokenIn);
        _isNotZero(tokenOut);

        TransferHelper.safeApprove(tokenIn, address(router), amountIn);
        emit Debug("approved");

        ISwapRouter.ExactInputSingleParams memory paramas = ISwapRouter
            .ExactInputSingleParams({
                tokenIn: tokenIn,
                tokenOut: tokenOut,
                fee: poolFee,
                recipient: recipient,
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: amountOutMin,
                sqrtPriceLimitX96: 0
            });
        emit Debug("Called swap");
        return router.exactInputSingle(paramas);
    }

    function _isNotZero(address token) internal pure returns (bool) {
        require(token != address(0), "token is zero");
    }
}
