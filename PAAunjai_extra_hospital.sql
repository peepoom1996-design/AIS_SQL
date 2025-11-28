%sql

select *,
CASE WHEN purchase_month_num >= hospital_month_num THEN 'Y' ELSE 'N' END as hospital_flag
from(
select
PA.*,
CAST(date_format(PA.purchase_date, 'yyyyMM') AS INT) AS purchase_month_num,
hospital_users.pattern_segment,
hospital_users.partition_month,
CAST(hospital_users.partition_month AS INT) AS hospital_month_num

from
(
select *
from digide_insurance.add_nonlife_purchase_active
where ddate = '2025-10-31'
and product_type = 'PAAunjai_extra'
--and purchase_date >= '2025-09-01'
) PA


left join

(
select 
mobile_no.mobile_no,
hospital.c360_subscription_identifier,
hospital.pattern_segment,
hospital.partition_month

from(
select 
*
from digida_insurance.advs_da_hospital_users
where partition_month = '202510'
) hospital

left join 

(
select 
access_method_num as mobile_no,
subscription_identifier as c360_subscription_identifier
FROM `hive_metastore`.`c360_customer_profile`.`l3_customer_profile_union_monthly_feature`
where start_of_month = '2025-10-01'
) mobile_no

on hospital.c360_subscription_identifier = mobile_no.c360_subscription_identifier
) hospital_users

on PA.mobile_no = hospital_users.mobile_no
)
