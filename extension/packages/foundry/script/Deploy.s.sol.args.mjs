export const deploymentsScriptsImports = `import {UltraVerifier} from "../contracts/UltraVerifier.sol";
import {ZkTree} from "../contracts/ZkTree.sol";`;
export const deploymentsLogic = `

    vm.startBroadcast(deployerPrivateKey);

    address owner = 0xd2aad578798Af2457Bba973b2b35e8DEA6b3d7a7;
    address ultraVerifier = address(new UltraVerifier());
    address zkTree = address(new ZkTree(owner, ultraVerifier));
    console.logString(
        string.concat(
            "UltraVerifier deployed at: ", vm.toString(ultraVerifier)
        )
    );
    console.logString(
        string.concat(
            "ZkTree deployed at: ", vm.toString(zkTree)
        )
    );

    vm.stopBroadcast();
`;