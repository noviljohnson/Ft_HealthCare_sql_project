-- Problem Statement 1:
-- “HealthDirect” pharmacy finds it difficult to deal with the product type of medicine being
-- displayed in numerical form, they want the product type in words. Also, they want to filter the
-- medicines based on tax criteria.
-- Display only the medicines of product categories 1, 2, and 3 for medicines that come under
-- tax category I and medicines of product categories 4, 5, and 6 for medicines that come
-- under tax category II.
-- Write a SQL query to solve this problem.
-- ProductType numerical form and ProductType in words are given by
-- 1 - Generic,
-- 2 - Patent,
-- 3 - Reference,
-- 4 - Similar,
-- 5 - New,
-- 6 - Specific,
-- 7 - Biological,
-- 8 – Dinamized

CREATE TABLE if not EXISTS proTypeToName(id int PRIMARY KEY AUTO_INCREMENT,productName VARCHAR(15));
INSERT INTO proTypeToName(`productName`) VALUES('Generic'),('Patent'),('Regerence'),('Similar'),('New'),('Specific'),('Biological'),('Dinamized');

-- EXPLAIN FORMAT = tree
SELECT *
FROM medicine m
    JOIN protypetoname p on p.id = m.`productType`
WHERE `productType` in (1,2,3) and `taxCriteria` = 'I'
UNION
SELECT *
FROM medicine m
    JOIN protypetoname p on p.id = m.`productType`
WHERE `productType` in (4,5,6) and `taxCriteria` = 'II';



-- Problem Statement 2:
-- &#39;Ally Scripts&#39; pharmacy company wants to find out the quantity of medicine prescribed in
-- each of its prescriptions.
-- Write a query that finds the sum of the quantity of all the medicines in a prescription and if
-- the total quantity of medicine is less than 20 tag it as “low quantity”. If the quantity of
-- medicine is from 20 to 49 (both numbers including) tag it as “medium quantity“ and if the
-- quantity is more than equal to 50 then tag it as “high quantity”.
-- Show the prescription Id, the Total Quantity of all the medicines in that prescription, and the
-- Quantity tag for all the prescriptions issued by &#39;Ally Scripts&#39;.

SELECT prescriptionID, totalQuantity, 
    CASE 
        WHEN totalQuantity < 20 then 'low Quantity'
        WHEN (totalQuantity >= 20 and totalQuantity <= 49) then 'Medium Quantity'
        When totalQuantity >= 50 then 'high quantity'
    end as tag
FROM (
    SELECT distinct p.prescriptionID prescriptionID, sum(c.quantity) OVER(PARTITION BY p.`prescriptionID`) totalQuantity
    FROM pharmacy ph 
        JOIN prescription p on p.`pharmacyID` = ph.`pharmacyID`
        JOIN contain c on c.`prescriptionID` = p.`prescriptionID`
    WHERE ph.`pharmacyName` = 'Ally Scripts'
) a
;


-- Problem Statement 3:
-- In the Inventory of a pharmacy &#39;Spot Rx&#39; the quantity of medicine is considered ‘HIGH
-- QUANTITY’ when the quantity exceeds 7500 and ‘LOW QUANTITY’ when the quantity falls
-- short of 1000. The discount is considered “HIGH” if the discount rate on a product is 30% or
-- higher, and the discount is considered “NONE” when the discount rate on a product is 0%.
-- &#39;Spot Rx&#39; needs to find all the Low quantity products with high discounts and all the high-
-- quantity products with no discount so they can adjust the discount rate according to the
-- demand.
-- Write a query for the pharmacy listing all the necessary details relevant to the given
-- requirement.

-- Hint: Inventory is reflected in the Keep table.


SELECT m.`productName`,
    CASE 
        WHEN k.quantity < 1000 THEN 'Low quantity'
        WHEN k.quantity > 7500 THEN 'High quantity'
        ELSE 'Medium quantity'
    END as quantity_tag,
    CASE 
        WHEN k.discount >= 30 THEN 'High'
        WHEN k.discount = 0 THEN 'None'
        ELSE 'Avg'
    END as discount
FROM medicine m
    JOIN keep k on m.`medicineID` = k.`medicineID`
    JOIN pharmacy ph on ph.`pharmacyID` = k.`pharmacyID`
WHERE ph.`pharmacyName` = 'Spot Rx'
HAVING (quantity_tag = 'Low quantity' and discount='High') or (quantity_tag = 'High quantity' and discount = 'None')
;



-- Problem Statement 4:
-- Mack, From HealthDirect Pharmacy, wants to get a list of all the affordable and costly,
-- hospital-exclusive medicines in the database. Where affordable medicines are the medicines
-- that have a maximum price of less than 50% of the avg maximum price of all the medicines

-- in the database, and costly medicines are the medicines that have a maximum price of more
-- than double the avg maximum price of all the medicines in the database. Mack wants clear
-- text next to each medicine name to be displayed that identifies the medicine as affordable or
-- costly. The medicines that do not fall under either of the two categories need not be
-- displayed.
-- Write a SQL query for Mack for this requirement.

SELECT DISTINCT m.`productName`,
    case 
        WHEN m.`maxPrice` < ag.avg_price*0.5 THEN 'Affordable HE medicine'
        WHEN m.`maxPrice` > ag.avg_price*2 THEN 'Costly HE medicine'
        ELSE 'None' 
    END as `Affordable-Costly`
FROM medicine m
    JOIN (SELECT AVG(maxPrice) avg_price
            FROM medicine) ag
HAVING `Affordable-Costly`  not LIKE 'None'
ORDER BY `Affordable-Costly`
;



-- The healthcare department wants to categorize the patients into the following category.
-- YoungMale: Born on or after 1 st Jan 2005 and gender male.
-- YoungFemale: Born on or after 1 st Jan 2005 and gender female.
-- AdultMale: Born before 1 st Jan 2005 but on or after 1 st Jan 1985 and gender male.
-- AdultFemale: Born before 1 st Jan 2005 but on or after 1 st Jan 1985 and gender female.
-- MidAgeMale: Born before 1 st Jan 1985 but on or after 1 st Jan 1970 and gender male.
-- MidAgeFemale: Born before 1 st Jan 1985 but on or after 1 st Jan 1970 and gender female.
-- ElderMale: Born before 1 st Jan 1970, and gender male.
-- ElderFemale: Born before 1 st Jan 1970, and gender female.

-- Write a SQL query to list all the patient name, gender, dob, and their category.



SELECT pt.`personName`, pt.gender, p.dob,
    CASE
        WHEN p.dob >= date('2005-01-01') and pt.gender = 'male' THEN 'YoungMale'
        WHEN p.dob >= date('2005-01-01') and pt.gender = 'female' THEN 'YoungFemale'
        WHEN p.dob < date('2005-01-01') and p.dob >= '1985-01-01' and pt.gender = 'male' THEN 'AdultMale'
        WHEN p.dob < date('2005-01-01') and p.dob >= '1985-01-01' and pt.gender = 'female'  THEN 'AdultFemale'
        WHEN p.dob < date('1985-01-01') and p.dob >= '1970-01-01' and pt.gender = 'female'  THEN 'MidAgeMale'
        WHEN p.dob < '1985-01-01' and p.dob >= '1970-01-01' and pt.gender = 'male'  THEN 'MidAgeFemale'
        WHEN p.dob < date('1970-01-01') and pt.gender = 'male'  THEN 'ElderMale'
        WHEN p.dob < date('1970-01-01') and pt.gender = 'female'  THEN 'ElderFemale'
    END as ageTag
FROM person pt 
    JOIN patient p on p.`patientID` = pt.`personID`
;


