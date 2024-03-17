// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {OffchainResolverFactory} from "../src/OffchainResolverFactory.sol";

contract OffchainResolverFactoryTest is Test {
    OffchainResolverFactory public factory;

    function setUp() public {
        factory = new OffchainResolverFactory();
    }

    function test_Increment() public {
        address[] memory signers = new address[](1);
        signers[0] = address(this);
        string memory url = "https://example.com";
        factory.createOffchainResolver(url, signers);
    }
}
