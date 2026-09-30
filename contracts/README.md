# BitcoinNova (BTCN) — BEP20 token on BSC

| Field        | Value                      |
|--------------|----------------------------|
| Name         | BitcoinNova                |
| Symbol       | BTCN                       |
| Decimals     | 18                         |
| Initial supply | 21,000,000 BTCN (all minted to the deployer wallet) |
| Compiler     | solc **0.5.16**, optimization **enabled, 200 runs** |

## Deploy with Remix + MetaMask

1. Add BSC to MetaMask (Testnet chain ID 97, Mainnet chain ID 56) and fund it with BNB for gas
   (testnet BNB comes from the official BNB Chain faucet).
2. Open https://remix.ethereum.org, create `BitcoinNova.sol`, paste the contract.
3. **Solidity Compiler** tab: version `0.5.16`, enable optimization (200 runs), compile.
4. **Deploy & Run** tab: Environment = "Injected Provider – MetaMask", contract = `BitcoinNova`, click **Deploy**.
5. Copy the deployed contract address. In MetaMask, "Import tokens" → paste the address to see your 21M BTCN.

Always deploy to **testnet first**, test transfers/burn/mint, then repeat on mainnet.

## Verify on BscScan

BscScan → your contract address → Contract → Verify & Publish:
- Compiler type: Solidity (Single file)
- Compiler version: v0.5.16+commit.9c3226ce
- License: MIT
- Optimization: Yes, 200 runs
- Paste the exact same source code. No constructor arguments.

## Functions

| Function | Who | What it does |
|----------|-----|--------------|
| `transfer`, `approve`, `transferFrom` | anyone | Standard BEP20 |
| `increaseAllowance`, `decreaseAllowance` | anyone | Safer allowance changes |
| `burn(amount)` | any holder | Destroys own tokens, lowers total supply |
| `burnFrom(account, amount)` | approved spender | Burns someone's tokens using allowance |
| `mint(amount)` | **owner only** | Creates new tokens to the owner — **no cap** |
| `transferOwnership(addr)` | owner | Hand control to another wallet (e.g. a multisig) |
| `renounceOwnership()` | owner | Removes the owner forever → `mint` disabled permanently |

Note: amounts are in the smallest unit (wei). 1 BTCN = `1000000000000000000`.
