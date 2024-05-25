// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {OffchainResolverFactory} from "../src/offchain-resolver/OffchainResolverFactory.sol";
import {OffchainResolver} from "../src/offchain-resolver/OffchainResolver.sol";

contract COffchainResolverDeployScript is Script {
    function setUp() public {}

    function run() public {
        vm.broadcast();

        OffchainResolver _offchainResolver = new OffchainResolver();
        OffchainResolverFactory factory = new OffchainResolverFactory(address(_offchainResolver));
    }
}
