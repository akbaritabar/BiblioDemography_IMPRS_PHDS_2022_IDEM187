CREATE VIEW ORCID AS SELECT * FROM parquet_scan('..\98_outputs\*.parquet');
-- IF it gives error in reading parquet file, give the full directory URL, e.g.,
--CREATE VIEW ORCID AS SELECT * FROM parquet_scan('U:\nc\w\mpidr\biblio_data_for_demogr\workshop_course\2022_PHDS_DCD\materials\BiblioDemography_IMPRS_PHDS_2022_IDEM187\98_outputs\*.parquet');

-- this gives the first 100 rows of the table
SELECT * from orcid limit 100;

-- count all rows
SELECT count(*) from orcid;

-- this gives a table with multiple columns
-- count of all rows (including duplicates)
-- count of distinct ORCID IDs
-- count of distinct first names
-- count of distinct last names
SELECT count(*), count(DISTINCT orcid_id), COUNT(DISTINCT first_name), COUNT(DISTINCT last_name) from main.orcid;

