-- Active: 1671700995648@@127.0.0.1@3308@healthcare


-- Problem Statement 1: Some complaints have been lodged by patients that they have been
-- prescribed hospital-exclusive medicine that they can’t find elsewhere and facing problems due to
-- that. Joshua, from the pharmacy management, wants to get a report of which pharmacies have
-- prescribed hospital-exclusive medicines the most in the years 2021 and 2022. Assist Joshua to
-- generate the report so that the pharmacies who prescribe hospital-exclusive medicine more often
-- are advised to avoid such practice if possible.


SELECT ph.`pharmacyName`, count( p.prescriptionID) cnt_pharmacies
FROM prescription p
    JOIN pharmacy ph on ph.`pharmacyID` = p.`pharmacyID`
    JOIN contain c on c.`prescriptionID` = p.`prescriptionID`
    JOIN medicine m on m.`medicineID` = c.`medicineID`
WHERE m.`hospitalExclusive` = 'S'
GROUP BY ph.`pharmacyName`--p.`pharmacyID`
ORDER BY cnt_pharmacies desc
;


-- Problem Statement 2: Insurance companies want to assess the performance of their insurance
-- plans. Generate a report that shows each insurance plan, the company that issues the plan, and the
-- number of treatments the plan was claimed for.

SELECT c.companyName, p.planName, count(t.treatmentID) count_claims
FROM insurancecompany c
    JOIN insuranceplan p on p.`companyID` = c.`companyID`
    JOIN claim cl on cl.uin = p.uin
    JOIN treatment t on t.`claimID` = cl.`claimID`
GROUP BY c.`companyName`, p.`planName`
ORDER BY c.`companyName`, count_claims
;



-- Problem Statement 3: Insurance companies want to assess the performance of their insurance
-- plans. Generate a report that shows each insurance company&#39;s name with their most and least
-- claimed insurance plans.

with cte as
(
    SELECT c.companyName cname, p.planName pname, count(t.treatmentID) count_claims
    FROM insurancecompany c
        JOIN insuranceplan p on p.`companyID` = c.`companyID`
        JOIN claim cl on cl.uin = p.uin
        JOIN treatment t on t.`claimID` = cl.`claimID`
    GROUP BY c.`companyName`, p.`planName`
    ORDER BY c.`companyName`, count_claims
)
SELECT cname, pname, count_claims
FROM cte ct
WHERE count_claims in (SELECT min(count_claims) from cte WHERE cname=ct.cname
                        UNION
            SELECT max(count_claims) from cte WHERE cname=ct.cname )
;
SELECT DISTINCT `companyName`
FROM insurancecompany
ORDER BY `companyName`;



-- Problem Statement 4: The healthcare department wants a state-wise health report to assess which
-- state requires more attention in the healthcare sector. Generate a report for them that shows the
-- state name, number of registered people in the state, number of registered patients in the state,
-- and the people-to-patient ratio. sort the data by people-to-patient ratio.


SELECT a.state, count(distinct p.personID), COUNT(DISTINCT pt.`patientID`), count(distinct p.personID)/COUNT(DISTINCT pt.`patientID`) people_patient_ration
FROM address a
    JOIN person p on p.`addressID` = a.`addressID`
    left JOIN patient pt on pt.`patientID` = p.`personID`
GROUP BY a.state
ORDER BY people_patient_ration
;



-- Problem Statement 5: Jhonny, from the finance department of Arizona(AZ), has requested a report
-- that lists the total quantity of medicine each pharmacy in his state has prescribed that falls under
-- Tax criteria I for treatments that took place in 2021. Assist Jhonny in generating the report.

-- EXPLAIN FORMAT = tree 
SELECT a.state, ph.`pharmacyName`, SUM(c.quantity)
FROM address a
    JOIN pharmacy ph on ph.`addressID` = a.`addressID`
    JOIN prescription p on p.`pharmacyID` = ph.`pharmacyID`
    JOIN contain c on c.`prescriptionID` = p.`prescriptionID`
    JOIN treatment t on p.`treatmentID` = t.`treatmentID`
    JOIN medicine m on c.`medicineID` = m.`medicineID`
WHERE year(t.`date`) = 2021 and m.`taxCriteria` = 'I'
GROUP BY a.state, ph.`pharmacyName`
ORDER BY a.state;