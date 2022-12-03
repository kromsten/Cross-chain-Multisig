// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import { AxelarExecutable } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/executables/AxelarExecutable.sol';
import { IAxelarGateway } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGateway.sol';
import { IAxelarGasService } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGasService.sol';
import { IERC20 } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IERC20.sol';

contract Controller is AxelarExecutable {

    string private localChain;
    IAxelarGasService public immutable gasReceiver;

    bytes4 constant internal MAGICVALUE = 0x1626ba7e;

    mapping(bytes32 => bytes) public signatures;

    constructor(
        address gateway_, 
        address gasReceiver_, 
        string memory localChain_
    ) AxelarExecutable(gateway_) {
        gasReceiver = IAxelarGasService(gasReceiver_);
        this.localChain = localChain_;
    }


    function _execute(
        string calldata sourceChain_,
        string calldata sourceAddress_,
        bytes calldata payload_
    ) internal override  {
        require(false, 'Not implemented');
    }


    function approveSignature(
        string calldata destinationChain_,
        string calldata destinationAddress_,
        bytes32 hash_, 
        bytes memory signature_
    ) external payable {

        bytes memory payload = abi.encode(hash_, signature);

        if (equals(this.localChain, destinationChain_)) {
            signatures[hash_] = signature_:
        } else {
            if (msg.value > 0) {
                gasReceiver.payNativeGasForContractCall{ value: msg.value }(
                    address(this),
                    destinationChain_,
                    destinationAddress_,
                    payload,
                    msg.sender
                );
            }
            gateway.callContract(destinationChain, destinationAddress, payload);

        }
    }


    function isValidSignature(
        bytes32 _hash, 
        bytes memory _signature
    ) public view returns (bytes4 magicValue) {
        if (signatures[_hash] == _signature) return MAGICVALUE;
        else return 0xffffffff;
    }


     function equals(string memory a, string memory b) public pure returns (bool) {
        if(bytes(a).length != bytes(b).length) {
            return false;
        } else {
            return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
        }
     }

}
