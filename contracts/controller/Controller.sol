// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import { StringToAddress, AddressToString } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/StringAddressUtils.sol';
import { AxelarExecutable } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/executables/AxelarExecutable.sol';
import { IAxelarGateway } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGateway.sol';
import { IAxelarGasService } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGasService.sol';
import { IERC20 } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IERC20.sol';
import { Secp256k1 } from './crypto/Secp256k1.sol';
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";


contract Controller is AxelarExecutable {

    IAxelarGasService public immutable gasReceiver;
    bytes4 constant internal MAGICVALUE = 0x1626ba7e;


    using StringToAddress for string;
    using AddressToString for address;

    string private localChain;
    address private masterSigner;
    address private masterContract;

    uint64 public nonce = 0;

    mapping(bytes32 => bytes) public signatures;


    modifier sentByMasterContract() {
        require(msg.sender == this.masterContract, 'Only a master contract can use this method');
        _;
    }


    modifier sentWithMasterSignature(bytes32 hash_, bytes memory signature_) {
        require(this.nonce_ == nonce, 'Invalid nonce');

        (address recovered, ECDSA.RecoverError error) = Secp256k1.tryRecover(hash_, signature_, 27);

        if (error == ECDSA.RecoverError.NoError && recovered != signer) {
            (recovered, error) = tryRecover(hash_, signature_, 28);
        }

        require(error == ECDSA.RecoverError.NoError && recovered == this.masterSigner, 'Not a master signature');

        _;
    }


    constructor(
        address gateway_, 
        address gasReceiver_, 
        string memory localChain_,
        address memory masterSigner_,
        address memory masterContract_
    ) AxelarExecutable(gateway_) {

        gasReceiver = IAxelarGasService(gasReceiver_);
        this.localChain = localChain_;

        if (!masterContract_ && !masterSigner_) {
            this.masterSigner = msg.sender;
        } else {
            if (masterSigner_) this.masterSigner = masterSigner_
            if (masterContract_) this.masterContract = masterContract_;
        }
    }
    

    function _execute(
        string calldata sourceChain_,
        string calldata sourceAddress_,
        bytes calldata payload_
    ) internal override  {
        revert('Not implemented');
    }



    function callFromContract(
        string calldata destinationChain_,
        string calldata destinationAddress_,
        bytes calldata payload_,
    ) external payable {
        call(destinationChain_, destinationAddress_, payload_)
    }


    function callWithSignature(
        string calldata destinationChain_,
        string calldata destinationAddress_,
        bytes calldata payload_,
        uint64 memory hash_, 
        bytes memory signature_
    ) external payable  sentWithMasterSignature(hash_, signature_) {
        call(destinationChain_, destinationAddress_, payload_)
    }


    function call(
        string calldata destinationChain_,
        string calldata destinationAddress_,
        bytes calldata payload_,
    ) internal {
        if (equals(this.localChain, destinationChain_)) {

            destinationAddress_.call{ value: msg.value }(data);

        } else {

            bytes memory wrappedPayload = abi.encode(true, payload_);

            if (msg.value > 0) {
                gasReceiver.payNativeGasForContractCall{ value: msg.value }(
                    address(this),
                    destinationChain_,
                    destinationAddress_,
                    payload,
                    msg.sender
                );
            }
            gateway.callContract(destinationChain, destinationAddress, wrappedPayload);
        }

        this.nonce += 1;
    }


    function addSignatureFromContract(
        string calldata destinationChain_,
        string calldata destinationAddress_,
        bytes32 calldata hash_,
        bytes calldata signature_
    ) external payable {
        saveSignature(destinationChain_, destinationAddress_, hash_, signature_)
    }


    function addSignatureWithSignature(
        string calldata destinationChain_,
        string calldata destinationAddress_,

        bytes32 memory storeHash_,
        bytes memory storeSignature_,

        uint64 memory hash_, 
        bytes memory signature_

    ) external payable  sentWithMasterSignature(hash, signature_) {
        saveSignature(destinationChain_, destinationAddress_, storeHash_, storeSignature_)
    }

    function addSignatureFromSignature(
        string calldata destinationChain_,
        string calldata destinationAddress_,

        uint64 memory hash_, 
        bytes memory signature_

    ) external payable  sentWithMasterSignature(hash, signature_) {
        saveSignature(destinationChain_, destinationAddress_, hash_, signature_)
    }



    function saveSignature(
        string calldata destinationChain_,
        string calldata destinationAddress_,
        bytes32 hash_, 
        bytes memory signature_
    ) external payable {

        if (equals(this.localChain, destinationChain_)) {

            signatures[hash_] = signature_:

        } else {

            bytes memory payload = abi.encode(hash_, signature_);
            bytes memory wrappedPayload = abi.encode(false, payload_);

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
