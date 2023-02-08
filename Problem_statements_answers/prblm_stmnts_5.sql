-- Active: 1671700995648@@127.0.0.1@3308@healthcare


-- Problem Statement 1:
-- Johansson is trying to prepare a report on patients who have gone through treatments more
-- than once. Help Johansson prepare a report that shows the patient&#39;s name, the number of
-- treatments they have undergone, and their age, Sort the data in a way that the patients who
-- have undergone more treatments appear on top.


SELECT  t.`patientID`,p.`personName`, COUNT(t.`treatmentID`) count_trtmnts, TIMESTAMPDIFF(YEAR,pt.dob,CURRENT_DATE), pt.dob
FROM person p
    JOIN patient pt on pt.`patientID` = p.`personID`
    JOIN treatment t on t.`patientID` = p.`personID`
GROUP BY t.`patientID`,p.`personName`
HAVING count_trtmnts > 1
ORDER BY count_trtmnts DESC;

-- SELECT * FROM treatment;


-- Problem Statement 2:
-- Bharat is researching the impact of gender on different diseases, He wants to analyze if a
-- certain disease is more likely to infect a certain gender or not.
-- Help Bharat analyze this by creating a report showing for every disease how many males
-- and females underwent treatment for each in the year 2021. It would also be helpful for
-- Bharat if the male-to-female ratio is also shown.

-- EXPLAIN FORMAT = tree
SELECT d.diseaseName, sum(if(p.gender = 'male',1,0)) numOfMales, sum(if(p.gender = 'female',1,0)) numOfFemales, sum(if(p.gender = 'male',1,0))/sum(if(p.gender = 'female',1,0)) males_females_ratio
FROM disease d
    JOIN treatment t on t.`diseaseID` = d.`diseaseID`
    JOIN person p on p.`personID` = t.`patientID`
WHERE year(t.`date`) = 2021
GROUP BY d.`diseaseName`
;

-- EXPLAIN FORMAT = tree 
SELECT disease, numOfMales, cnt-numOfMales numOfFemales, numOfMales/(cnt-numOfMales)
FROM (
    SELECT d.diseaseName disease, sum(if(p.gender = 'male',1,0)) numOfMales, COUNT(*) cnt
    FROM disease d
        JOIN treatment t on t.`diseaseID` = d.`diseaseID`
        JOIN person p on p.`personID` = t.`patientID`
    WHERE YEAR(t.`date`) = 2021
    GROUP BY d.`diseaseName`
    
) a
;


-- Problem Statement 3:
-- Kelly, from the Fortis Hospital management, has requested a report that shows for each
-- disease, the top 3 cities that had the most number treatment for that disease.
-- Generate a report for Kelly’s requirement.

SELECT  disease, city, cnt
FROM (
    SELECT d.`diseaseName` disease,a.city city,count(distinct p.`personID`) cnt, DENSE_RANK() OVER(PARTITION BY d.`diseaseName` ORDER BY count(distinct p.`personID`) DESC ) ranks3
    FROM disease d
        JOIN treatment t on t.`diseaseID` = d.`diseaseID`
        JOIN person p on p.`personID` = t.`patientID`
        JOIN address a on a.`addressID` = p.`addressID`
    GROUP BY d.`diseaseName`,a.city
    -- HAVING ranks3 < 4
    ORDER BY d.`diseaseName`, cnt desc

) a
WHERE ranks3 < 4
;



-- Problem Statement 4:
-- Brooke is trying to figure out if patients with a particular disease are preferring some
-- pharmacies over others or not, For this purpose, she has requested a detailed pharmacy
-- report that shows each pharmacy name, and how many prescriptions they have prescribed
-- for each disease in 2021 and 2022, She expects the number of prescriptions prescribed in
-- 2021 and 2022 be displayed in two separate columns.
-- Write a query for Brooke’s requirement.


SELECT ph.`pharmacyName` phrmcyname, d.`diseaseName` disName, 
        sum(if (year(t.date) = 2021,1,0)), sum(if (year(t.date) = 2022,1,0)) 
FROM pharmacy ph
    JOIN prescription pr on pr.`pharmacyID` = ph.`pharmacyID`
    JOIN treatment t on t.`treatmentID` = pr.`treatmentID`
    JOIN disease d on d.`diseaseID` = t.`diseaseID`
WHERE YEAR(t.`date`)  in (2021,2022)
GROUP BY ph.`pharmacyName`, d.`diseaseName`

;


-- Problem Statement 5:
-- Walde, from Rock tower insurance, has sent a requirement for a report that presents which
-- insurance company is targeting the patients of which state the most.
-- Write a query for Walde that fulfills the requirement of Walde.
-- Note: We can assume that the insurance company is targeting a region more if the patients
-- of that region are claiming more insurance of that company.

