-- Active: 1671700995648@@127.0.0.1@3308@healthcare


-- Problem Statement 1: A company needs to set up 3 new pharmacies, they have come up with an
-- idea that the pharmacy can be set up in cities where the pharmacy-to-prescription ratio is the lowest
-- and the number of prescriptions should exceed 100. Assist the company to identify those cities
-- where the pharmacy can be set up.

SELECT a.city, COUNT(distinct p.`pharmacyID`)/COUNT(c.`prescriptionID`) ratio 
FROM address a
    left JOIN pharmacy p on p.`addressID` = a.`addressID`
    JOIN prescription c on c.`pharmacyID` = p.`pharmacyID`
GROUP BY a.city--,p.`pharmacyID`
HAVING COUNT(c.`prescriptionID`) > 100
ORDER BY ratio  --, a.city;
LIMIT 3;

select city,count(pharmacyID) /sum(pre_count) as ratio
from
(
	select city,pharmacyID,count(prescriptionID) as pre_count
	from
	address ad inner join pharmacy ph 
	on ad.addressID = ph.addressID
	inner join prescription pr using(pharmacyID)
	group by city, pharmacyID
) a
group by city
having sum(pre_count)>100
order by ratio;



-- Problem Statement 2: The State of Alabama (AL) is trying to manage its healthcare resources more
-- efficiently. For each city in their state, they need to identify the disease for which the maximum
-- number of patients have gone for treatment. Assist the state for this purpose.
-- Note: The state of Alabama is represented as AL in Address Table.

with cte as
(select a.city,d.diseaseName,count(t.patientID) as counts
from treatment t 
    join person p on t.patientID=p.personID
    join disease d on t.diseaseID=d.diseaseID
    join address a on p.addressID=a.addressID
where a.state='AL'
group by a.city, d.diseaseName)

select city,diseaseName,counts
from
(select city,diseaseName,counts, dense_rank() over(partition by city order by counts desc) as ranks
from cte) a
where ranks=1;





-- Problem Statement 3: The healthcare department needs a report about insurance plans. The report
-- is required to include the insurance plan, which was claimed the most and least for each disease.
-- Assist to create such a report.

WITH cte AS
(
    SELECT d.diseaseName dname,i.`planName` plan, COUNT(c.`claimID`) cnt
    FROM disease d
        JOIN treatment t on t.`diseaseID` = d.`diseaseID`
        JOIN claim c on c.`claimID` = t.`claimID`
        JOIN insuranceplan i on i.uin = c.uin
    GROUP BY d.`diseaseName`,i.`planName`
    ORDER BY d.`diseaseName`, COUNT(c.`claimID`)
)
SELECT dname, plan, cnt
FROM cte ct
WHERE cnt in (SELECT min(cnt) from cte WHERE dname=ct.dname) OR
 cnt in (SELECT max(cnt) from cte WHERE dname=ct.dname)
;



-- Problem Statement 4: The Healthcare department wants to know which disease is most likely to
-- infect multiple people in the same household. For each disease find the number of households that
-- has more than one patient with the same disease.
-- Note: 2 people are considered to be in the same household if they have the same address.



SELECT addressID,COUNT(*) cnt
FROM person 
WHERE `personID` in (
        SELECT patientId
        FROM patient
)
GROUP BY `addressID`
HAVING cnt > 1;


select diseaseName,p.`addressID`, count(*)
FROM disease d
    JOIN treatment t  on t.`diseaseID` = d.`diseaseID`
    JOIN patient pt on pt.`patientID` = t.`patientID`
    JOIN person p on p.`personID` = pt.`patientID`
    JOIN (
        SELECT addressID,COUNT(*) cnt
        FROM person 
        WHERE `personID` in (
            SELECT patientId
            FROM patient
        )
GROUP BY `addressID`
HAVING cnt > 1
    )
GROUP BY d.`diseaseName`, p.`addressID`
;


SELECT count(x.`personID`),x.`addressID`
FROM person x
    JOIN person y on x.`addressID` = y.`addressID` 
GROUP BY x.`addressID`
HAVING count(*) > 1
ORDER BY x.`addressID`
;


SELECT diseaseID
FROM disease d

WHERE patientID in (
    SELECT patientID
    FROM treatment
    WHERE `diseaseID` = d.`diseaseID`
)

 