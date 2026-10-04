// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * BTCN Airdrop (Merkle claim)
 *
 * How it works:
 * 1. Deploy this contract with your token's address.
 * 2. Build a list of {address, amount} off-chain, hash it into a single
 *    "Merkle root", and set it with setMerkleRoot(). (Script included below.)
 * 3. Send the total BTCN you want to give away to this contract's address.
 * 4. Each eligible wallet calls claim(amount, proof) once to receive their
 *    share. `amount` and `proof` come from the same off-chain script.
 * 5. After the deadline (optional), you can sweep() any unclaimed tokens
 *    back to yourself.
 *
 * Nobody but the addresses in your original list can claim, and each
 * address can only claim once.
 */

interface IBEP20 {
  function transfer(address to, uint256 amount) external returns (bool);
  function balanceOf(address account) external view returns (uint256);
}

contract BTCNAirdrop {
  address public owner;
  IBEP20 public immutable token;
  bytes32 public merkleRoot;
  uint256 public claimDeadline; // unix timestamp; 0 = no deadline

  mapping(address => bool) public claimed;

  event Claimed(address indexed user, uint256 amount);
  event MerkleRootUpdated(bytes32 newRoot);
  event DeadlineUpdated(uint256 newDeadline);
  event Swept(address indexed to, uint256 amount);
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  modifier onlyOwner() {
    require(msg.sender == owner, "Airdrop: caller is not the owner");
    _;
  }

  constructor(address tokenAddress, bytes32 root, uint256 deadline) {
    require(tokenAddress != address(0), "Airdrop: zero token address");
    owner = msg.sender;
    token = IBEP20(tokenAddress);
    merkleRoot = root;
    claimDeadline = deadline;
    emit OwnershipTransferred(address(0), msg.sender);
  }

  /**
   * @dev Claim your share of the airdrop.
   * `amount` and `proof` must be the exact values generated for your
   * address by the off-chain Merkle tree script.
   */
  function claim(uint256 amount, bytes32[] calldata proof) external {
    require(!claimed[msg.sender], "Airdrop: already claimed");
    require(claimDeadline == 0 || block.timestamp <= claimDeadline, "Airdrop: claim period ended");

    bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(msg.sender, amount))));
    require(_verify(proof, merkleRoot, leaf), "Airdrop: invalid proof");

    claimed[msg.sender] = true;

    require(token.transfer(msg.sender, amount), "Airdrop: transfer failed");

    emit Claimed(msg.sender, amount);
  }

  function _verify(bytes32[] calldata proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
    bytes32 computed = leaf;
    for (uint256 i = 0; i < proof.length; i++) {
      bytes32 p = proof[i];
      if (computed <= p) {
        computed = keccak256(abi.encodePacked(computed, p));
      } else {
        computed = keccak256(abi.encodePacked(p, computed));
      }
    }
    return computed == root;
  }

  /**
   * @dev Replace the eligibility list by setting a new root (e.g. for a
   * second airdrop round). Addresses that already claimed stay claimed.
   */
  function setMerkleRoot(bytes32 root) external onlyOwner {
    merkleRoot = root;
    emit MerkleRootUpdated(root);
  }

  function setDeadline(uint256 deadline) external onlyOwner {
    claimDeadline = deadline;
    emit DeadlineUpdated(deadline);
  }

  /**
   * @dev Send any BTCN left in this contract back to `to`. Use this after
   * the deadline to reclaim unclaimed tokens.
   */
  function sweep(address to) external onlyOwner {
    require(to != address(0), "Airdrop: zero address");
    uint256 balance = token.balanceOf(address(this));
    require(token.transfer(to, balance), "Airdrop: sweep failed");
    emit Swept(to, balance);
  }

  function transferOwnership(address newOwner) external onlyOwner {
    require(newOwner != address(0), "Airdrop: zero address");
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}
