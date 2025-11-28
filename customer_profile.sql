%sql
SELECT 
gender,
count(distinct subscription_identifier)
FROM `hive_metastore`.`c360_customer_profile`.`l3_customer_profile_union_monthly_feature`
where start_of_month = '2025-10-01'
group by gender

---------------------------------------------------------------------------------------------

%sql
SELECT 
customer_age_range,
count(distinct subscription_identifier)
FROM `hive_metastore`.`c360_customer_profile`.`l3_customer_profile_union_monthly_feature`
where start_of_month = '2025-10-01'
group by customer_age_range

---------------------------------------------------------------------------------------------

%sql
SELECT 
mobile_segment,
count(distinct subscription_identifier)
FROM `hive_metastore`.`c360_customer_profile`.`l3_customer_profile_union_monthly_feature`
where start_of_month = '2025-10-01'
group by mobile_segment

---------------------------------------------------------------------------------------------

%sql
SELECT 
charge_type,
count(distinct subscription_identifier)
FROM `hive_metastore`.`c360_customer_profile`.`l3_customer_profile_union_monthly_feature`
where start_of_month = '2025-10-01'
group by charge_type

---------------------------------------------------------------------------------------------

%sql
SELECT 
province_name,
count(distinct subscription_identifier)
FROM `hive_metastore`.`c360_customer_profile`.`l3_customer_profile_union_monthly_feature`
where start_of_month = '2025-10-01'
group by province_name

---------------------------------------------------------------------------------------------

%sql
SELECT 
count(subscription_identifier),
count(distinct subscription_identifier)
FROM `hive_metastore`.`c360_customer_profile`.`l3_customer_profile_union_monthly_feature`
where start_of_month = '2025-10-01'
