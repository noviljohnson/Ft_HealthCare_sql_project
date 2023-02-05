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



