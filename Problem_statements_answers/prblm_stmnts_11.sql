-- Active: 1671700995648@@127.0.0.1@3308@healthcare


-- Problem Statement 1:
-- Patients are complaining that it is often difficult to find some medicines. 
-- They move from pharmacy to pharmacy to get the required medicine. 
-- A system is required that finds the pharmacies and their contact number that have the required medicine in their inventory.
--  So that the patients can contact the pharmacy and order the required medicine.
-- Create a stored procedure that can fix the issue


DELIMITER //

CREATE Procedure findMedicine(
    IN medName VARCHAR(30)
)
BEGIN
    SELECT p.pharmacyName, p.phone
    FROM pharmacy p
        JOIN keep k ON k.`pharmacyID` = p.`pharmacyID`
        JOIN medicine m on m.`medicineID` = k.`medicineID`
    WHERE m.productName = medName
    ;
END//

DELIMITER ;

CALL findMedicine("FAULDVINCRI");


-- Problem Statement 2:
-- The pharmacies are trying to estimate the average cost of all the prescribed medicines per prescription, 
-- for all the prescriptions they have prescribed in a particular year. 
-- Create a stored function that will return the required value when the pharmacyID and year are passed to it. 
-- Test the function with multiple values.


DROP FUNCTION avgCost_per_Prescription;

DELIMITER //

CREATE Function avgCost_per_Prescription(
    pharmId INT(15),
    yr INT(6)
)
RETURNS DECIMAL(20,6)
DETERMINISTIC
BEGIN
    declare avg_cost DECIMAL(20,6);
    SELECT  AVG(m.`maxPrice`) INTO avg_cost 
    FROM pharmacy p
        JOIN prescription pr ON pr.`pharmacyID` = p.`pharmacyID`
        JOIN contain c ON c.`prescriptionID` = pr.`prescriptionID`
        JOIN medicine m ON m.`medicineID` = c.`medicineID`
        JOIN treatment t ON t.`treatmentID` = pr.`treatmentID`
    WHERE YEAR(t.`date`) = yr and p.`pharmacyID` = pharmId
    GROUP BY p.`pharmacyID`
    ;

    RETURN avg_cost;
END//

DELIMITER ;

SELECT `pharmacyID`,`pharmacyName`, avgCost_per_Prescription(`pharmacyID`,2022)
FROM pharmacy;


-- Problem Statement 3:
-- The healthcare department has requested an application that finds out the disease that was spread the most in a state for a given year. 
-- So that they can use the information to compare the historical data and gain some insight.
-- Create a stored function that returns the name of the disease for which the patients from a particular
--  state had the most number of treatments for a particular year. Provided the name of the state and year is passed to 
--  the stored function.


DROP FUNCTION mostSpread_disease;

DELIMITER //

CREATE Function mostSpread_disease(
    states VARCHAR(5),
    yr INT(6)
)
RETURNS VARCHAR(200)
DETERMINISTIC
BEGIN
    declare maxDiseases VARCHAR(200);
    SELECT GROUP_CONCAT(dname) into maxDiseases
    FROM (
        SELECT a.state st, d.`diseaseName` dname, COUNT(distinct t.`patientID`) cnt, 
                DENSE_RANK() OVER(PARTITION BY a.state ORDER BY count(distinct t.`patientID`) desc) ranks
        FROM disease d
            JOIN treatment t on t.`diseaseID` = d.`diseaseID`
            JOIN person pr on pr.`personID` = t.`patientID`
            JOIN address a on a.`addressID` = pr.`addressID`
        WHERE YEAR(t.date) = yr and a.state = states
        GROUP BY a.state,d.`diseaseName`
        -- ORDER BY a.state, cnt desc
    ) a
    WHERE a.ranks = 1
    -- GROUP BY a.st
    ;

    RETURN maxDiseases;
END//

DELIMITER ;


select mostSpread_disease('AK', 2022);
-- FROM address;

select DISTINCT state FROM address;


-- Problem Statement 4:
-- The representative of the pharma union, Aubrey, has requested a system that she can use to find how many people in a 
-- specific CITY have been treated for a specific DISEASE in a specific YEAR.
-- Create a stored function for this purpose.



DROP FUNCTION cityWiseDisease_count;

DELIMITER //

CREATE Function cityWiseDisease_count(
    citys VARCHAR(30),
    dis VARCHAR(50),
    yr INT(6)
)
RETURNS INT
DETERMINISTIC
BEGIN
    declare cnt int;

    SELECT COUNT(distinct t.`patientID`) into cnt
    FROM disease d
        JOIN treatment t on t.`diseaseID` = d.`diseaseID`
        JOIN person pr on pr.`personID` = t.`patientID`
        JOIN address a on a.`addressID` = pr.`addressID`
    WHERE YEAR(t.date) = yr and a.city = citys and d.diseaseName = dis
    GROUP BY a.city,d.`diseaseName`
    ;

    RETURN cnt;
END//

DELIMITER ;

SELECT 'Norman', cityWiseDisease_count('Norman',"Alzheimer's disease",2022)
;

-- Problem Statement 5:
-- The representative of the pharma union, Aubrey, is trying to audit different aspects of the pharmacies. 
-- She has requested a system that can be used to find the average balance for claims submitted by a 
-- specific insurance company in the year 2022. 
-- Create a stored function that can be used in the requested application. 


DROP FUNCTION avgBal_ICompany;

DELIMITER //

CREATE Function avgBal_ICompany(
    icompany VARCHAR(30)
)
RETURNS DECIMAL(20,10)
DETERMINISTIC
BEGIN
    declare avg_bal DECIMAL(20,10);

    SELECT AVG(c.balance) into avg_bal
    FROM insurancecompany ic 
        JOIN insuranceplan ip on ic.`companyID` = ip.`companyID`
        JOIN claim c on c.uin = ip.uin
        JOIN treatment t on t.`claimID` = c.`claimID`
    WHERE YEAR(t.`date`) = 2022 and ic.`companyName` = icompany
    GROUP BY ic.`companyName`
    ORDER BY ic.`companyName`
    ;

    RETURN avg_bal;
END //

DELIMITER ;

SELECT avgBal_ICompany('Acko General Insurance Ltd.�');