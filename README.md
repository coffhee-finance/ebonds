# eBONDS
RWA token marketplace.

ARBITRUM ADDRESSES FrappeBond (ERC3475 encrypted bond): 0xAb8BD1b16a9912c2DD39b433c72b10559A1b7621 Frappucino (Encrypted Wrapper NFT): 0x5d3DD9f67618b1500f3a03D66921A67dAe09C298 Cappucino (Wrapper NFT): 0x880fe78C2E1bd0Ac2c6580Dc99f47C29107d9884 Marketplace: 0x59De9918eE0cba2a60368104C289bE9EB8973E34

ROBINHOOD CHAIN Cappucino (Wrapped NFT): 0xaFD717461069733CB63644A1497874A196505Bfe Marketplace: 0xB9B956A6F0AD75f5dB0da742c3520b28b90a9935

The Coffhee Finance Infrastructure The Confidential Hub (Arbitrum/Robinhood Chain + Fhenix): The core of the ecosystem resides on Arbitrum, utilizing Fhenix’s FHE (Fully Homomorphic Encryption) coprocessor. This "Confidential Hub" hosts the ERC-3475 "Golden Copy" of the debt. It enables the encryption of sensitive financial data—such as principal amounts, individual yields, and institutional identities—allowing the blockchain to perform math on the debt while it remains encrypted.

The Liquid Spoke Model (Multichain): Instead of siloed liquidity, Coffhee utilizes a "Spoke" architecture. While the complex bond logic lives on the Hub, ERC-1155 "Receipt NFTs" are provisioned to high-traffic chains like Robinhood Chain. This allows retail traders to buy and sell bond positions in their native environment without needing to understand the underlying FHE encryption.

Multi-Class Debt Engine (ERC-3475): The infrastructure moves beyond simple tokens to an Abstract Storage Bond standard. A single contract can manage infinite "classes" (types of bonds) and "nonces" (specific issuances). This allows Coffhee to support fixed-income, zero-coupon, and callable bonds within the same gas-efficient infrastructure, mimicking a sophisticated prime brokerage.

Permissioned Decryption & Sealing: The platform features a native sealing protocol. When an authorized holder connects via the Terminal, the FHE coprocessor "seals" the private bond data specifically for that holder’s public key. This ensures that while the market sees a generic NFT, the owner sees their private amortized yield and maturity schedule directly in their interface.
