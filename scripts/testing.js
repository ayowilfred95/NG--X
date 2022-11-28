const PatientRecord =  require("../src/PatientHealthRecord.json");
async function viewPatientRecords () {
const MyContract = await ethers.getContractFactory("PatientHealthRecord");
const contract = await MyContract.attach(
    PatientRecord.address
);

// Now you can call functions of the contract
var vals = await contract.viewMyRecords();
console.log(vals);

/*const provider = new ethers.providers.Web3Provider(window.ethereum)
const signer = provider.getSigner();
const addrsign = await signer.getAddress();

let contract = new ethers.Contract( PatientRecord.address, PatientRecord.abi, signer)
let transaction = await contract.viewMyRecord()
console.log(transaction);*/
}

viewPatientRecords();
