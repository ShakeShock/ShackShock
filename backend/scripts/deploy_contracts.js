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
  const char = await CaracterContract.deploy(
    [0, 1, 2],
    [0, 0, 0],
    [0, 0, 0],
    ["l1", "l2", "l3"],
    [
      { amount: 7, price: ethers.utils.parseEther("0") },
      { amount: 2, price: ethers.utils.parseEther("0.03") },
      { amount: 1, price: ethers.utils.parseEther("0.06") },
    ]
  );

  await char.deployed();
  console.log("Character COntract deployed to: ", char.address);

  const DefGear = await hre.ethers.getContractFactory("DefensiveGear", {
    libraries: {
      StringTools: lib.address,
    },
  });
  const def = await DefGear.deploy();
  await def.deployed();
  console.log("DefGear deployed to:", def.address);

  const OffGear = await hre.ethers.getContractFactory("OffensiveGear", {
    libraries: {
      StringTools: lib.address,
    },
  });
  const off = await OffGear.deploy();
  await off.deployed();
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
