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
        string[] examinationResult;
        string[] caseSummaries
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

     modifier approvedDoctor(uint256 patientID){
        require(
            approvedDoctors[msg.sender] [patientIdToAddress[patientID]],
            "Doctor without approval cannot treat the patient!"
        );
        _;
     }

     modifier validNumber(uint256 _number) {
        require(_number > 0, "Value must be greater than zero!");
        _;
     }

     // Functions to be executed 

     // functions to register a new patient

     function registerNewPatient(
        string calldata _name,
        Gender _gender,
        uint8 _age
    ) external validNumber(_age) {
        require(
            verifiedPatient[msg.sender] == false,
            "Patient has already registered!"
        );
        Patient storage newPatient = addressToPatientRecord[msg.sender];
        newPatient.patientID = counterPatientID;
        newPatient.patientName = _name;
        newPatient.patientGender = _gender;
        newPatient.patientAge = _age;

        patientIdToAddress[counterPatientID] = msg.sender; //
        patients.push(newPatient);
        verifiedPatient[msg.sender] = true;
        counterPatientID++;
    }

    // Function to allow patients update their age
    function updateMyAge(uint8 _age) external validNumber(_age) onlyPatient{
        addressToPatientRecord[msg.sender].patientAge = _age;
    }

    // Function to allow patient to approve doctors before the doctor can prescribe medications, and view patient medical records.
    // Patient will enter doctor ID number.

    function approveDoctor(uint256 _doctorId) 
    external 
    validNumber(_doctorID)
    onlyPatient
    {
        require(
            verifiedDoctor[doctorIdToAddress[_doctorId]] == true;
            "This doctor is not registered";
        );
        approvedDoctors[doctorIdToAddress[_doctorID][msg.sender]] = true;
    }

    // Function to allow registered patient to view their records. Only Registered patients can call this function

    function viewMyRecord()
    external
    view
    onlyPatient
    returns (Patient memory){
        return addressToPatientRecord[msg.sender];
    }

    // function to allow patient to view list of medical doctors. Patient can obtain 
    // more information about the doctor by calling this function

    function viewListOfDoctors()public view onlyPatient returns
    (Doctor[] memory)
    {
        return doctors;
    }

    // Patient can also get doctors info just by typing the doctor ID number.
    function getDoctorDetails(uint256 _doctorId)
        external
        view
        validNumber(_doctorId)
        onlyPatient
        returns (Doctor memory)
    {
        address doctor_address = doctorIdToAddress[_doctorId];
        return addressToDoctor[doctor_address];
    }

    // Function to create new doctors or where a new doctor can get registered
    function registerNewDoctor(
        string calldata _name,
        string calldata _specialty,
        string calldata _workplace
    ) external {
        require(!verifiedDoctor[msg.sender], "Doctor has already registered!");
        verifiedDoctor[msg.sender] = true;
        Doctor storage newDoctor = addressToDoctor[msg.sender];
        newDoctor.doctorID = counterDoctorID;
        newDoctor.doctorName = _name;
        newDoctor.specialty = _specialty;
        newDoctor.workplace = _workplace;

        doctors.push(newDoctor);
        doctorIdToAddress[counterDoctorID] = msg.sender;
        counterDoctorID++;
    }
    //  Function that allow approved doctor to add a diagnosis to the patient's list of conditions.
    function addCondition(string calldata _newCondition, uint256 patientID)
        external
        onlyDoctor
        approvedDoctor(patientID)
        validNumber(patientID)
    {
        address patientAddr = patientIdToAddress[patientID];
        addressToPatientRecord[patientAddr].conditions.push(_newCondition);
    }
    //  Function that allow approved doctor to add a diagnosis to the patient's list of Examination Result.
    function addExaminationResult(string calldata _newExaminationResult, uint256 patientID)
        external
        onlyDoctor
        approvedDoctor(patientID)
        validNumber(patientID)
    {
        address patientAddr = patientIdToAddress[patientID];
        addressToPatientRecord[patientAddr].examinationResult.push(_newExaminationResult);  // Take note of this function
    }

     //  Function that allow approved doctor to add to the patient's list of case summaries.
    function addCaseSummary(string calldata _newCaseSummary, uint256 patientID)
        external
        onlyDoctor
        approvedDoctor(patientID)
        validNumber(patientID)
    {
        address patientAddr = patientIdToAddress[patientID];
        addressToPatientRecord[patientAddr].caseSummaries.push(_newCaseSuumary);
    }

    // Function that allow Doctors to register new medications to the database.
    // Doctors need to call on the "addPrescription()" function to add a medication to a patient's prescriptions array.
    function addMedication(
        uint256 _medicationID,
        string calldata _medicationName,
        string calldata _expirationDate,
        string calldata _dosage,
        uint256 _price
    ) external onlyDoctor validNumber(_medicationID) validNumber(_price) {
        require(
            medicationIdToBool[_medicationID] == false,
            "Medication already registered!"
        );
        medicationIdToBool[_medicationID] = true;
        Medication memory medicine = Medication(
            _medicationID,
            _medicationName,
            _expirationDate,
            _dosage,
            _price
        );

        idToMedication[_medicationID] = medicine;
        medications.push(medicine);
    }

    // Function to  allow doctors to view a list of currently registered medications
    // It will return an array of Medication structures
    function viewListofMedications()
        public
        view
        onlyDoctor
        returns (Medication[] memory)
    {
        return medications;
    }

    //  Patient has to approve doctors that can add medications to Patient structures
    // Patient will supply patient ID number and medication ID number
    function addPrescription(uint256 _patientID, uint256 _medicineID)
        external
        onlyDoctor
        approvedDoctor(_patientID)
        validNumber(_patientID)
        validNumber(_medicineID)
    {
        require(
            medicationIdToBool[_medicineID] == true,
            "Medication not registered!"
        );
        Patient storage patient = addressToPatientRecord[
            patientIdToAddress[_patientID]
        ];
        Medication storage medicine = idToMedication[_medicineID];
        patient.prescriptions.push(medicine);
    }

    // Function to allow  approved doctors to call on this function to view their patient's medical record
    // function takes in the patient ID number as an input.
    // @dev  patient ID number if first mapped to the patient's address, which is then mapped to the Patient structure.
    // @return full patient structure including ID number, name, gender (0 or 1), age, list of conditions, and list of prescriptions.
    function viewPatientRecords(uint256 _patientID)
        external
        view
        onlyDoctor
        approvedDoctor(_patientID)
        validNumber(_patientID)
        returns (Patient memory)
    {
        return addressToPatientRecord[patientIdToAddress[_patientID]];
    }
    


}
