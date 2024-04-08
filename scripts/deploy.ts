import { ethers } from "hardhat";

async function main() {
  const MusicTuneVibe = await ethers.getContractFactory("MusicTuneVibe");
  const musicTuneVibe = await MusicTuneVibe.deploy(
    "http://localhost:3000/",
    "0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199"
  );

  await musicTuneVibe.waitForDeployment();

  console.log("NFTMint deployed to:", musicTuneVibe.target);

  // For MarketPlace

  const Marketplace = await ethers.getContractFactory("TuneVibe");
  const marketplace = await Marketplace.deploy(musicTuneVibe.target);

  await marketplace.waitForDeployment();

  console.log("Marketplace deployed to:", marketplace.target);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
