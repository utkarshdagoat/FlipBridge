// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;
pragma abicoder v2;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ISwapRouter} from "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import {TransferHelper} from "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import {IVault} from "@chainflip-interfaces/IVault.sol";
import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";
contract UniswapAggregatorChainflip_V1 is Ownable {
    ISwapRouter router;
    IVault cfVault;
    using SafeCast for uint256;

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
        tokenCount = tokens.length.toUint32();
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
            bytes memory swapPath,
            uint256 amountIn,
            uint256 amountOutMin,
            address recipient,
            bool single
        ) = abi.decode(
                message,
                (bytes, uint256, uint256,  address, bool)
            );
        if (single) {
            (uint32 tokenIn,uint24 poolFee,uint32 tokenOut) = abi.decode(swapPath, (uint32,uint24,uint32));
            amountOut = _singleHopSwapExactInputAmount(
                amountIn,
                amountOutMin,
                tokenIn,
                tokenOut,
                poolFee,
                recipient
            );
        }else {
            amountOut = this._exactInput(swapPath, recipient, amountIn, amountOutMin, token);
        }

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

    ///@dev had to change it to external for implicit conversion from bytes memory to bytes calldata
    function _exactInput(
        bytes calldata path,
        address recipient,
        uint256 amountIn,
        uint256 amountOutMinimum,
        address token
    ) public returns (uint256 amountOut){
        TransferHelper.safeApprove(token, address(router), amountIn);
        ISwapRouter.ExactInputParams memory params = ISwapRouter.ExactInputParams({
            path: path,
            recipient: recipient,
            deadline: block.timestamp,
            amountIn: amountIn,
            amountOutMinimum: amountOutMinimum
        });
        return router.exactInput(params);
    }

    function _isNotZero(address token) internal pure returns (bool) {
        require(token != address(0), "token is zero");
    }
}
