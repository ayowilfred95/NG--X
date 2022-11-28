const { ethers } = require("hardhat");
const hre = require("hardhat");
const fs = require("fs");

async function main() {
  const [deployer] = await ethers.getSigners();
  const balance = await deployer.getBalance();
  const PatientRecord = await hre.ethers.getContractFactory("PatientHealthRecord");
  const patientRecord = await PatientRecord.deploy();

  await  patientRecord.deployed();
  console.log("patientRecord deployed to:",  patientRecord.address);

  const data = {
    address:  patientRecord.address,
    abi: JSON.parse( patientRecord.interface.format('json'))
  }

  //This writes the ABI and address to the mktplace.json
  fs.writeFileSync('./src/PatientRecord.json', JSON.stringify(data)) // Remember to create a file called PatientRecord.json
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
