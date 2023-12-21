-- Q1-321425748
CREATE VIEW PatientSurgeryView AS
SELECT
    P.PatientID,
    CONCAT(P.Initials, ' ', P.Surname) AS PatientName,
    CONCAT(L.BedNo, ', Room ', L.RoomNo) AS Location,
    S.SurgeryName,
    S.Date AS SurgeryDate
FROM
    Patient AS P
JOIN
    Surgery AS S ON P.PatientID = S.PatientID
JOIN
    Location AS L ON P.PatientID = L.BedNo;
-- Retrieves information about patients and their surgeries from the PatientSurgeryView.
SELECT * FROM PatientSurgeryView;

-- Q2-321425748-part 1
CREATE TABLE MedInfo (
    MedName VARCHAR(100) PRIMARY KEY,
    QuantityAvailable INT,
    ExpirationDate DATE
);
SELECT * FROM MedInfo;

-- Auto-populate 'MedInfo' on 'Medications' insertion.
DELIMITER //
CREATE TRIGGER AfterMedicationsInsert
AFTER INSERT ON Medications
FOR EACH ROW
BEGIN
    INSERT INTO MedInfo (MedName, QuantityAvailable, ExpirationDate)
    VALUES (NEW.Name, NEW.Qty_of_Hand, NEW.ExpirationDate);
END;
//
DELIMITER ;

-- Q2-321425748-part 2
-- Update 'MedInfo' when 'Medications' data is modified.
DELIMITER //
CREATE TRIGGER AfterMedicationsUpdate
AFTER UPDATE ON Medications
FOR EACH ROW
BEGIN
    UPDATE MedInfo
    SET QuantityAvailable = NEW.Qty_of_Hand,
        ExpirationDate = NEW.ExpirationDate
    WHERE MedName = NEW.Name;
END;
//
DELIMITER ;

-- Q2-321425748-part 3
-- Delete corresponding data from 'MedInfo' when 'Medications' data is deleted.
DELIMITER //
CREATE TRIGGER AfterMedicationsDelete
AFTER DELETE ON Medications
FOR EACH ROW
BEGIN
    DELETE FROM MedInfo
    WHERE MedName = OLD.Name;
END;
//
DELIMITER ;

-- Q3-321425748
-- Create a stored procedure to get the number of medications taken by a patient.
-- The result will be assigned to an InOut parameter.
DELIMITER //
CREATE PROCEDURE GetMedicationCountByPatientID(
    IN PatientID INT,
    INOUT MedicationCount INT
)
BEGIN
    -- Count the number of medication interactions for the specified patient.
    SELECT COUNT(*) INTO MedicationCount
    FROM Med_Interaction
    WHERE PatientID = PatientID;
END;
//
DELIMITER ;

-- Declare a session variable to store the output
SET @PatientMedicationCount = 0;

-- Call the stored procedure with a specific PatientID and the session variable as InOut parameter
CALL GetMedicationCountByPatientID(1006, @PatientMedicationCount);

-- Display the result stored in the session variable
SELECT @PatientMedicationCount AS MedicationCount;

-- Q4-321425748
-- Create a function to calculate the number of days remaining for the expiration of a medication/medicine.
DELIMITER //
CREATE FUNCTION DaysUntilExpiration(ExpirationDate DATE)
RETURNS INT
BEGIN
    RETURN DATEDIFF(ExpirationDate, CURDATE());
END;
//
DELIMITER ;
SET GLOBAL log_bin_trust_function_creators = 1;
SET GLOBAL log_bin_trust_function_creators = 0;
DELIMITER //
CREATE FUNCTION DaysUntilExpiration(ExpirationDate DATE)
RETURNS INT
BEGIN
    RETURN DATEDIFF(ExpirationDate, CURDATE());
END;
//
DELIMITER ; 

-- Q4-321425748
-- Error resolved
-- Create a function to calculate the number of days remaining for the expiration of a medication/medicine.
DELIMITER //
CREATE FUNCTION DaysUntilExpiration(ExpirationDate DATE)
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN DATEDIFF(ExpirationDate, CURDATE());
END;
//
DELIMITER ;

-- Display all the information about medicines with less than 30 days remaining until expiry.
SELECT
    M.*,
    DaysUntilExpiration(M.ExpirationDate) AS RemainingDays
FROM
    Medications AS M
WHERE
    DaysUntilExpiration(M.ExpirationDate) <= 30;

-- Q6-321425748
-- Load XML data from the file 'D:/staff_data.xml' into the 'Staff' table.
-- Identify rows in the XML file using the '<employee>' element.
LOAD XML INFILE 'D:/staff_data.xml'
INTO TABLE Staff
ROWS IDENTIFIED BY '<StaffMember>';

-- Load XML data from the file 'D:/patient_data.xml' into the 'Patient' table.
-- Identify rows in the XML file using the '<patient>' element.
LOAD XML INFILE 'D:/patient_data.xml'
INTO TABLE Patient
ROWS IDENTIFIED BY '<Patient>';






