//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./DeployHelpers.s.sol";
import {UltraVerifier} from "../contracts/UltraVerifier.sol";
import {ZkTree} from "../contracts/ZkTree.sol";

contract DeployScript is ScaffoldETHDeploy {
    function run() external ScaffoldEthDeployerRunner {
        address owner = 0xd2aad578798Af2457Bba973b2b35e8DEA6b3d7a7;
        ZkTree zkTree = new ZkTree(owner, address(new UltraVerifier()));
        console.logString(
            string.concat(
                "YourContract deployed at: ", vm.toString(address(zkTree))
            )
        );
    }
}