-- 1a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.
SELECT npi,	SUM(total_claim_count) AS total_claims
	FROM prescription
	GROUP BY npi
	ORDER BY total_claims DESC
	LIMIT 1;
-- answer:1881634483, 598242

--1b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.
SELECT nppes_provider_first_name,nppes_provider_last_org_name, specialty_description, SUM(total_claim_count) AS total_claim_count_over_all_drugs
FROM prescription
INNER JOIN prescriber
ON prescriber.npi=prescription.npi
GROUP BY nppes_provider_first_name,nppes_provider_last_org_name, specialty_description
ORDER BY total_claim_count_over_all_drugs DESC
-- answer: "BRUCE", "PENDLEY", "Family Practice", 3589452

--2a. Which specialty had the most total number of claims (totaled over all drugs)?
SELECT prescriber.specialty_description, SUM(prescription.total_claim_count) AS total_claim
        FROM prescriber
		INNER JOIN prescription 
		ON prescriber.npi = prescription.npi
		GROUP BY prescriber.specialty_description
		ORDER BY total_claim DESC;
-- answer: Family Practice, 351084492

--2b. Which specialty had the most total number of claims for opioids?
SELECT p.specialty_description, --p.npi, d.opioid_drug_flag, 
SUM(total_claim_count) as total_sum
FROM prescriber as p
INNER JOIN prescription as pr
ON p.npi=PR.npi
INNER JOIN drug as d
ON pr.drug_name=d.drug_name
WHERE d.opioid_drug_flag = 'Y'
GROUP BY 1 --2,3
ORDER BY total_sum DESC
--answer: "Nurse Practitioner"	194582520

--3a. Which drug (generic_name) had the highest total drug cost?
SELECT drug.generic_name, SUM(prescription.total_drug_cost) AS total_cost
FROM drug
INNER JOIN prescription
	ON drug.drug_name = prescription.drug_name
WHERE prescription.total_drug_cost IS NOT NULL
GROUP BY drug.generic_name
ORDER BY total_cost DESC
LIMIT 10;
--answer: "INSULIN GLARGINE,HUM.REC.ANLOG"	3753506388.60

--3b. Which drug (generic_name) has the hightest total cost per day?
SELECT drug.generic_name
		,	(SUM(prescription.total_drug_cost)/SUM(prescription.total_day_supply)) :: MONEY as daily_drug_cost
	FROM prescription
		INNER JOIN drug
			USING (drug_name)
	GROUP BY drug.generic_name
	ORDER BY daily_drug_cost DESC
--answer:"C1 ESTERASE INHIBITOR"	"$3,495.22"

--4a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs. **Hint:** You may want to use a CASE expression for this.
SELECT drug_name,
	CASE 
		WHEN d1.opioid_drug_flag = 'Y' THEN 'opioid'
		WHEN d1.antibiotic_drug_flag = 'Y' THEN 'antibiotic'
		ELSE 'neither' 
		END AS drug_type
FROM drug AS d1 
--answer: "1ST TIER UNIFINE PENTIPS"	"neither"

--4b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.
 SELECT drug_type, SUM(total_drug_cost)::MONEY AS total_cost 
	FROM (SELECT drug.drug_name ,
	CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
	WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
    ELSE 'neither'
	END AS drug_type , total_drug_cost 
	 
	FROM drug AS drug
	INNER JOIN prescription
	ON drug.drug_name = prescription.drug_name ) AS drug_cost 
	WHERE drug_type IN ('opioid','antibiotic')
	GROUP BY drug_type;
--answer: "antibiotic"	"$1,383,664,365.36", "opioid"	"$3,782,902,549.32"

--5a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.
SELECT COUNT(*) 
FROM fips_county AS f
INNER JOIN cbsa AS c
ON f.fipscounty = c.fipscounty
WHERE f.state = 'TN'
-- answer:1512

--5b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.
SELECT cbsa, cbsaname, fips_county.state, sum(population) AS combined_population
FROM cbsa
INNER JOIN fips_county
ON cbsa.fipscounty = fips_county.fipscounty
INNER JOIN population 
ON fips_county.fipscounty = population.fipscounty
GROUP BY cbsa, cbsaname, fips_county.state
ORDER BY combined_population DESC
--answer:"34980" "Nashville-Davidson--Murfreesboro--Franklin, TN"	"TN"	395368560
--"34100"	"Morristown, TN"	"TN"	25132032

--5c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.
SELECT f.county, SUM(p.population) as combined_population
FROM fips_county AS f
INNER JOIN population AS p 
	ON f.fipscounty = p.fipscounty
WHERE f.fipscounty IN
		(SELECT fipscounty FROM fips_county 
		EXCEPT
		SELECT fipscounty FROM cbsa)
GROUP BY f.county
ORDER BY combined_population desc
LIMIT 1
--answer:"SEVIER", 3438828


--6a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.
SELECT drug_name,total_claim_count 
	FROM prescription
	WHERE total_claim_count >= 3000
--answer:	"OXYCODONE HCL"	4538

--6b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.
SELECT d.drug_name,
	       p.total_claim_count,d.opioid_drug_flag,
	 CASE
	 WHEN d.opioid_drug_flag = 'Y' THEN 'YES'
	 ELSE 'NO'
	 END AS is_opioid
	 FROM prescription P
	 INNER JOIN drug AS d
	 ON p.drug_name = d.drug_name
	WHERE total_claim_count >= 3000;
--answer: "OXYCODONE HCL"	4538	"Y"	"YES"

--6c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.
SELECT total_claim_count,d.drug_name,CONCAT(pres.nppes_provider_last_org_name,' ',
		pres.nppes_provider_first_name) as prescriber_name,
CASE WHEN opioid_drug_flag = 'Y' THEN 'Opioid'
	WHEN opioid_drug_flag = 'N' THEN 'Not Opioid' END as opioid
FROM prescription as pr
INNER JOIN drug as d
ON pr.drug_name=d.drug_name
INNER JOIN prescriber as pres
ON pr.npi=pres.npi
WHERE total_claim_count >= 3000

--7a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet
SELECT 	p.npi
	, 	d.drug_name
FROM prescriber as p
CROSS JOIN drug as d
	WHERE 	p.specialty_description ='Pain Management' 
	AND 	p.nppes_provider_city = 'NASHVILLE' 
	AND 	d.opioid_drug_flag = 'Y'



--7b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).
SELECT prescriber.npi
		,	drug.drug_name
		,	SUM(prescription.total_claim_count) AS sum_total_claims
	FROM prescriber
		CROSS JOIN drug
		LEFT JOIN prescription
			USING (drug_name)
	WHERE prescriber.specialty_description = 'Pain Management'
		AND prescriber.nppes_provider_city = 'NASHVILLE'
		AND drug.opioid_drug_flag = 'Y'
	GROUP BY prescriber.npi
		,	drug.drug_name
	ORDER BY prescriber.npi;
--answer:1154436590	"TYLENOL-CODEINE NO.3"	


--7c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.
SELECT prescriber.npi
		,	drug.drug_name
		,	COALESCE(SUM(prescription.total_claim_count), 0) AS sum_total_claims
	FROM prescriber
		CROSS JOIN drug
		LEFT JOIN prescription
			USING (drug_name)
	WHERE prescriber.specialty_description = 'Pain Management'
		AND prescriber.nppes_provider_city = 'NASHVILLE'
		AND drug.opioid_drug_flag = 'Y'
	GROUP BY prescriber.npi
		,	drug.drug_name
	ORDER BY prescriber.npi;
