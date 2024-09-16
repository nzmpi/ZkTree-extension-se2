//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./DeployHelpers.s.sol";
import {UltraVerifier} from "../contracts/UltraVerifier.sol";
import {ZkTree} from "../contracts/ZkTree.sol";

contract DeployScript is ScaffoldETHDeploy {
  error InvalidPrivateKey(string);

  function run() external {
    uint256 deployerPrivateKey = setupLocalhostEnv();
    if (deployerPrivateKey == 0) {
      revert InvalidPrivateKey(
        "You don't have a deployer account. Make sure you have set DEPLOYER_PRIVATE_KEY in .env or use `yarn generate` to generate a new random account"
      );
    }
    vm.startBroadcast(deployerPrivateKey);

    address owner = 0xd2aad578798Af2457Bba973b2b35e8DEA6b3d7a7;
    ZkTree zkTree = new ZkTree(owner, address(new UltraVerifier()));
    console.logString(
        string.concat(
            "ZkTree deployed at: ", vm.toString(address(zkTree))
        )
    );

    vm.stopBroadcast();

    /**
     * This function generates the file containing the contracts Abi definitions.
     * These definitions are used to derive the types needed in the custom scaffold-eth hooks, for example.
     * This function should be called last.
     */
    exportDeployments();
  }

  function test() public { }
}
