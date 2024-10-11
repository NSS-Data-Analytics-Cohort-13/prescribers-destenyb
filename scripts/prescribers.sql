-- 1a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.
SELECT scribe.npi, total_claim_count
FROM prescriber AS scribe
FULL JOIN prescription AS script
ON scribe.npi = script.npi
WHERE total_claim_count IS NOT NULL
ORDER BY script.total_claim_count DESC
-- answer: npi= 1912011792

--1b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.

SELECT nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, total_claim_count
FROM prescriber AS scribe
FULL JOIN prescription AS script
ON scribe.npi = script.npi
WHERE total_claim_count IS NOT NULL
ORDER BY script.total_claim_count DESC
-- answer: DAVID, COFFEY, Family Practice, 4538

--2a. Which specialty had the most total number of claims (totaled over all drugs)?
SELECT scribe.specialty_description, sum(total_claim_count) AS claim_count
FROM prescriber AS scribe
FULL JOIN prescription AS script
ON scribe.npi = script.npi
WHERE total_claim_count IS NOT NULL
GROUP BY scribe.specialty_description 
ORDER BY claim_count DESC
-- answer: Family Practice, 351084492

--2b. Which specialty had the most total number of claims for opioids?








