// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {IExtendedResolver} from "@ensdomains/ens-contracts/resolvers/profiles/IExtendedResolver.sol";
import {IExtendedDNSResolver} from "@ensdomains/ens-contracts/resolvers/profiles/IExtendedDNSResolver.sol";
import {IAddressResolver} from "@ensdomains/ens-contracts/resolvers/profiles/IAddressResolver.sol";
import "solmate/auth/Owned.sol";

import "../utils/SupportsInterface.sol";
import "./SignatureVerifier.sol";

/**
 * Implements an ENS resolver that directs all queries to a CCIP read gateway.
 * Callers must implement EIP 3668 and ENSIP 10.
 */
contract OffchainResolver is
    SupportsInterface,
    Owned,
    Initializable,
    IExtendedResolver,
    IExtendedDNSResolver,
    IAddressResolver
{
    string public url;
    mapping(address => bool) public signers;

    event NewSigners(address[] signers);

    error OffchainLookup(
        address sender,
        string[] urls,
        bytes callData,
        bytes4 callbackFunction,
        bytes extraData
    );

    /**
     * Constructor
     */
    constructor() Owned(msg.sender) {
        _disableInitializers();
    }

    /**
     * Initializes the resolver with the given URL and signers.
     * This is required due to the minimal proxy pattern
     */
    function initialize(
        string memory _url,
        address[] memory _signers,
        address owner
    ) external initializer {
        url = _url;
        for (uint i = 0; i < _signers.length; i++) {
            signers[_signers[i]] = true;
        }
        emit NewSigners(_signers);
        Owned(owner);
    }

    /**
     * Helper function to generate signatures for the gateway.
     */
    function makeSignatureHash(
        address target,
        uint64 expires,
        bytes memory request,
        bytes memory result
    ) external pure returns (bytes32) {
        return
            SignatureVerifier.makeSignatureHash(
                target,
                expires,
                request,
                result
            );
    }

    /**
     * Resolves a name, as specified by ENSIP 10.
     * @param name The DNS-encoded name to resolve.
     * @param data The ABI encoded data for the underlying resolution function (Eg, addr(bytes32), text(bytes32,string), etc).
     * @return The return data, ABI encoded identically to the underlying function.
     */
    function resolve(
        bytes calldata name,
        bytes calldata data
    ) external view override returns (bytes memory) {
        bytes memory callData = abi.encodeWithSelector(
            IExtendedResolver.resolve.selector,
            name,
            data
        );
        string[] memory urls = new string[](1);
        urls[0] = url;
        revert OffchainLookup(
            address(this),
            urls,
            callData,
            OffchainResolver.resolveWithProof.selector,
            abi.encode(callData, address(this))
        );
    }

    /**
     * Resolves a name with gasless DNSSEC support, as specified by IExtendedDNSResolver.
     * @param name The DNS-encoded name to resolve.
     * @param data The ABI encoded data for the underlying resolution function (Eg, addr(bytes32), text(bytes32,string), etc).
     * @param context The context data from the DNS record.
     * @return The return data, ABI encoded identically to the underlying function.
     */
    function resolve(
        bytes calldata name,
        bytes calldata data,
        bytes calldata context
    ) external view override returns (bytes memory) {
        return this.resolve(name, data);
    }

    /**
     * Callback used by CCIP read compatible clients to verify and parse the response.
     */
    function resolveWithProof(
        bytes calldata response,
        bytes calldata extraData
    ) external view returns (bytes memory) {
        (address signer, bytes memory result) = SignatureVerifier.verify(
            extraData,
            response
        );
        require(signers[signer], "SignatureVerifier: Invalid sigature");
        return result;
    }

    /**
     * Sets the URL of the gateway.
     */
    function setURL(string calldata _url) external onlyOwner {
        url = _url;
    }

    /**
     * Sets the Signers of the gateway.
     */
    function setSigners(address[] calldata _signers) external onlyOwner {
        for (uint i = 0; i < _signers.length; i++) {
            signers[_signers[i]] = true;
        }
        emit NewSigners(_signers);
    }

    /**
     * Implements the ENS resolver interfaces.
     */
    function supportsInterface(
        bytes4 interfaceID
    ) public pure override returns (bool) {
        return
            interfaceID == type(IExtendedResolver).interfaceId ||
            interfaceID == type(IExtendedDNSResolver).interfaceId ||
            super.supportsInterface(interfaceID);
    }
}
