// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import { StringToAddress, AddressToString } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/StringAddressUtils.sol';
import { AxelarExecutable } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/executables/AxelarExecutable.sol';
import { IAxelarGateway } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGateway.sol';
import { IAxelarGasService } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGasService.sol';
import { IERC20 } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IERC20.sol';


contract Controller is AxelarExecutable {

    IAxelarGasService public immutable gasReceiver;
    bytes4 constant internal MAGICVALUE = 0x1626ba7e;


    struct Message {
        uint64 nonce;
        bytes pubKey;
        bytes32
    }


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

    modifier sentWithMasterSignature(hash_: bytes32, signature_ : bytes) {
        require(recoverSigner(hash_, signature_) == this.masterSigner, 'Not a master signature');
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
        bytes32 calldata hash_,
        bytes calldata signature_
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
    }

    function addSignatureFromContract(
        string calldata destinationChain_,
        string calldata destinationAddress_,
        bytes calldata payload_,
    ) external payable {
        call(destinationChain_, destinationAddress_, payload_)
    }


    function addSignatureWithSignature(
        string calldata destinationChain_,
        string calldata destinationAddress_,
        bytes calldata payload_,
        bytes32 calldata hash_,
        bytes calldata signature_
    ) external payable  sentWithMasterSignature(hash_, signature_) {
        call(destinationChain_, destinationAddress_, payload_)
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


    function recoverSigner(
        bytes32 calldata _hash,
        bytes calldata _signature
    ) internal pure returns (address signer) {
        require(_signature.length == 65, "SignatureValidator#recoverSigner: invalid signature length");

        // Variables are not scoped in Solidity.
        uint8 v = uint8(_signature[64]);
        bytes32 r = _signature.readBytes32(0);
        bytes32 s = _signature.readBytes32(32);


        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            revert("SignatureValidator#recoverSigner: invalid signature 's' value");
        }

        if (v != 27 && v != 28) {
            revert("SignatureValidator#recoverSigner: invalid signature 'v' value");
        }

        // Recover ECDSA signer
        signer = ecrecover(_hash, v, r, s);
        
        // Prevent signer from being 0x0
        require(
            signer != address(0x0),
            "SignatureValidator#recoverSigner: INVALID_SIGNER"
        );

        return signer;
  }

}
