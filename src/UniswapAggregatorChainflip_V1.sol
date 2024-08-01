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

    address swapRouter02;
    error UniswapError();

    constructor(
        address owner,
        address _cfVault,
        address _swapRouter02
    ) Ownable(owner) {
        cfVault = IVault(_cfVault);
        swapRouter02 = _swapRouter02;
    }

    event BytesDebug(bytes);

    receive() external payable {}

    function setRouter(address _router) external onlyOwner {
        router = ISwapRouter(_router);
    }

    function getRouter() external view returns (address) {
        return address(router);
    }

    function cfReceive(
        uint32 srcChain,
        bytes calldata srcAddress,
        bytes calldata message,
        address token,
        uint256 amount
    ) external payable returns (uint256 amountOut) {
        require(msg.sender == address(cfVault), "only router");
        if (msg.value > 0) {

        } else {
            IERC20(token).approve(swapRouter02, amount);
            (bool _success, ) = swapRouter02.call(message);
            if (!_success) {
                revert UniswapError();
            }
        }

        emit UniswapCCM(srcChain, srcAddress, token, amount);
    }

    function _isNotZero(address token) internal pure returns (bool) {
        require(token != address(0), "token is zero");
    }
}
