# ShakeShock

## What’s Shake Shock?

Shake Shock it’s a Play-and-Earn (PaE), the first of its kind. Like many games in Crypto, the mechanics are highly dependable on the design of the games, the incentives of trade, and how fun it is.

Shake Shock starts with the creation of Adam and Eve, mere humans that initially were alone in the world and through different decisions evolve and move into different continents, clans, and ultimately civilizations.

Civilizations are born, rise and fall. Intimately tied with human nature, groups of people need to communicate and decide the fate of civilizations and their characters. In the meantime, a battle for the world will be fought, earning different civilizations more wealth and power.

[Design doc](https://mirror.xyz/0x37eC246fCD668400Df5dAA5362601dB613BAcC84/iVmb8tLYQHaKfU_HZhjAPdv4rbYv2I6H6neinSTkg4s)


## Technical details

> Backend
- Game contract, central smart contract for handling interactions to the NFT and escrow contracts (solidity)
- Escrow contract (solidity) - holds $shake in escrow when players stake their tokens before entering into a battle
- NFT minting contracts (solidity) - players mint a character NFT and asset NFTs used in game
- $shake ERC20 token (extended from the OpenZeppelin wizard) - players air initially airdropped tokens when minting their character NFT and would eventually be able to earn more $shake from in game activities
- Deployed NFT meta data to NFT.Storage

> Frontend

- Unity WebGL with multiplayer support via photon
- Moralis for unity and on-chain integration

## Links

ETHGlobal Showcase: https://showcase.ethglobal.com/buildquest/shake-shock-domcc
Website: https://www.shakeshock.xyz/
Discord Server: https://discord.gg/tY7yr3KT

## Screenshots

![Screenshot 2022-03-14 at 20 47 00](https://user-images.githubusercontent.com/35449333/158258447-f942c4a8-cc74-4bf8-bcb0-41de38070216.png)
