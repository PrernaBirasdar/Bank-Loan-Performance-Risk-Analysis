USE bank_loan_db ; 


CREATE TABLE bank_loan (
id INT,
address_state VARCHAR(10),
application_type VARCHAR(50),
emp_length VARCHAR(20),
emp_title TEXT,
grade VARCHAR(5),
home_ownership VARCHAR(20),

issue_date VARCHAR(20),
last_credit_pull_date VARCHAR(20),
last_payment_date VARCHAR(20),

loan_status VARCHAR(50),
next_payment_date VARCHAR(20),

member_id BIGINT,
purpose VARCHAR(50),
sub_grade VARCHAR(10),
term VARCHAR(20),
verification_status VARCHAR(50),

annual_income DOUBLE,
dti DOUBLE,
installment DOUBLE,
int_rate DOUBLE,

loan_amount INT,
total_acc INT,
total_payment DOUBLE
);

SELECT * FROM bank_loan ; 


LOAD DATA LOCAL INFILE
'D:\Analytics Internship\SQL + PowerBI/Bank_Loan.csv'
INTO TABLE bank_loan
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

###################### KPI's : ###########################

# 1  Total Loan Applications

SELECT COUNT(id) AS Total_Applications FROM bank_loan 
WHERE MONTH(issue_date) = 12 AND YEAR(issue_date) = 2021 ; 

# Convert 'issue_date' permanently to DATE:

ALTER TABLE bank_loan 
ADD issue_date_new DATE; 

UPDATE bank_loan
SET issue_date_new = STR_TO_DATE(issue_date,'%d-%m-%Y');


SELECT COUNT(id) AS Total_Applications
FROM bank_loan
WHERE MONTH(issue_date_new) = 12
AND YEAR(issue_date_new) = 2021; 

# CHEK IF THEY MATCH WITH OLD COLUMN 
SELECT issue_date, issue_date_new
FROM bank_loan
LIMIT 20;

# CHECK IF ANY NULL
SELECT COUNT(*)
FROM bank_loan
WHERE issue_date_new IS NULL;

# CHECK IF ANY NULL
SELECT COUNT(*)
FROM bank_loan
WHERE issue_date IS NULL;

# DROP OLD DATE COLUMN 
ALTER TABLE bank_loan DROP COLUMN issue_date ; 

# RENAME NEW ISHHUE DATE COLUMN 
ALTER TABLE bank_loan 
RENAME COLUMN  issue_date_new TO issue_date ; 

SELECT * FROM bank_loan ; 


# 1 1.	Total Loan Applications - MONTH TO DATE 
SELECT COUNT(id) AS MTD_Total_Application FROM bank_loan 
WHERE MONTH(issue_date) = 12 AND YEAR(issue_date) = 2021 ; 

# TOTAL APPLICATION BY EACH MONTH 
SELECT 
YEAR(issue_date) AS Year,
MONTH(issue_date) AS Month,
COUNT(*) AS Applications
FROM bank_loan
GROUP BY Year, Month
ORDER BY Year, Month; 

# PRIVIOUS MONTH TO DATE LOAN APPLICATIONS 
SELECT COUNT(id) AS PMTD_TOTAL_APPLICATION FROM bank_loan
WHERE MONTH(issue_date) = 11 AND YEAR(issue_date) = 2021 ; 

# HOW TO CALCULATE MONTH ON MONTH APPLICATION - MOM 
-- (MTD-PMTD)/PMTD 

# 2 Total Funded Amount - TOTAL LOAN AMT THAT IS GIVEN TO THE APPLICANTS BY BANK 
SELECT SUM(loan_amount) AS Total_Funded_Amt FROM bank_loan ; 

# MOM CHANGES : 
-- MTD 
SELECT SUM(loan_amount) AS MTD_Total_Funded_Amt FROM bank_loan 
WHERE MONTH(issue_date) = 12 AND YEAR(issue_date) = 2021 ; 
-- PMTD 
SELECT SUM(loan_amount) AS PMTD_Total_Funded_Amt FROM bank_loan
WHERE MONTH(issue_date) = 11 AND YEAR(issue_date) = 2021 ;

# 3 3.	Total Amount Received - FROM BORROWERS 
SELECT SUM(total_payment) AS Total_Amt_Rec FROM bank_loan ; 

# MOM CHANGES 
-- MTD 
SELECT SUM(total_payment) AS MTD_Total_Amt_Rec FROM bank_loan
WHERE MONTH(issue_date) = 12 AND YEAR(issue_date) = 2021 ; 
-- PMTD 
SELECT SUM(total_payment) AS PMTD_Total_Amt_Rec FROM bank_loan
WHERE MONTH(issue_date) = 11 AND YEAR(issue_date) = 2021 ;

# 4.   Average Interest Rate - 
SELECT SUM(int_rate) FROM bank_loan ; 

# AVG : 
SELECT AVG(int_rate) AS Avg_interest_rate FROM bank_loan ; 
-- CONVERT INTO % 
SELECT ROUND(AVG(int_rate)* 100, 2) AS Avg_interest_rate FROM bank_loan ; 

# MOM CHANGES
-- MTD AVG
SELECT ROUND(AVG(int_rate)*100,2) AS MTD_Avg_interest_rate FROM bank_loan 
WHERE MONTH(issue_date) = 12 AND YEAR(issue_date) = 2021 ; 
-- PMTD 
SELECT ROUND(AVG(int_rate)*100,2) AS PMTD_Avg_interest_rate FROM bank_loan
WHERE MONTH(issue_date) = 11 AND YEAR(issue_date) = 2021 ; 
 
# 5.  Average Debt-to-Income Ratio (DTI)
SELECT ROUND(AVG(dti) * 100,2) AS AVG_DTI FROM bank_loan ;

