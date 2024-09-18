# ZkTree

This is an extension for [Scaffold-ETH 2](https://github.com/scaffold-eth/scaffold-eth-2), which implements a zero knowledge Merkle tree.
I made it as general as possible to make it easy to use in different projects. 

This extension is built as a core part for more complex projects that need ZK Merkle trees. 

## Installation

First use `npx create-eth@latest -e nzmpi/ZkTree-extension-se2` to create a new SE-2 project with this extension. Then update the owner of the contract [here](https://github.com/nzmpi/ZkTree-extension-se2/blob/master/extension/packages/hardhat/deploy/01_deploy_ZkTree.ts#L34) for Hardhat or [here](https://github.com/nzmpi/ZkTree-extension-se2/blob/master/extension/packages/foundry/script/Deploy.s.sol.args.mjs#L7) for Foundry.

Then use `yarn chain` in the first terminal to start a local chain, in the second terminal run `yarn start` to start your NextJS app and in the third terminal `yarn deploy` to deploy all contracts.

## What is it about?

This extension helps devs implement zero-knowledge Merkle trees in their projects without having to write a ZK circuit and a Solidity contract.

## How it works

### ZK Circuit

The circuit itself can be found in [here](https://github.com/nzmpi/ZkTree-extension-se2/blob/master/extension/packages/circuit/src/main.nr). It is written in Noir. Everything is written and [the Solidity verifier](https://github.com/nzmpi/ZkTree-extension-se2/blob/master/extension/packages/hardhat/contracts/UltraVerifier.sol) is deployed on [Sepolia](https://sepolia.etherscan.io/address/0x10440e2a89225cbc9d0c542d9d510744d94d9fbf). It is not needed for the extension, but if you want to update it or just curious feel free to check it.

There are some restrictions, that developers should be aware of. The first one is the tree only supports 64 leaves. Otherwise it's impossible to generate a proof for it on the frontend with more leaves. The second one is a leaf must be a poseidon hash of a secret. The last one is the nullifier must be an array of [leaf index, secret, caller address, leaf]. And the nullifier hash is the poseidon hash of the nullifier. All of this can be calculated using the frontend. The only public inputs needed to verify the proof on-chain are the root and the nullifier hash.

### Solidity contract

The [ZkTree](https://github.com/nzmpi/ZkTree-extension-se2/blob/master/extension/packages/hardhat/contracts/ZkTree.sol) contract is a basic Solidity contract that implements and maintains the Merkle Tree. You can add leaves, which also will recalculate the tree (here we use keccak256) and return the index of the leaf and its Merkle path (or also called as Merkle proof). 

To save on gas, only affected nodes will be updated in the tree and all indices of the leaves are kept in one storage slot. The `exampleFunction` is an entry point for users, where they provide the proof and public inputs to the contract to verify.

## How to use frontend

I also made basic components for the frontend that may help you to use the extension:

- Get [hash](https://github.com/nzmpi/ZkTree-extension-se2/blob/master/extension/packages/nextjs/app/ZkTree/page.tsx#L127-L130) of the secret

- Get poseidon [hash](https://github.com/nzmpi/ZkTree-extension-se2/blob/master/extension/packages/nextjs/app/ZkTree/page.tsx#L132-L134) of a secret to create a leaf

- [Add](https://github.com/nzmpi/ZkTree-extension-se2/blob/master/extension/packages/nextjs/app/ZkTree/page.tsx#L67-L84) and [remove](https://github.com/nzmpi/ZkTree-extension-se2/blob/master/extension/packages/nextjs/app/ZkTree/page.tsx#L86-L102) leaves from the contract

- Get the poseidon [hash](https://github.com/nzmpi/ZkTree-extension-se2/blob/master/extension/packages/nextjs/app/ZkTree/page.tsx#L136-L143) of the nullifier

- Create the [proof](https://github.com/nzmpi/ZkTree-extension-se2/blob/master/extension/packages/nextjs/app/ZkTree/page.tsx#L155-L176) (off-chain) and verify it ([off-chain](https://github.com/nzmpi/ZkTree-extension-se2/blob/master/extension/packages/nextjs/app/ZkTree/page.tsx#L187-L202) and [on-chain](https://github.com/nzmpi/ZkTree-extension-se2/blob/master/extension/packages/nextjs/app/ZkTree/page.tsx#L104-L125))

To not limit devs and users with their secrets, the original secret can be anything. But the circuit will expect a secret that can be fit in the `Field` type. To achieve that we use the `id` function on the frontend, that will compute the UTF-8 bytes and the keccak256 of the secret. Then we will `mod` the result by `ORDER = 0x30644e72e131a029b85045b68181585d2833e84879b9709143e1f593f0000001`, which is the order of the curve used in the ZK circuit. The result should be used as a secret for the circuit.

The frontend can be found in [here](https://github.com/nzmpi/ZkTree-extension-se2/blob/master/extension/packages/nextjs/app/ZkTree/page.tsx).
