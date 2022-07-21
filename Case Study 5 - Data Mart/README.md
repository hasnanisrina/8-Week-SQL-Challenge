# Case Study 5- Data Mart

![5](https://user-images.githubusercontent.com/103159451/180107741-4ea033e0-a3ac-4dd4-9dad-097c80986dfc.png)


The case study available in this [link](https://8weeksqlchallenge.com/case-study-5/) 

## Background
Data Mart is Danny’s latest venture and after running international operations for his online supermarket that specialises in fresh produce - Danny is asking for your support to analyse his sales performance. In June 2020 - large scale supply changes were made at Data Mart. All Data Mart products now use sustainable packaging methods in every single step from the farm all the way to the customer.

## Problem Statemnet
Danny needs your help to quantify the impact of this change on the sales performance for Data Mart and it’s separate business areas.

The key business question he wants you to help him answer are the following:

a. What was the quantifiable impact of the changes introduced in June 2020?

b. Which platform, region, segment and customer types were the most impacted by this change?

c. What can we do about future introduction of similar sustainability updates to the business to minimise impact on sales?

## Entity Relationship Diagram
<img width="188" alt="Capture" src="https://user-images.githubusercontent.com/103159451/180107779-0d666afe-6d6d-4561-90b8-cc7b139df2ce.PNG">

## Case Study Question
**A.Data Cleansing Steps**

In a single query, perform the following operations and generate a new table in the data_mart schema named clean_weekly_sales:

a. Convert the week_date to a DATE format

b. Add a week_number as the second column for each week_date value, for example any value from the 1st of January to 7th of January will be 1, 8th to 14th will be 2 etc

c. Add a month_number with the calendar month for each week_date value as the 3rd column

d. Add a calendar_year column as the 4th column containing either 2018, 2019 or 2020 values

e. Add a new column called age_band after the original segment column using the following mapping on the number inside the segment value

**B. Data Exploration**
1.	What day of the week is used for each week_date value?
2.	What range of week numbers are missing from the dataset?
3.	How many total transactions were there for each year in the dataset?
4.	What is the total sales for each region for each month?
5.	What is the total count of transactions for each platform
6.	What is the percentage of sales for Retail vs Shopify for each month?
7.	What is the percentage of sales by demographic for each year in the dataset?
8.	Which age_band and demographic values contribute the most to Retail sales?
9.	Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?





