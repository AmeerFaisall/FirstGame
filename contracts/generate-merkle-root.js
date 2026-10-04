// Usage: node generate-merkle-root.js recipients.csv
// recipients.csv format (no header): address,amount_in_whole_tokens
//
// Outputs:
//   - the Merkle root to paste into the airdrop contract's constructor
//   - proofs.json: { "<address>": { "amount": "<wei amount>", "proof": [...] } }
//     Your claim page looks up the connected wallet's entry here and calls
//     airdrop.claim(amount, proof).
//
// npm install ethers merkletreejs

const fs = require('fs');
const { ethers } = require('ethers');
const { MerkleTree } = require('merkletreejs');

const csvPath = process.argv[2];
if (!csvPath) {
  console.error('Usage: node generate-merkle-root.js recipients.csv');
  process.exit(1);
}

const lines = fs.readFileSync(csvPath, 'utf8').trim().split('\n').filter(Boolean);
const entries = lines.map((line) => {
  const [addr, amount] = line.split(',').map((s) => s.trim());
  return { address: ethers.getAddress(addr), amount: ethers.parseEther(amount) };
});

function leafOf(address, amount) {
  return ethers.keccak256(
    ethers.keccak256(ethers.AbiCoder.defaultAbiCoder().encode(['address', 'uint256'], [address, amount]))
  );
}

const leaves = entries.map((e) => leafOf(e.address, e.amount));
const tree = new MerkleTree(leaves, (b) => Buffer.from(ethers.getBytes(ethers.keccak256(b))), { sortPairs: true });
const root = tree.getHexRoot();

const proofs = {};
entries.forEach((e, i) => {
  proofs[e.address] = {
    amount: e.amount.toString(),
    amountFormatted: ethers.formatEther(e.amount),
    proof: tree.getHexProof(leaves[i]),
  };
});

fs.writeFileSync('proofs.json', JSON.stringify(proofs, null, 2));

console.log('Total recipients:', entries.length);
console.log('Total tokens to fund the contract with:', ethers.formatEther(entries.reduce((s, e) => s + e.amount, 0n)));
console.log('Merkle root (paste into deploy):', root);
console.log('Wrote proofs.json');
