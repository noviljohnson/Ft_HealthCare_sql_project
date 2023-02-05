-- Active: 1671700995648@@127.0.0.1@3308@healthcare

-- Problem Statement 1:  Jimmy, from the healthcare department, has requested a report that shows how the number of treatments each 
-- age category of patients has gone through in the year 2022. The age category is as follows, Children (00-14 years), 
-- Youth (15-24 years), Adults (25-64 years), and Seniors (65 years and over). 
-- Assist Jimmy in generating the report. 
with patientCte AS (
    SELECT `patientID`,TIMESTAMPDIFF(YEAR,dob,NOW()) AS `age` FROM patient
)
SELECT CASE WHEN age <15 THEN 'Children'
            WHEN age>=15 AND age<=24 THEN 'Youth'
            WHEN age>=25 AND age<=64 THEN 'Adults'
            ELSE 'Seniors' END AS `age Category`,COUNT(*) FROM patientCte p
NATURAL JOIN treatment t
WHERE YEAR(t.date)=2022
GROUP BY `age Category`;


-- Problem Statement 2:  Jimmy, from the healthcare department, wants to know which disease is infecting people of which gender more often.
-- Assist Jimmy with this purpose by generating a report that shows for each disease the male-to-female ratio. Sort the data in a way that is helpful for Jimmy.


-- SELECT d.diseaseName, sum(CASE WHEN p.gender = 'male' THEN 1 ELSE 0 end)/COUNT(*) male_ratio,
--                         sum(CASE WHEN p.gender = 'female' THEN 1 ELSE 0 end)/COUNT(*) female_ratio
SELECT d.`diseaseName`, sum(CASE WHEN p.gender = 'male' THEN 1 ELSE 0 end)/sum(CASE WHEN p.gender = 'female' THEN 1 ELSE 0 end) male_to_female_ratio
FROM disease d 
    JOIN treatment t on d.`diseaseID` = t.`diseaseID`
    JOIN person p on p.`personID` = t.`patientID`
GROUP BY d.`diseaseName`;


-- Problem Statement 3: Jacob, from insurance management, has noticed that insurance
-- claims are not made for all the treatments. He also wants to figure out if the gender of the
-- patient has any impact on the insurance claim. Assist Jacob in this situation by generating a
-- report that finds for each gender the number of treatments, number of claims, and treatment-
-- to-claim ratio. And notice if there is a significant difference between the treatment-to-claim
-- ratio of male and female patients.

select *, round(total_treatments/ total_claims, 2) as ratio from 
(
	select p.gender, count(t.treatmentID) as total_treatments,count(c.claimID) as total_claims 
    from person p 
        inner join treatment t on p.personID = t.patientID
	    left join claim c on t.claimID = c.claimID
	group by p.gender
)a;



-- Problem Statement 4: The Healthcare department wants a report about the inventory of
-- pharmacies. Generate a report on their behalf that shows how many units of medicine each
-- pharmacy has in their inventory, the total maximum retail price of those medicines, and the
-- total price of all the medicines after discount.
-- Note: discount field in keep signifies the percentage of discount on the maximum price.

SELECT `pharmacyID`,COUNT(`medicineID`),ROUND(sum(`maxPrice`)), ROUND(SUM(`maxPrice`-`maxPrice`*discount/100))
FROM pharmacy
NATURAL JOIN keep
NATURAL JOIN medicine
GROUP BY `pharmacyID`
ORDER BY `pharmacyID`;


-- Problem Statement 5: The healthcare department suspects that some pharmacies
-- prescribe more medicines than others in a single prescription, for them, generate a report
-- that finds for each pharmacy the maximum, minimum and average number of medicines
-- prescribed in their prescriptions.

SELECT  p.`pharmacyID`,p.`prescriptionID`,min(c.quantity),max(c.quantity), avg(c.quantity)
FROM prescription p
JOIN contain c on c.`prescriptionID` = p.`prescriptionID`
GROUP BY p.`pharmacyID`,p.`prescriptionID`
ORDER BY p.`pharmacyID`;


SELECT `pharmacyID`, MAX(quantity),MIN(quantity),AVG(quantity) 
FROM prescription
NATURAL JOIN contain
GROUP BY `pharmacyID`;



