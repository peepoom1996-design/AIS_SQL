%sql
select
segment
from digida_common.tbl_ta_investing_result
where partition_month = '202510'
group by segment

-------------------------------------------------------------------------------------------------

%sql
select
--segment,
count(mobile_no),
count(distinct mobile_no)
from digida_common.tbl_ta_investing_result
where partition_month = '202510'
group by segment

-------------------------------------------------------------------------------------------------

%sql


select
investing.segment,
investing.mobile_no,
profile.*
from
(
select *
FROM `hive_metastore`.`c360_customer_profile`.`l3_customer_profile_union_monthly_feature`
where start_of_month = '2025-10-01'
) profile

left join

(
select
segment,
mobile_no
from digida_common.tbl_ta_investing_result
where partition_month = '202510'
) investing

on profile.access_method_num = investing.mobile_no

where investing.mobile_no is not null

-------------------------------------------------------------------------------------------------

%sql

SELECT 
segment,
count(distinct subscription_identifier)

from(

select
investing.segment,
investing.mobile_no,
profile.*
from
(
select *
FROM `hive_metastore`.`c360_customer_profile`.`l3_customer_profile_union_monthly_feature`
where start_of_month = '2025-10-01'
) profile

left join

(
select
segment,
mobile_no
from digida_common.tbl_ta_investing_result
where partition_month = '202510'
) investing

on profile.access_method_num = investing.mobile_no

where investing.mobile_no is not null

) inv

group by segment

-------------------------------------------------------------------------------------------------

%sql

SELECT 
gender,
count(distinct subscription_identifier)

from(

select
investing.segment,
investing.mobile_no,
profile.*
from
(
select *
FROM `hive_metastore`.`c360_customer_profile`.`l3_customer_profile_union_monthly_feature`
where start_of_month = '2025-10-01'
) profile

left join

(
select
segment,
mobile_no
from digida_common.tbl_ta_investing_result
where partition_month = '202510'
) investing

on profile.access_method_num = investing.mobile_no

where investing.mobile_no is not null

) inv

group by gender
