// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ISquidRouter} from "@squid-interfaces/ISquidRouter.sol";
import {IVault} from "@chainflip-interfaces/IVault.sol";
import {ISquidMulticall} from "@squid-interfaces/ISquidMulticall.sol";

contract SquidAggregatorChainflip_V1 is Ownable {
    IVault cfVault;
    ISquidRouter router;
    ISquidMulticall squidMulticall;

    event SquidCCM(
        uint32 srcChain,
        bytes srcAddress,
        address token,
        uint256 amount,
        string destinationChain,
        string destinationAddress
    );

    constructor(
        address _router,
        address _cfVault,
        address _squidMulticall,
        address owner
    ) Ownable(owner) {
        router = ISquidRouter(_router);
        cfVault = IVault(_cfVault);
        squidMulticall = ISquidMulticall(_squidMulticall);
    }

    receive() external payable {}

    function setRouter(address _router) external onlyOwner {
        router = ISquidRouter(_router);
    }

    function getRouter() external view returns (ISquidRouter) {
        return router;
    }

    function setCFVault(address _cfVault) external onlyOwner {
        cfVault = IVault(_cfVault);
    }

    function getCFVault() external view returns (IVault) {
        return cfVault;
    }

    function cfReceive(
        uint32 srcChain,
        bytes calldata srcAddress,
        bytes calldata message,
        address token,
        uint256 amount
    ) external payable {
        require(msg.sender == address(cfVault), "only cfvault");
        (
            address squidToken,
            uint256 squidAmount,
            ISquidMulticall.Call[] memory calls,
            string memory bridgedTokenSymbol,
            string memory destinationChain,
            string memory destinationAddress,
            bytes memory payload,
            address gasRefundRecipient,
            bool enableExpress
        ) = abi.decode(
                message,
                (
                    address,
                    uint256,
                    ISquidMulticall.Call[],
                    string,
                    string,
                    string,
                    bytes,
                    address,
                    bool
                )
            );
        require(token == address(0), "token not supported");
        require(amount == 0, "amount not supported");
        router.callBridgeCall(
            squidToken,
            squidAmount,
            calls,
            bridgedTokenSymbol,
            destinationChain,
            destinationAddress,
            payload,
            gasRefundRecipient,
            enableExpress
        );
    }
}
