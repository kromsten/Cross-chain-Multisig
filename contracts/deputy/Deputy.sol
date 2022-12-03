// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import { AxelarExecutable } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/executables/AxelarExecutable.sol';
import { IAxelarGateway } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGateway.sol';
import { IAxelarGasService } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGasService.sol';
import { IERC20 } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IERC20.sol';

contract Deputy is AxelarExecutable {
    string public value;
    string private controllerChain;
    string private controllerAddress;
    IAxelarGasService public immutable gasReceiver;

    bytes4 constant internal MAGICVALUE = 0x1626ba7e;

    mapping(bytes32 => bytes) public signatures;

    constructor(
        address gateway_, 
        address gasReceiver_, 
        string memory controllerChain_, 
        string memory controllerAddress_
    ) AxelarExecutable(gateway_) {
        gasReceiver = IAxelarGasService(gasReceiver_);
        controllerChain = controllerChain_;
        controllerAddress = controllerAddress_;
    }

    modifier onlyController(string calldata sourceChain, string calldata sourceAddress_) {
        require(
            equals(this.controllerChain, sourceChain) && 
            equals(this.controllerAddress, sourceAddress_, "Not a controller contract");
        _;
    }


    function _execute(
        string calldata sourceChain_,
        string calldata sourceAddress_,
        bytes calldata payload_
    ) internal override onlyController(sourceChain_, sourceAddress_)  {
        (_hash, _signature) = abi.decode(payload_, (bytes32, bytes));
        signatures[_hash] = signature;
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
        r   eturn false;
        } else {
            return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
        }
     }

}
