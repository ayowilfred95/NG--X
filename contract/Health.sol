//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

    // owner of the contract 
    address public owners;

    //Events for the owner to remove items
    event ItemAddition(adress indexed owner);

    // Mapping to keep track of all patient's address
    mapping(address => bool) isOwner;


    //The structure to store info about a patient
    struct PatientInfo {
        uint256 id;
        string name;
        address walletAddress;
        bool isPatient;
        uint256 age;
        string blood;
        String allergies;
        string caseSummaries;
        string examinationResult;

    }


    // Event to emit when an Item is created.
    event NewItem(
        address indexed from,
        uint256 timestamp,
        string name,
        string condition,
        string prescription,
        string medicalCondtion,
        string message,
        string caseSummaries,
        string examinationResult
    );

    // This mapping helps to maps patient id with patient info when retrieving
    // details about a patient
    mapping(uint256 =>patientInfo) private idToPatient;


     struct Item {
        uint256 id;
        address from;
        uint256 timestamp;
        string name;
        string message;
    }
    Item[] items;


    contract Health is ERC721URIStorage {
    constructor() ERC721("Health", "HLT") {
        owner = payable(msg.sender);
    }

    function updatePatientAge(uint _age) public {
        require(owner == msg.sender, "Only owner can update patient age");
        age = _age;

    }
    //The first time a patient profile is created, it is listed here
    function createNewPatient(uint256 id, 
        string memory name, 
        string memory condition,
        string memory medicalCondition,
        string memory message,
        string memory caseSummaries,
        string memory examinationResult,
        string memory bllod) public payable return  {
            // Increment the id counter, which is used to keep track of number of patient created
            _ids.increment();
            uint256 newId = _ids.current();
            
            // Create a new info with id newId to the address who called createPatient
            _setId(newId);

            // Function to update Global variables and emit an event
            createPatient(newId, name, condition,blood,medicalCondition,message,caseSummaries,examinationResult);
        

        }


}
