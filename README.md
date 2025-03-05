1. Making sure our USD is always paired to 1.0 USD.
   1. Fetching fromChainlink Price Feed.
   2. Function that exchanges ETH & BTC => $
2. Stable minting mechanism: Algorithmic (Decentralized)
   1. People are only going to mint with enough collateral (gonna be ocoded)
3. Collateral: Exogenous (Crypto)
   1. ETH
   2. BTC

## Explanation of `address(0)` in Solidity

In a Solidity contract, `address(0)` represents the zero address, which is a special address in the Ethereum network. It is often used as a sentinel value to indicate the absence of an address or to represent a null address. The zero address is 0x0000000000000000000000000000000000000000.

Here are some common uses of `address(0)` in smart contracts:

1. **Burning Tokens**: When tokens are burned, they are often sent to the zero address to remove them from circulation.
2. **Initial Values**: It can be used to check if an address variable has been initialized or not.
3. **Validation**: It can be used to validate that an address is not the zero address before performing certain operations.
