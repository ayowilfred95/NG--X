// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;


contract PatientHealthRecord {
    //  Patient and doctors are assigned ID numbers using a counter.
    uint256 public counterPatientID = 1;
    uint256 public counterDoctorID = 1;

    // Enum type for gender.
    enum Gender {
        MALE,
        FEMALE
    }

    // Struct to store patient informations.

    struct Patient {
        uint256 patientID;
        string patientName;
        Gender patientGender;
        uint8 patientAge;
        string[] caseSummaries;
      //  string[] examinationResults;
        Medication[] prescriptions;
        Dependency[] dependencies;

    }

    // Struct to store Examination Results Images
    struct ExaminationResults{
        uint256 id;
        string ipfsHash;    //IPFS hash
        string title;       //Image Titke;
        string description;  // Image description
        uint256 uploadedOn;    // uploaded timestamp
    }

    ExaminationResults[] private examinationResults;


    //Struct to store dependencies
    struct Dependency {
        uint256 dependencyId;
        string dependencyName;
        string dependencyRelationship;
        string dependencyAddress;
        uint256 contactNumber;
    }

    Dependency[] private dependencies;

    // Array to push patient information to.

    Patient[] private patients;

    struct Doctor {
        uint256 doctorID;
        string doctorName;
        string specialty;
        string workplace;
    }

    Doctor[] private doctors;

    struct Medication {
        uint256 medicationId;
        string medicationName;
        string dosage;
        uint256 price;
    }

    Medication[] private medications;
   


    //create mappings to verify patients and doctors once they have registered with the registration() functions.  Patient data should always remain private.
    mapping(address => bool) private verifiedPatient;
    mapping(address => bool) public verifiedDoctor;

    //connect the address of the patients and doctors to their structures.  MUST be private for patients (no external calling to view the patient data).
    mapping(address => Patient) private addressToPatientRecord;
    mapping(address => Doctor) public addressToDoctor;

    //connect ID's to addresses.  Function callers may only have access to ID numbers and not to any addresses. These mapping aid with function execution.
    mapping(uint256 => address) private patientIdToAddress;
    mapping(uint256 => address) private doctorIdToAddress;

    //list of patient approved doctors using a nested mapping approach (similar to ERC20 approval).  Patient data is always private.
    mapping(address => mapping(address => bool)) private approvedDoctors;

    //medication registry and lookup through medication ID.  Every ID will be unique -- second mapping helps prevent duplicate medicine ID registrations
    mapping(uint256 => Medication) public idToMedication;
    mapping(uint256 => bool) public medicationIdToBool;

    // map patient to their Examimination Result image
    mapping(uint256 => ExaminationResults) public idToExaminationResult;
    mapping(uint256 => bool) public examinationResultIdToBool;

    // dependency registry and lookup through dependency ID
    mapping(uint256 => Dependency) public idToDependency;
    mapping(uint256 => bool) public dependencyIdToBool;



    modifier onlyPatient() {
        require(verifiedPatient[msg.sender] == true, "Not a patient!");
        _;
    }

    modifier onlyDoctor() {
        require(verifiedDoctor[msg.sender] == true, "Not a doctor!");
        _;
    }

    modifier approvedDoctor(uint256 patientID) {
        require(
            approvedDoctors[msg.sender][patientIdToAddress[patientID]],
            "Doctor does not have approval to treat this patient!"
        );
        _;
    }

    modifier validNumber(uint256 _number) {
        require(_number > 0, "Value must be greater than 0!");
        _;
    }

   // Function to register new patient 

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

    // Function to update patient age

    function updateMyAge(uint8 _age) external validNumber(_age) onlyPatient {
        addressToPatientRecord[msg.sender].patientAge = _age;
    }

    // patients need to approve registered doctors before those doctors can prescribe medication, add new conditions, and view patient medical records.
    // patients enter the doctor ID number.
    function approveDoctor(uint256 _doctorID)
        external
        validNumber(_doctorID)
        onlyPatient
    {
        require(
            verifiedDoctor[doctorIdToAddress[_doctorID]] == true,
            "This doctor is not registered!"
        );
        approvedDoctors[doctorIdToAddress[_doctorID]][msg.sender] = true;
    }

    // function to allow registered patients to view their records.  Only registered patients can call this function.
    function viewMyRecords()
        external
        view
        onlyPatient
        returns (Patient memory)
    {
        return addressToPatientRecord[msg.sender];
    }

    // Registered patients can view the full list of registered doctors.  List contains doctor ID and doctor name.  Pateitn can
    // obtain more information about the doctor (specialty, location) by calling getDoctorDetails() function.
    function viewListOfDoctors()
        public
        view
        onlyPatient
        returns (Doctor[] memory)
    {
        return doctors;
    }

    // Patients can obtain a readout of the Doctor structure by inputting an integer corresponding to the Doctor ID number.
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

    // New doctors register to the network by inputting their name, specialty, and work location.
    // A new doctor structure is then created and added to list of doctors with a unique ID nubmer.
    // Doctor name, specialty, and workplace.  Doctor ID  value is automatically assigned with the counter variable.
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


    // Approved doctors can add a diagnosis to the patient's list of caseSummaries.
    function addCaseSummary(string calldata _newCaseSummary, uint256 patientID)
        external
        onlyDoctor
        approvedDoctor(patientID)
        validNumber(patientID)
    {
        address patientAddr = patientIdToAddress[patientID];
        addressToPatientRecord[patientAddr].caseSummaries.push(_newCaseSummary);

    }


    // Approved doctors can add a diagnosis to the patient's list of examinationResults.
/*

    function addExaminationResult(string calldata _newExaminationResult, uint256 patientID)
        external
        onlyDoctor
        approvedDoctor(patientID)
        validNumber(patientID)
    {
        address patientAddr = patientIdToAddress[patientID];
        addressToPatientRecord[patientAddr].examinationResults.push(_newExaminationResult);
    }
    */

    // Doctors can register new medications to the database.
    // Doctors need to call on the "addPrescription()" function to add a medication to a patient's prescriptions array.
    function addMedication(
        uint256 _medicationID,
        string calldata _medicationName,
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
            _dosage,
            _price
        );

        idToMedication[_medicationID] = medicine;
        medications.push(medicine);
    }

    // Allows doctors to view a list of currently registered medications
    // return an array of Medication structures
    function viewListofMedications()
        public
        view
        onlyDoctor
        returns (Medication[] memory)
    {
        return medications;
    }

    // Patient approved doctors can add medications to Patient structures
    // patient ID number and medication ID number
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

    //  Approved doctors can call on this function to vie their patient's medical record
    //  function takes in the patient ID number as an input.
  
    // return full patient structure including ID number, name, gender (0 or 1), age, list of conditions, and list of prescriptions.
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

    // function to add dependencies to patient portal

    function addDependency(
        uint256 _dependencyID,
        string calldata _dependencyName,
        string calldata _dependencyRelationship,
        string calldata _dependencyAddress,
        uint256 _contactNumber
    ) external onlyPatient validNumber(_dependencyID) validNumber(_contactNumber) {
        require(
            dependencyIdToBool[_dependencyID] == false,
            "Dependency  already registered!"
        );
        dependencyIdToBool[_dependencyID] = true;
        Dependency memory family = Dependency(
            _dependencyID,
            _dependencyName,
            _dependencyRelationship,
             _dependencyAddress,
             _contactNumber
        );

        idToDependency[_dependencyID] = family;
        dependencies.push(family);
    }

    // Function to view details about dependencies
    function viewListofDependencies()
        public
        view
        onlyPatient
        returns (Dependency[] memory)
    {
        return dependencies;
    }




     function addExaminationResult(
        uint256 _id,
        string calldata _ipfsHash, 
        string calldata _title, 
        string  calldata _description,
        uint256 _patientID
    ) external
        onlyDoctor
        approvedDoctor(_id)
        validNumber(_patientID){
            
        require(bytes(_ipfsHash).length == 46);
        require(bytes(_title).length > 0 && bytes(_title).length <= 256);
        require(bytes(_description).length < 1024);
         require(
            examinationResultIdToBool[_id] == false,
            "Examination Result already uploaded!"
        );


        examinationResultIdToBool[_id] = true;
        ExaminationResults memory image = ExaminationResults(
            _id,
            _ipfsHash,
            _title, 
            _description,
            _patientID
        );

        idToExaminationResult[_id] = image;
        examinationResults.push(image);
    }


    function viewExaminationResult()
        public
        view
        onlyPatient
        returns (ExaminationResults[] memory)
    {
        return examinationResults;
    }


}
