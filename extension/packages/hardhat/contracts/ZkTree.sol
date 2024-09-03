// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IUltraVerifier {
    function verify(bytes calldata proof, bytes32[] calldata publicInputs) external view returns (bool);
}

/**
 * @title zkTree - a simple implementation of a zero knowledge merkle tree
 * @author https://github.com/nzmpi
 * @notice
 */
contract ZkTree {
    bytes32 constant MASK = 0x00000000000000000000000000000000000000000000000000000000000000ff;
    // keccak256 of bytes32(0)
    bytes32 constant ZERO_HASH = 0x290decd9548b62a8d60345a988386fc84ba6bc95484008f6362f93160ef3e563;
    address immutable public owner;
    // the merkle root when i-th leaf is updated
    // index => merkle root
    mapping(uint256 => bytes32) merkleRoots;
    // current tree
    // level => index => hash
    mapping(uint256 => mapping(uint256 => bytes32)) tree;
    // used nullifiers
    mapping(bytes32 => bool) nullifiers;
    // the verifier is deployed at 0x10440e2a89225CBC9D0C542D9d510744D94D9FbF on Sepolia
    IUltraVerifier ultraVerifier;
    // keep track of used indices
    uint256 indices;

    error ArrayIsFull();
    error FailedVerifier();
    error NotOwner();
    error UsedNullifier();
    error WrongIndex();

    event NewLeafAdded(uint256 index, bytes32[6] merklePath);

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    constructor(address _owner, address _ultraVerifier) payable {
        owner = _owner;
        ultraVerifier = IUltraVerifier(_ultraVerifier);
    }

    /**
     * Example function
     * @param proof - the proof
     * @param index - the index of the leaf
     * @param nullifierHash - the nullifier hash
     */
    function exampleFunction(bytes calldata proof, uint256 index, bytes32 nullifierHash) external {
        // check if the nullifier has been used
        if (nullifiers[nullifierHash]) {
            revert UsedNullifier();
        }
        nullifiers[nullifierHash] = true;

        // get the root
        bytes32 root = merkleRoots[index];
        if (root == bytes32(0)) {
            revert WrongIndex();
        }

        // check the proof
        if (!ultraVerifier.verify(proof, _getPublicInputs(root, nullifierHash))) {
            revert FailedVerifier();
        }

        // DO SOMETHING HERE
    }

    /**
     * Add a new leaf to the tree
     * @param leaf - the new leaf
     * @dev Leaf MUST be a poseidon hash of a secret!
     * @return index - the index of the new leaf in the tree
     * @return merklePath - the merkle path
     */
    function addLeaf(bytes32 leaf) external onlyOwner returns (uint256 index, bytes32[6] memory merklePath) {
        index = _updateIndex();
        tree[0][index] = leaf;
        merklePath = _updateTree(index, leaf);

        emit NewLeafAdded(index, merklePath);
    }

    /**
     * Remove a leaf from the tree
     * @param index - the index of the leaf to remove
     */
    function removeLeaf(uint256 index) external onlyOwner {
        if (index > 63) {
            revert WrongIndex();
        }
        delete tree[0][index];
        delete merkleRoots[index];
        // clear the bit
        indices &= ~(1 << index);

        bytes32 sibling;
        bytes32 hash = ZERO_HASH;
        for (uint256 level; level < 5;) {
            if (index % 2 == 0) {
                sibling = tree[level][index + 1];
                if (sibling == bytes32(0)) {
                    sibling = _getZeroHash(level);
                }
                hash = keccak256(abi.encode(hash, sibling));
            } else {
                sibling = tree[level][index - 1];
                if (sibling == bytes32(0)) {
                    sibling = _getZeroHash(level);
                }
                hash = keccak256(abi.encode(sibling, hash));
            }
            index /= 2;
            ++level;
            tree[level][index] = hash;
        }
    }

    /**
     * Get the merkle root at index
     * @param index - the index
     * @return the merkle root
     */
    function getMerkleRootAt(uint256 index) external view returns (bytes32) {
        return merkleRoots[index];
    }

    /**
     * Prepare the public inputs for the verifier
     * @dev Circuit expects 33 of 32 bytes inputs,
     * where root is given byte by byte
     * @param _root - the merkle root
     * @param _nullifierHash - the nullifier hash
     * @return result - the public inputs
     */
    function _getPublicInputs(bytes32 _root, bytes32 _nullifierHash) internal pure returns (bytes32[] memory result) {
        result = new bytes32[](33);
        for (uint256 i; i < 32; ++i) {
            result[i] = (_root >> (256 - (i + 1) * 8)) & MASK;
        }
        result[32] = _nullifierHash;
    }

    /**
     * Find and update the index
     * @return index - the new index
     */
    function _updateIndex() internal returns (uint256 index) {
        uint256 value = indices;
        if (value == 0xffffffffffffffff) {
            revert ArrayIsFull();
        }

        while (index < 64) {
            // find a zero bit
            if ((value >> index) & 1 == 0) {
                // set the bit
                indices = value | (1 << index);
                break;
            }
            ++index;
        }
    }

    /**
     * Update the merkle tree and return the merkle path
     * @param _index - the index of the leaf
     * @param _leaf - the new leaf
     * @return merklePath - the merkle path
     */
    function _updateTree(uint256 _index, bytes32 _leaf) internal returns (bytes32[6] memory merklePath) {
        bytes32 sibling;
        uint256 index = _index;
        bytes32 hash = _leaf;
        for (uint256 level; level < 5;) {
            if (index % 2 == 0) {
                sibling = tree[level][index + 1];
                if (sibling == bytes32(0)) {
                    sibling = _getZeroHash(level);
                }
                merklePath[level] = sibling;
                hash = keccak256(abi.encode(hash, sibling));
            } else {
                sibling = tree[level][index - 1];
                if (sibling == bytes32(0)) {
                    sibling = _getZeroHash(level);
                }
                merklePath[level] = sibling;
                hash = keccak256(abi.encode(sibling, hash));
            }
            index /= 2;
            ++level;
            tree[level][index] = hash;
        }

        // update the root
        if (index % 2 == 0) {
            sibling = tree[5][index + 1];
            if (sibling == bytes32(0)) {
                sibling = _getZeroHash(5);
            }
            merklePath[5] = sibling;
            hash = keccak256(abi.encode(hash, sibling));
        } else {
            sibling = tree[5][index - 1];
            if (sibling == bytes32(0)) {
                sibling = _getZeroHash(5);
            }
            merklePath[5] = sibling;
            hash = keccak256(abi.encode(sibling, hash));
        }
        merkleRoots[_index] = hash;
    }

    /**
     * Return the precalculated zero hash
     * @dev The default tree is populated with ZERO_HASH
     * @param _level - the level of the tree
     * @return zeroHash - the zero hash
     */
    function _getZeroHash(uint256 _level) internal pure returns (bytes32) {
        if (_level < 3) {
            if (_level < 2) {
                if (_level == 0) {
                    return ZERO_HASH;
                } else {
                    // level 1
                    return 0x633dc4d7da7256660a892f8f1604a44b5432649cc8ec5cb3ced4c4e6ac94dd1d;
                }
            } else {
                // level 2
                return 0x890740a8eb06ce9be422cb8da5cdafc2b58c0a5e24036c578de2a433c828ff7d;
            }
        } else {
            if (_level < 5) {
                if (_level == 3) {
                    return 0x3b8ec09e026fdc305365dfc94e189a81b38c7597b3d941c279f042e8206e0bd8;
                } else {
                    // level 4
                    return 0xecd50eee38e386bd62be9bedb990706951b65fe053bd9d8a521af753d139e2da;
                }
            } else {
                // level 5
                return 0xdefff6d330bb5403f63b14f33b578274160de3a50df4efecf0e0db73bcdd3da5;
            }
        }
    }
}
