const hre = require("hardhat");

async function main() {
  const ShakeToken = await hre.ethers.getContractFactory("ShakeToken");
  const token = await ShakeToken.deploy();
  console.log("Token deployed to:", token.address);

  const Library = await hre.ethers.getContractFactory("StringTools");
  const lib = await Library.deploy();
  await lib.deployed();
  console.log("Library deployed to ", lib.address);

  const CaracterContract = await hre.ethers.getContractFactory("NFTMinting", {
    libraries: {
      StringTools: lib.address,
    },
  });
  // URIś for each combiantion
  const c000 = "";
  const c100 = "";
  const c200 = "";
  const c001 = "";
  const c101 = "";
  const c201 = "";
  const c010 = "";
  const c110 = "";
  const c210 = "";
  const c011 = "";
  const c111 = "";
  const c211 = "";
  const char = await CaracterContract.deploy(
    [0, 1, 2, 0, 1, 2, 0, 1, 2, 0, 1, 2], // Level
    [0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1], // Civilization
    [0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 1, 1], // Class
    [c000, c100, c200, c001, c101, c201, c010, c110, c210, c011, c111, c211], // URIs
    [
      { amount: 3000, price: ethers.utils.parseEther("0") },
      { amount: 3000, price: ethers.utils.parseEther("0") },
      { amount: 3000, price: ethers.utils.parseEther("0") },
    ]
  );

  await char.deployed();
  console.log("Character COntract deployed to: ", char.address);

  const DefGear = await hre.ethers.getContractFactory("DefensiveGear", {
    libraries: {
      StringTools: lib.address,
    },
  });
  // Define deployement values
  const defGearAmounts = [3000, 1000, 500, 100];
  const defGearprices = ["0", "0", "0", "0"];
  const defGearUris = ["", "", "", ""];
  const def = await DefGear.deploy(defGearAmounts, defGearprices, defGearUris);
  await def.deployed();
  console.log("DefGear deployed to:", def.address);

  const OffGear = await hre.ethers.getContractFactory("OffensiveGear", {
    libraries: {
      StringTools: lib.address,
    },
  });

  // Define deployement values
  const offGearAmounts = [3000, 1000, 500];
  const offGearprices = ["0", "0", "0"];
  const offGearUris = ["", "", ""];
  const off = await OffGear.deploy();
  await off.deployed(offGearAmounts, offGearprices, offGearUris);
  console.log("OffGear deployed to:", off.address);

  const Escrow = await hre.ethers.getContractFactory("Escrow");
  const escrow = await Escrow.deploy(token.address);
  await escrow.deployed();
  console.log("Escrow deployed to:", escrow.address);

  const GameContract = await hre.ethers.getContractFactory("GameContract");
  const game = await GameContract.deploy(
    escrow.address,
    token.address,
    escrow.address, // Change to character address
    def.address,
    off.address
  );
  console.log("Game Contract deployed to:", game.address);

  const transferTx = await token.transferOwnership(game.address);
  await transferTx.wait(1);

  const transferTx2 = await char.transferOwnership(game.address);
  await transferTx2.wait(1);

  const transferTx3 = await def.transferOwnership(game.address);
  await transferTx3.wait(1);

  const transferTx4 = await off.transferOwnership(game.address);
  await transferTx4.wait(1);

  const transferTx5 = await escrow.transferOwnership(game.address);
  await transferTx5.wait(1);

  console.log("All Ownerships transfered");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
