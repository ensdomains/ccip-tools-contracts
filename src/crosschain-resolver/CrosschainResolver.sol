// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {EVMFetcher} from "@ensdomains/evm-verifier/contracts/EVMFetcher.sol";
import {EVMFetchTarget} from "@ensdomains/evm-verifier/contracts/EVMFetchTarget.sol";
import {IEVMVerifier} from "@ensdomains/evm-verifier/contracts/IEVMVerifier.sol";

import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {IAddressResolver} from "@ensdomains/ens-contracts/resolvers/profiles/IAddressResolver.sol";
import {IExtendedResolver} from "@ensdomains/ens-contracts/resolvers/profiles/IExtendedResolver.sol";
import {IExtendedDNSResolver} from "@ensdomains/ens-contracts/resolvers/profiles/IExtendedDNSResolver.sol";
import "solmate/auth/Owned.sol";

import "../utils/SupportsInterface.sol";

/**
 * Implements an ENS resolver that leverages the EVMGateway to load from a remote chain.
 * Currently only supports optimism.
 * Callers must implement EIP 3668 and ENSIP 10.
 */
contract CrosschainResolver is
    SupportsInterface,
    Owned,
    Initializable,
    EVMFetchTarget,
    IAddressResolver
    // IExtendedResolver,
    // IExtendedDNSResolver
{
    using EVMFetcher for EVMFetcher.EVMFetchRequest;

    IEVMVerifier verifier;
    address public remote;

    /**
     * Constructor
     */
    constructor() Owned(msg.sender) {
        _disableInitializers();
    }

    /**
     * Initializes the resolver with the given remote address.
     * This is required due to the minimal proxy pattern
     */
    function initialize(
        string memory _remote,
        IEVMVerifier _verifier,
        address owner
    ) external initializer {
        remote = _remote;
        verifier = _verifier;
        Owned(owner);
    }

    // /**
    //  * Resolves a name, as specified by ENSIP 10.
    //  * @param name The DNS-encoded name to resolve.
    //  * @param data The ABI encoded data for the underlying resolution function (Eg, addr(bytes32), text(bytes32,string), etc).
    //  * @return The return data, ABI encoded identically to the underlying function.
    //  */
    // function resolve(
    //     bytes calldata name,
    //     bytes calldata data
    // ) external view override returns (bytes memory) {
    //     bytes memory callData = abi.encodeWithSelector(
    //         IExtendedResolver.resolve.selector,
    //         name,
    //         data
    //     );
    //     string[] memory urls = new string[](1);
    //     urls[0] = url;
    //     revert OffchainLookup(
    //         address(this),
    //         urls,
    //         callData,
    //         OffchainResolver.resolveWithProof.selector,
    //         abi.encode(callData, address(this))
    //     );
    // }

    // /**
    //  * Resolves a name with gasless DNSSEC support, as specified by IExtendedDNSResolver.
    //  * // this implementation disregards the "context" and calls the resolve function
    //  * @param name The DNS-encoded name to resolve.
    //  * @param data The ABI encoded data for the underlying resolution function (Eg, addr(bytes32), text(bytes32,string), etc).
    //  * @param context The context data from the DNS record.
    //  * @return The return data, ABI encoded identically to the underlying function.
    //  */
    // function resolve(
    //     bytes calldata name,
    //     bytes calldata data,
    //     bytes calldata context
    // ) external view override returns (bytes memory) {
    //     return this.resolve(name, data);
    // }

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
