// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {OffchainResolverFactory} from "../src/offchain-resolver/OffchainResolverFactory.sol";
import {OffchainResolver} from "../src/offchain-resolver/OffchainResolver.sol";

contract OffchainResolverFactoryTest is Test {
    OffchainResolver public offchainResolver;
    OffchainResolverFactory public factory;

    function setUp() public {
        offchainResolver = new OffchainResolver();
        factory = new OffchainResolverFactory(address(offchainResolver));
    }

    function test_Increment() public {
        address[] memory signers = new address[](1);
        signers[0] = address(this);
        string memory url = "https://example.com";
        factory.createOffchainResolver(url, signers);
    }
}