# MOM CHANGES 
-- MTD 
SELECT ROUND(AVG(dti) * 100,2) AS MTD_AVG_DTI FROM bank_loan
WHERE MONTH(issue_date) = 12 AND YEAR(issue_date) = 2021 ;  

SELECT ROUND(AVG(dti)*100,2) AS PMTD_AVG_DTI FROM bank_loan
WHERE MONTH(issue_date) = 11 AND YEAR(issue_date) = 2021 ; 

####### GOOD LOAN VS BAD LOAN ############

# GOOD LOAN KPI
# 1. GOOD LOAN APPLICATIONS IN PERCENTAGE 
SELECT 
	  (COUNT(CASE WHEN loan_status = 'Fully Paid' OR loan_status = 'Current' THEN ID END) * 100)
      /
      COUNT(id) AS Good_loan_Percentage
      FROM bank_loan ; 
      
# 2. GOOD LOAN APPLICATIONS 
SELECT COUNT(id) AS Good_loan_Apllications FROM bank_loan
WHERE loan_status = 'Fully Paid' OR loan_status = 'Current' ; 

# 3. Good Loan Funded Amount MEANS THIS MUCH MONEY BANK GAVE TO THE GOOD PEOPLE THAT THEY PAID THE LOAN AMT OR PAYING BACK 
SELECT SUM(loan_amount) AS Good_Loan_Funded_Amt FROM bank_loan
WHERE loan_status = 'Fully Paid' OR loan_status = 'Current' ; 

# 4. Good Loan Total Received Amount: 
SELECT SUM(total_payment) AS Good_Loan_Total_Rece_Amt FROM bank_loan
WHERE loan_status = 'Fully Paid' OR loan_status = 'Current' ;  

SELECT * FROM bank_loan ; 

# Bad Loan KPIs:
# 1. Bad Loan Application Percentage: 
SELECT
	  (COUNT(CASE WHEN loan_status = 'Charged Off' THEN ID END) * 100)
      /
      COUNT(id) AS Bad_Loan_Application_Perce
      FROM bank_loan ; 
      
# 2.  Bad Loan Applications:
SELECT COUNT(id) FROM bank_loan WHERE loan_status = 'Charged Off' ; 

# 3. Bad Loan Funded Amount:
SELECT SUM(loan_amount) AS Bad_loan_Funded_Amt FROM bank_loan WHERE loan_status = 'Charged Off' ; 
      
# 4.  Bad Loan Total Received Amount
SELECT SUM(total_payment) AS Bad_Loan_Total_Rec_Amt FROM bank_loan WHERE loan_status = 'Charged Off' ; 

########### Loan Status Grid View ###########
SELECT
     loan_status,
     COUNT(id) Total_apllications,
     SUM(total_payment) AS Total_amt_rece,
     SUM(loan_amount) AS Total_funded_amt,
     AVG(int_rate * 100) AS Interest_rate,
     AVG(dti * 100) AS DTI
FROM bank_loan 
GROUP BY loan_status ; 

# DIFFERENCE BETWEEN TOTAL AMT FUNDED IN 12 MONTH AND TOTAL AMT RECEIVED IN 2021 

SELECT 
      loan_status,
      SUM(loan_amount) AS MTD_Total_funded,
      SUM(total_payment) AS MTD_Total_amt_rece
FROM bank_loan
WHERE MONTH(issue_date) = 12 AND YEAR(issue_date) = 2021 
GROUP BY loan_status ; 


# 2ND DASHBOARD QUERIES 

-- 1. Monthly Trends by Issue Date (Line Chart):

SELECT
      MONTH(issue_date) AS Month_Numb,
      MONTHNAME(issue_date) AS Month_Name,
      COUNT(id) AS Total_Loan_applications,
      SUM(loan_amount) AS Total_funded_amt,
      SUM(total_payment) AS Total_received_amt
FROM bank_loan 
GROUP BY  MONTH(issue_date), MONTHNAME(issue_date) 
ORDER BY MONTH(issue_date)  ; 

-- 2. Regional Analysis by State (Filled Map):

SELECT 
      address_state,
      COUNT(id) AS 	Total_Loan_Applications,
      SUM(loan_amount) AS Total_funded_amt,
      SUM(total_payment) AS Total_received_amt
FROM bank_loan
GROUP BY address_state 
ORDER BY address_state ; 

-- 3. Loan Term Analysis (Donut Chart):

SELECT 
     term, 
     COUNT(id) AS Total_loan_Application, 
     SUM(loan_amount) AS Total_funded_amt,
     SUM(total_payment) AS Total_received_amt
FROM bank_loan
GROUP BY term
ORDER BY term ; 

-- 4. Employee Length Analysis (Bar Chart):

SELECT
      emp_length,
      COUNT(id) AS Total_Lona_Applications,
      SUM(loan_amount) AS Total_funded_amt,
	  SUM(total_payment) AS Total_received_amt
FROM bank_loan
GROUP BY emp_length
ORDER BY COUNT(id) DESC ; 

-- 5. Loan Purpose Breakdown (Bar Chart):

SELECT
      purpose,
      COUNT(id) AS Total_Lona_Applications,
      SUM(loan_amount) AS Total_funded_amt,
	  SUM(total_payment) AS Total_received_amt
FROM bank_loan
GROUP BY purpose
ORDER BY COUNT(id) DESC  ; 

-- 6. Home Ownership Analysis (Tree Map):

SELECT
      home_ownership,
      COUNT(id) AS Total_Lona_Applications,
      SUM(loan_amount) AS Total_funded_amt,
	  SUM(total_payment) AS Total_received_amt
FROM bank_loan
GROUP BY home_ownership
ORDER BY COUNT(id) DESC  ;

