# BitcoinNova (BTCN) — BEP20 token on BSC

| Field          | Value |
|----------------|-------|
| Name           | BitcoinNova |
| Symbol         | BTCN |
| Decimals       | 18 |
| Initial supply | **21,000,000,000 BTCN** (all sent to the deployer wallet) |
| Mint           | Owner only, no maximum cap |
| Burn           | Any holder can burn their own tokens (`burn`), or approved tokens (`burnFrom`) |
| Compiler       | solc **0.5.16**, optimization **enabled, 200 runs** |

## Deploy with Remix + MetaMask

1. Add BSC to MetaMask (Testnet chain ID 97, Mainnet chain ID 56) and fund it with BNB for gas
   (testnet BNB comes from the official BNB Chain faucet).
2. Open https://remix.ethereum.org, create `BitcoinNova.sol`, paste the contract.
3. **Solidity Compiler** tab: version `0.5.16`, enable optimization (200 runs), compile.
4. **Deploy & Run** tab: Environment = "Injected Provider – MetaMask", contract = `BitcoinNova`, click **Deploy**.
5. Copy the deployed contract address. In MetaMask, "Import tokens" → paste the address to see your 21B BTCN.

Always deploy to **testnet first**, test everything, then repeat on mainnet.

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
| `transfer(to, amount)` | anyone | Send BTCN |
| `approve(spender, amount)` | anyone | Let another wallet/contract spend your BTCN |
| `transferFrom(from, to, amount)` | approved spender | Move BTCN using an approval (used by DEXes, game contracts) |
| `increaseAllowance` / `decreaseAllowance` | anyone | Safer way to change an approval |
| `balanceOf`, `totalSupply`, `allowance`, `name`, `symbol`, `decimals`, `getOwner` | anyone | Read-only info |
| `mint(amount)` | **owner only** | Creates new BTCN to the owner wallet (no cap) |
| `burn(amount)` | any holder | Destroys own BTCN, lowers total supply |
| `burnFrom(account, amount)` | approved spender | Burns another wallet's BTCN using allowance |
| `transferOwnership(addr)` | owner | Give the owner role (and mint power) to another wallet |
| `renounceOwnership()` | owner | Remove the owner forever → `mint` is disabled permanently |

Amounts are in the smallest unit: 1 BTCN = `1000000000000000000` (18 zeros).

## What this contract does NOT have (for apps & games)

This is a plain currency token. Everything below must be built as **separate contracts or backend
services** that use BTCN. Only the owner wallet can mint, so game contracts must be **funded with BTCN
from your supply/owner wallet**.

| Missing piece | Why an app/game needs it | How to add it |
|---|---|---|
| Tokenomics / allocation wallets | 21B all lands in one wallet. Need split: game rewards pool, team, marketing, liquidity, reserve | Send to separate wallets / vesting contracts right after deploy, publish the plan |
| Vesting / time-lock | Team & investor tokens should unlock over time to build trust | Separate vesting contract (e.g. OpenZeppelin `VestingWallet`) |
| Game rewards / play-to-earn | Paying players for wins, quests, daily login | Rewards contract or backend hot wallet funded from the rewards pool, with daily limits |
| In-game payments / shop | Players pay BTCN for items, upgrades, entry fees | Shop contract using `approve` + `transferFrom`, or direct transfer to a treasury wallet |
| Staking | Lock BTCN to earn rewards / perks | Separate staking contract funded with reward BTCN |
| NFTs (characters, skins, items) | Own game items on-chain | Separate BEP721 / BEP1155 contract, priced in BTCN |
| Gasless approvals (`permit`, EIP-2612) | Players approve by signing, not paying BNB gas | Needs newer Solidity (0.8.x) token — only possible **before** deployment |
| Gas-free experience for players | New players have no BNB for gas | Meta-transactions / relayer, or keep in-game balances off-chain and withdraw on-chain |
| Batch transfers / airdrops | Rewarding thousands of players cheaply | Separate multisend/airdrop contract |
| Pause / emergency stop | Stop transfers if exploited | Not in token (by choice). Put pause in your game contracts instead |
| Anti-bot / max wallet / tax | Launch sniping protection, fees for treasury | Not included (keeps token clean & trusted). Needs token redesign before deploy |
| Multisig ownership | Protect treasury & admin wallets | Use Safe (safe.global) for the supply and treasury wallets |
| Liquidity on PancakeSwap | Players need a place to buy/sell BTCN | Add BTCN/BNB or BTCN/USDT pool, lock the LP tokens |
| Price oracle | Show BTCN price in USD in the game | Read PancakeSwap pool price or listing APIs |
| Audit | Required before real users/money | Audit the token + all game contracts |
| Listings & metadata | Logo and info in wallets/explorers | BscScan token update, CoinGecko, CoinMarketCap, Trust Wallet assets |

**Decide before deploying:** anything that must live *inside* the token (permit, tax, anti-bot, pause)
cannot be added later — the token code is permanent once deployed.

**Mint risk:** unlimited owner mint is flagged by scanners (BscScan, Token Sniffer, GoPlus) and
buyers. Protect the owner wallet with a multisig, and consider `renounceOwnership()` or a supply cap
when you no longer need to mint.
