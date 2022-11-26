//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "hardhat/console.sol";

contract PatientHealthRecord {
    // Patient and doctors are assigned ID numbers using a counter.

    uint256 public counterPatientID = 1;
    uint256 public counterDoctorID = 1;

    // Gender has to be included during registration

    enum Gender {
        MALE,
        FEMALE
    }

    // struct to store Patient Information

    struct Patient {
        uint256 patientID;
        string patientName;
        Gender patientGender;
        uint8 patientAge;
        string[] conditions;
        Medication[] prescriptions;
        Medication[] examinationResult;
        Medication[] caseSummaries
    } 

    // An admin has to have full access to this array which is struct 
    // An owner has to be declared

    Patient[] private patients;

    // STRUCT TO STORE DOCTORS INFORMATIONS

    struct Doctor {
        uint256 doctorID;
        string doctorName;
        string specialty;
        string workplace;
        string role;
        uint256 licenseNos;
    }

    Doctor[] private doctors

    // Struct to store medications
     struct Medication {
        uint256 medicationId;
        string medicationName;
        string dosage;
        uint256 price;
     }
     Medication[] private medications;

     // Let create a mapping to verify patients and doctors once they register.
     // The patient should remain private.

     mapping(address => bool) private verifiedPatient;
     mapping(address=> bool) public verifiedDoctor;

     // Mapping to connect the address of the patients and doctors to their struct. Must still be private for patient.
     mapping(address => Patient) private addressToPatientRecord;
     mapping(address => doctor) public addressToDoctor;

     // Mapping to connect ID's addresses 
     mapping(uint256 => address) private patientidToAddress;
     mapping(uint256 => address) private doctorIdToAddress;

     // Mapping to list all patient approved by doctors. Patient data must be private
     mapping(address => mapping(address=>bool)) private approvedDoctors;

     // Mapping for medications ID 
     mapping(uint256=>Medication) public idToMedication;
     mapping(uint256=>bool) public medicationIdToBool;

     // let create our modifier that will allow onlyUsers e.g patients and doctors

     modifier onlyPatient() {
        require(verifiedPatient[msg.sender] == true, "Only a verified patient has access to this account");
        _;
     }

     modifier onlyDoctor() {
        require(verifiedDoctor[msg.sender] == true, "Only a verified doctor can aceess this account");
        _;
     }

     modifier approvedDoctor



}
