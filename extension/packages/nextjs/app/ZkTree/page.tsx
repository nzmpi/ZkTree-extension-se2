"use client";

import Link from "next/link";
import type { NextPage } from "next";
import { useState, useEffect } from "react";
import { CopyToClipboard } from "react-copy-to-clipboard";
import { id, toBeArray, toBeHex, toBigInt, hexlify, ZeroHash } from "ethers";
import { poseidon1, poseidon4 } from "poseidon-lite";
import { BarretenbergBackend, ProofData } from "@noir-lang/backend_barretenberg";
import { Noir, InputMap } from "@noir-lang/noir_js";
import { CheckCircleIcon, DocumentDuplicateIcon } from "@heroicons/react/24/outline";
import { AddressInput, Bytes32Input, BytesInput, IntegerInput } from "~~/components/scaffold-eth";
import { useScaffoldWriteContract, useScaffoldReadContract } from "~~/hooks/scaffold-eth";
import circuit from "../../../circuit/target/circuit.json";

const ZkTree: NextPage = () => {
  // max allowed number in the zk circuit
  const ORDER = BigInt("0x30644e72e131a029b85045b68181585d2833e84879b9709143e1f593f0000001");
  
  const compiledCircuit = JSON.parse(JSON.stringify(circuit));
  const backend = new BarretenbergBackend(compiledCircuit);
  const noir = new Noir(compiledCircuit);

  const [secret, setSecret] = useState("");
  const [hashedSecret, setHashedSecret] = useState("");
  const [hashedSecretForLeaf, setHashedSecretForLeaf] = useState("");
  const [leaf, setLeaf] = useState("");
  const [leafForTree, setLeafForTree] = useState("");
  const [index, setIndex] = useState(-1);
  const [merklePath, setMerklePath] = useState([""]);
  const [leafToRemove, setLeafToRemove] = useState("");
  const [indexForRoot, setIndexForRoot] = useState("");
  const [indexForNullifier, setIndexForNullifier] = useState("");
  const [hashedSecretForNullifier, setHashedSecretForNullifier] = useState("");
  const [callerForNullifier, setCallerForNullifier] = useState("");
  const [leafForNullifier, setLeafForNullifier] = useState("");
  const [nullifierHash, setNullierHash] = useState("");
  const [indexForProof, setIndexForProof] = useState("");
  const [hashedSecretForProof, setHashedSecretForProof] = useState("");
  const [callerForProof, setCallerForProof] = useState("");
  const [leafForProof, setLeafForProof] = useState("");
  const [rootForProof, setRootForProof] = useState("");
  const [merklePathArray, setMerklePathArray] = useState("");
  const [merklePathForProof, setMerklePathForProof] = useState([""]);
  const [nullifierHashForProof, setNullierHashForProof] = useState("");
  const [proof, setProof] = useState("");
  const [calculatingProof, setCalculatingProof] = useState(false);
  const [proofToVerify, setProofToVerify] = useState("");
  const [rootToVerify, setRootToVerify] = useState("");
  const [nullifierHashToVerify, setNullifierHashToVerify] = useState("");
  const [isVerified, setIsVerified] = useState(false);
  const [isValid, setIsValid] = useState(false);
  const [verifying, setVerifying] = useState(false);
  const [indexForContract, setIndexForCcontract] = useState("");
  const [proofForContract, setProofForContract] = useState("");
  const [nullifierHashForContract, setNullifierHashForContract] = useState("");
  const [isValidForContract, setIsValidForContract] = useState(false);
  const [isCopied, setIsCopied] = useState(false);
  const { writeContractAsync, isPending } = useScaffoldWriteContract("ZkTree");

  const { data: RetrievedRoot } = useScaffoldReadContract({
    contractName: "ZkTree",
    functionName: "getMerkleRootAt",
    args: [BigInt(indexForRoot)],
  });

  const addLeaf = async () => {
    try {
      await writeContractAsync(
        {
          functionName: "addLeaf",
          args: [`0x${leafForTree.slice(2)}`],
        },
        {
          onBlockConfirmation: txnReceipt => {
            console.log("📦 Transaction blockHash", txnReceipt.blockHash);
            getIndexAndMerklePath(txnReceipt.logs[0].data);
          },
        },
      );
    } catch (e) {
      console.error("Error adding leaf", e);
    }
  };

  const removeLeaf = async () => {
    try {
      await writeContractAsync(
        {
          functionName: "removeLeaf",
          args: [BigInt(leafToRemove)],
        },
        {
          onBlockConfirmation: txnReceipt => {
            console.log("📦 Transaction blockHash", txnReceipt.blockHash);
          },
        },
      );
    } catch (e) {
      console.error("Error removing leaf", e);
    }
  };

  const exampleFunction = async () => {
    try {
      await writeContractAsync(
        {
          functionName: "exampleFunction",
          args: [
            `0x${proofForContract.slice(2)}`,
            BigInt(indexForContract),
            `0x${nullifierHashForContract.slice(2)}`
          ],
        },
        {
          onBlockConfirmation: txnReceipt => {
            console.log("📦 Transaction blockHash", txnReceipt.blockHash);
            setIsValidForContract(true);
          },
        },
      );
    } catch (e) {
      console.error("Error calling example function", e);
    }
  };

  const hashSecret = () => {
    // keccak256 mod ORDER
    setHashedSecret(toBeHex(toBigInt(id(secret)) % ORDER));
  };

  const getLeafFromSecret = () => {
    setLeaf(toBeHex(poseidon1([hashedSecretForLeaf])));
  };

  const getNullifierHash = () => {
    setNullierHash(toBeHex(poseidon4([
      Number(indexForNullifier),
      hashedSecretForNullifier,
      callerForNullifier,
      leafForNullifier
    ])));
  }

  const getIndexAndMerklePath = (data: string) => {
    let temp = [];
    setIndex(Number(data.slice(2, 66)));
    data = data.slice(66);
    for (let i = 0; i < 6; i++) {
      temp.push("0x" + data.slice(i * 64, i * 64 + 64));
    }
    setMerklePath(temp);
  };

  const calculateProof = async () => {
    const merklePathInput: any[] = [];
    for (let i = 0; i < merklePathForProof.length; i++) {
      merklePathInput.push(padArray(Array.from(toBeArray(merklePathForProof[i]))));
    }

    const input: InputMap = {
      index: Number(indexForProof),
      secret: hashedSecretForProof,
      caller: callerForProof,
      leaf: leafForProof,
      root: padArray(Array.from(toBeArray(rootForProof))),
      merkle_path: merklePathInput,
      nullifier_hash: nullifierHashForProof
    };

    const { witness } = await noir.execute(input);
    setCalculatingProof(true);
    const proof = await backend.generateProof(witness);
    setProof(hexlify(proof.proof));
    setCalculatingProof(false);
  }
  
  const padArray = (arr: number[]) => {
    if (arr.length == 32) {
      return arr;
    } else {
      const start = new Array(32 - arr.length).fill(0);
      return start.concat(arr);
    }
  }

  const verifyProof = async () => {
    let publicInputs: string[] = [];
    for (let i = 2; i < 66; i += 2) {
      publicInputs.push("0x" + (rootToVerify[i] + rootToVerify[i + 1]).toString().padStart(64, "0"))
    }
    publicInputs.push(nullifierHashToVerify);
    let proof: ProofData = {
      proof: toBeArray(proofToVerify),
      publicInputs: publicInputs
    }
    setVerifying(true);
    const isValid = await backend.verifyProof(proof);
    setIsValid(isValid);
    setVerifying(false);
    setIsVerified(true);
  }

  const shorten = (input: string) => {
    const temp = input.slice(0, 6) + "..." + input.slice(-4);
    return <p className="flex items-center text-lg mt-1 ml-4">
      {temp}
      {isCopied ? (
        <CheckCircleIcon
          className="ml-1.5 text-xl font-normal text-white-600 h-5 w-5 cursor- mx-2.5"
          aria-hidden="true"
        />) : (
          <CopyToClipboard
            text={input}
            onCopy={() => {
              setIsCopied(true);
              setTimeout(() => {
                setIsCopied(false);
              }, 800);
            }}
          >
          <DocumentDuplicateIcon
            className="text-xl font-normal text-white-600 h-5 w-5 cursor-pointer mx-2"
          />
          </CopyToClipboard>
        )
      }
    </p>;
  }

  const shortenMerklePath = (input: string[]) => {
    const temp = input.map(a => a.slice(0, 6) + "..." + a.slice(-4));
    let res = "[";
    for (let i = 0; i < input.length; i++) {
      res += input[i] + ", ";
    }
    res += res.slice(0, -2) + "]";
    return <p className="flex items-center text-lg mt-1 ml-4">
      [{temp[0]},
      {" " + temp[1]},
      {" " + temp[2]},
      {" " + temp[3]},
      {" " + temp[4]},
      {" " + temp[5]}]
      {isCopied ? (
        <CheckCircleIcon
          className="ml-1.5 text-xl font-normal text-white-600 h-5 w-5 cursor- mx-2.5"
          aria-hidden="true"
        />) : (
          <CopyToClipboard
            text={res}
            onCopy={() => {
              setIsCopied(true);
              setTimeout(() => {
                setIsCopied(false);
              }, 800);
            }}
          >
          <DocumentDuplicateIcon
            className="text-xl font-normal text-white-600 h-5 w-5 cursor-pointer mx-2"
          />
          </CopyToClipboard>
        )
      }
    </p>;
  }

  useEffect(() => {
    setHashedSecret("");
  }, [secret]);

  useEffect(() => {
    setLeaf("");
  }, [hashedSecretForLeaf]);

  useEffect(() => {
    setIndex(-1);
    setMerklePath([""]);
  }, [leafForTree]);

  useEffect(() => {
    setNullierHash("");
  }, [indexForNullifier, hashedSecretForNullifier, callerForNullifier, leafForNullifier]);

  useEffect(() => {
    if (merklePathArray.length === 0) {
      return;
    }
    let temp = [];
    for (let i = 0; i < merklePathArray.length; i++) {
      if (merklePathArray[i] === "0" && merklePathArray[i + 1] === "x") {
        temp.push(merklePathArray.slice(i, i + 66));
        i += 66;
      }
    }
    setMerklePathForProof(temp);
  }, [merklePathArray]);

  useEffect(() => {
    setProof("");
  }, [indexForProof, hashedSecretForProof, callerForProof, leafForProof, rootForProof, merklePathArray, nullifierHashForProof]);

  useEffect(() => {
    setIsVerified(false);
  }, [proofToVerify, rootToVerify, nullifierHashToVerify]);

  useEffect(() => {
    setIsValidForContract(false);
  }, [indexForContract, proofForContract, nullifierHashForContract]);

  return (
    <>
      <div className="flex items-center flex-col flex-grow pt-10">
        <div className="px-5">
          <h1 className="text-center">
            <span className="block text-2xl mb-2">Welcome to</span>
            <span className="block text-4xl font-bold">ZkTree</span>
          </h1>
          <p className="text-center text-lg">
            This extension implements Zero Knowledge Merkle Tree.
          </p>
          <p className="text-center text-lg">
            Here you can find basic components to get started. More info can be found in{" "}
              <Link href="https://github.com/nzmpi/ZkTree-extension-se2/blob/master/README.md" passHref className="link">
                README
              </Link>
              .
          </p>
        </div>
        <div className="flex items-center flex-col flex-grow rounded-3xl shadow-xl border-2 px-5">
          <p className="text-center text-lg">
            Get your hashed secret:
          </p>
          <input
            type="text"
            placeholder="Your secret"
            className="input border border-primary"
            onChange={e => setSecret(e.target.value)}
          />
          <div className="pt-3 py-5">
            <button className="btn btn-primary" onClick={hashSecret} disabled={secret == ""}>
              {"Hash"}
            </button>
          </div>
          {hashedSecret != "" && (
            <p className="text-center text-lg -mt-2">
              Your hashed secret:
              {shorten(hashedSecret)}
            </p>)
          }
        </div>
        <div className="flex items-center flex-col flex-grow rounded-3xl shadow-xl border-2 px-5 mt-5">
          <p className="text-center text-lg">
            Get a new leaf from a hashed secret:
          </p>
          <Bytes32Input
            name="hashedSecretForLeaf"
            value={hashedSecretForLeaf}
            placeholder="Hashed secret"
            onChange={value => setHashedSecretForLeaf(value)}
          />
          <div className="pt-3 py-5">
            <button className="btn btn-primary" onClick={getLeafFromSecret} disabled={hashedSecretForLeaf == ""}>
              {"Get"}
            </button>
          </div>
          {leaf != "" && (
          <p className="text-center text-lg -mt-2">
            Your leaf:
            {shorten(leaf)}
          </p>)}
        </div>
        <div className="flex items-center flex-col flex-grow rounded-3xl shadow-xl border-2 px-5 mt-5">
          <p className="text-center text-lg">
            Add a new leaf to the tree:
          </p>
          <Bytes32Input
            name="leafForTree"
            value={leafForTree}
            placeholder="Leaf"
            onChange={value => setLeafForTree(value)}
          />
          <div className="pt-3 py-5">
            <button className="btn btn-primary" onClick={addLeaf} disabled={isPending || leafForTree == ""}>
              {isPending ? <span className="loading loading-spinner loading-sm"></span> : "Add"}
            </button>
          </div>
          {index != -1 && (
            <p className="text-center text-lg -mt-2">
              Your index: {index}
            </p>)}
          {merklePath[0] != "" && (<p className="text-center text-lg -mt-2">
            Your merkle path:
            {shortenMerklePath(merklePath)}
          </p>)}
        </div>
        <div className="flex items-center flex-col flex-grow rounded-3xl shadow-xl border-2 px-5 mt-5">
          <p className="text-center text-lg">
            Remove a leaf from the tree:
          </p>
          <IntegerInput
            name="leafToRemove"
            value={leafToRemove}
            placeholder="Index"
            onChange={value => setLeafToRemove(value.toString())}
          />
          <div className="pt-3 py-5">
            <button className="btn btn-primary" onClick={removeLeaf} disabled={isPending || leafToRemove == ""}>
              {isPending ? <span className="loading loading-spinner loading-sm"></span> : "Remove"}
            </button>
          </div>
        </div>
        <div className="flex items-center flex-col flex-grow rounded-3xl shadow-xl border-2 px-5 mt-5 py-3">
          <p className="text-center text-lg">
            Get the root of the tree at:
          </p>
          <IntegerInput
            name="indexForRoot"
            value={indexForRoot}
            placeholder="Index"
            onChange={value => setIndexForRoot(value.toString())}
          />
          {indexForRoot != "" && RetrievedRoot == ZeroHash && (
          <p className="text-center text-lg">
            No Root!
          </p>)}
          {indexForRoot != "" && RetrievedRoot != ZeroHash && RetrievedRoot && (
          <p className="text-center text-lg">
            Your root:
            {shorten(RetrievedRoot.toString())}
          </p>)}
        </div>
        <div className="flex items-center flex-col flex-grow rounded-3xl shadow-xl border-2 px-5 mt-5">
          <p className="text-center text-lg">
            Get the nullifier hash:
          </p>
          <div className="mt-1">  
          <IntegerInput
            name="indexForNullifier"
            value={indexForNullifier}
            placeholder="Index"
            onChange={value => setIndexForNullifier(value.toString())}
          />
          </div>
          <div className="mt-3">
          <Bytes32Input
            name="hashedSecretForNullifier"
            value={hashedSecretForNullifier}
            placeholder="Hashed secret"
            onChange={value => setHashedSecretForNullifier(value)}
          />
          </div>
          <div className="mt-3">
          <AddressInput
            name="callerForNullifier"
            value={callerForNullifier}
            placeholder="Caller"
            onChange={value => setCallerForNullifier(value)}
          />
          </div>
          <div className="mt-3">
          <Bytes32Input
            name="leafForNullifier"
            value={leafForNullifier}
            placeholder="Leaf"
            onChange={value => setLeafForNullifier(value)}
          />
          </div>
          <div className="pt-3 py-5">
            <button className="btn btn-primary" onClick={getNullifierHash}
                    disabled={indexForNullifier == "" || hashedSecretForNullifier == "" || callerForNullifier == "" || leafForNullifier == ""}>
              Hash
            </button>
          </div>
          {nullifierHash != "" && (
          <p className="text-center text-lg -mt-2">
            Your nullifier hash:
            {shorten(nullifierHash)}
          </p>)}
        </div>
        <div className="flex items-center flex-col flex-grow rounded-3xl shadow-xl border-2 px-5 mt-5">
          <p className="text-center text-lg">
            Create proof (takes few minutes!):
          </p>
          <div className="mt-1">
          <input
            type="text"
            placeholder="Merkle path"
            value={merklePathArray}
            className="input border border-primary"
            onChange={e => setMerklePathArray(e.target.value)}
          />
          </div>
          <div className="mt-3">
          <IntegerInput
            name="indexForProof"
            value={indexForProof}
            placeholder="Index"
            onChange={value => setIndexForProof(value.toString())}
          />
          </div>
          <div className="mt-3">
          <Bytes32Input
            name="hashedSecretForProof"
            value={hashedSecretForProof}
            placeholder="Hashed secret"
            onChange={value => setHashedSecretForProof(value)}
          />
          </div>
          <div className="mt-3">
          <AddressInput
            name="callerForProof"
            value={callerForProof}
            placeholder="Caller"
            onChange={value => setCallerForProof(value)}
          />
          </div>
          <div className="mt-3">
          <Bytes32Input
            name="leafForProof"
            value={leafForProof}
            placeholder="Leaf"
            onChange={value => setLeafForProof(value)}
          />
          </div>
          <div className="mt-3">
          <Bytes32Input
            name="rootForProof"
            value={rootForProof}
            placeholder="Root"
            onChange={value => setRootForProof(value)}
          />
          </div>
          <div className="mt-3">
          <Bytes32Input
            name="nullifierHashForProof"
            value={nullifierHashForProof}
            placeholder="Nullifier Hash"
            onChange={value => setNullierHashForProof(value)}
          />
          </div>
          <div className="pt-3 py-5">
            <button className="btn btn-primary" onClick={calculateProof}
                    disabled={calculatingProof || indexForProof == "" || hashedSecretForProof == "" || callerForProof == "" || leafForProof == "" || rootForProof == "" || nullifierHashForProof == "" || merklePathForProof[0] == "" || merklePathArray == ""}>
              {calculatingProof ? <span className="loading loading-spinner loading-sm"></span> : "Get proof"}
            </button>
          </div>
          {proof != "" && (<p className="text-center text-lg -mt-2">
            Your proof:
            {shorten(proof)}
          </p>)}
        </div>
        <div className="flex items-center flex-col flex-grow rounded-3xl shadow-xl border-2 px-5 mt-5">
          <p className="text-center text-lg">
            Verify proof (off-chain):
          </p>
          <div className="mt-1">
          <BytesInput
            name="proofToVerify"
            value={proofToVerify}
            placeholder="Proof"
            onChange={value => setProofToVerify(value)}
          />
          </div>
          <div className="mt-3">
          <Bytes32Input
            name="rootForVerify"
            value={rootToVerify}
            placeholder="Root"
            onChange={value => setRootToVerify(value)}
          />
          </div>
          <div className="mt-3">
          <Bytes32Input
            name="nullifierHashToVerify"
            value={nullifierHashToVerify}
            placeholder="Nullifier Hash"
            onChange={value => setNullifierHashToVerify(value)}
          />
          </div>
          <div className="pt-3 py-5">
            <button className="btn btn-primary" onClick={verifyProof}
                    disabled={verifying || proofToVerify == "" || rootToVerify == "" || nullifierHashToVerify == ""}>
              {verifying ? <span className="loading loading-spinner loading-sm"></span> : "Verify"}
            </button>
          </div>
          {isVerified && (
          <p className="text-center text-lg -mt-2">
            {isValid ? "Proof is valid!" : "Proof is invalid!"}
          </p>)}
        </div>
        <div className="flex items-center flex-col flex-grow rounded-3xl shadow-xl border-2 px-5 mt-5">
          <p className="text-center text-lg">
            Call the example function (on-chain):
          </p>
          <div className="mt-1">
          <IntegerInput
            name="indexForContract"
            value={indexForContract}
            placeholder="Index"
            onChange={value => setIndexForCcontract(value.toString())}
          />
          </div>
          <div className="mt-3">
          <BytesInput
            name="proofForContract"
            value={proofForContract}
            placeholder="Proof"
            onChange={value => setProofForContract(value)}
          />
          </div>
          <div className="mt-3">
          <Bytes32Input
            name="nullifierHashForContract"
            value={nullifierHashForContract}
            placeholder="Nullifier Hash"
            onChange={value => setNullifierHashForContract(value)}
          />
          </div>
          <div className="pt-3 py-5">
            <button className="btn btn-primary" onClick={exampleFunction}
                    disabled={isPending || indexForContract == "" || proofForContract == "" || nullifierHashForContract == ""}>
              {isPending ? <span className="loading loading-spinner loading-sm"></span> : "Call"}
            </button>
          </div>
          {isValidForContract && (
          <p className="text-center text-lg -mt-2">
            Proof is valid!
          </p>)}
        </div>
      </div>
    </>
  );
};

export default ZkTree;
