-- 1a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.
SELECT DISTINCT scribe.npi, total_claim_count
FROM prescriber AS scribe
FULL JOIN prescription AS script
ON scribe.npi = script.npi
WHERE total_claim_count IS NOT NULL
ORDER BY script.total_claim_count DESC
-- answer: npi= 1912011792

--1b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.
SELECT DISTINCT nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, total_claim_count
FROM prescriber AS scribe
FULL JOIN prescription AS script
ON scribe.npi = script.npi
WHERE total_claim_count IS NOT NULL
ORDER BY script.total_claim_count DESC
-- answer: DAVID, COFFEY, Family Practice, 4538

--2a. Which specialty had the most total number of claims (totaled over all drugs)?
SELECT DISTINCT scribe.specialty_description, sum(total_claim_count) AS claim_count
FROM prescriber AS scribe
FULL JOIN prescription AS script
ON scribe.npi = script.npi
WHERE total_claim_count IS NOT NULL
GROUP BY scribe.specialty_description 
ORDER BY claim_count DESC
-- answer: Family Practice, 351084492

--2b. Which specialty had the most total number of claims for opioids?
SELECT DISTINCT scribe.specialty_description, d.opioid_drug_flag, sum(total_claim_count) AS claim_count
FROM prescriber AS scribe
INNER JOIN prescription AS script
    ON scribe.npi = script.npi
INNER JOIN drug AS d
    ON script.drug_name = d.drug_name
WHERE total_claim_count IS NOT NULL
GROUP BY scribe.specialty_description
ORDER BY claim_count DESC
--answer:??


--3a. Which drug (generic_name) had the highest total drug cost?
SELECT DISTINCT generic_name, total_drug_cost
FROM prescription AS script
FULL JOIN drug AS d
ON script.drug_name = d.drug_name
WHERE total_drug_cost IS NOT NULL
ORDER BY total_drug_cost DESC
--answer: PIRFENIDONE, 2829174.3

--3b. Which drug (generic_name) has the hightest total cost per day?



--4a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs. **Hint:** You may want to use a CASE expression for this.

SELECT drug_name, opioid_drug_name 
  CASE WHEN  
  AND  THEN  WHEN 
  AND THEN  WHEN  THEN  
  END 
FROM 

--4b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.

--5a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.
SELECT cbsa, state
FROM cbsa AS c
FULL JOIN fips_county
ON c.fipscounty = county
WHERE state = 'TN'
-- answer:576

--5b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.
SELECT cbsaname, sum(population) AS sum
FROM cbsa AS c
FULL JOIN fips_county AS fc
ON c.fipscounty = county
FULL JOIN population AS pop
ON c.fipscounty = pop.fipscounty
WHERE population IS NOT NULL
GROUP BY c.cbsaname
--answer: Nashville-Davidson--Murfreesboro--Franklin, TN = 65894760, "Morristown, TN"	4188672

--5c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.
SELECT county, sum(population) AS sum
FROM population AS pop
FULL JOIN fips_county AS fc
ON pop.fipscounty = county
WHERE pop.fipscounty NOT LIKE '%cbsa%'
GROUP BY fc.county



--6a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.

--6b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.

--6c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.

--7a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet


--7b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).


--7c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.