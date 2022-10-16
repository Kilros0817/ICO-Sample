// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  const totalSupply = 10000000;
  const icoAmount = 2000000;
  const Doctor = await hre.ethers.getContractFactory("Doctor");
  const DoctorContract = await Doctor.deploy( totalSupply, icoAmount);
  console.log(
    `Doctor deployed to ${DoctorContract.address}`
  );

  const DoctorICO = await hre.ethers.getContractFactory("DoctorICO");
  const DoctorICOContract = await DoctorICO.deploy(1666209732, 20, 20, 20);
  console.log(
    `DoctorICO deployed to ${DoctorICOContract.address}`
  );

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
