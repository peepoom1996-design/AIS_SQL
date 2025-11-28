%sql

select
purchase.*,
profile.*

from
(
SELECT 
subscription_identifier as purchase,
count(subscription_identifier) as count_purchase
FROM digids_temp_db.prusaving_lead_2022_2023
group by subscription_identifier
ORDER BY count_purchase DESC
)purchase

left join

(SELECT
*
FROM `hive_metastore`.`c360_customer_profile`.`l3_customer_profile_union_monthly_feature`
where start_of_month = '2025-10-01' 
) profile

on purchase.purchase = profile.subscription_identifier

----------------------------------------------------------------------------------------

%sql

select 
segment,
count(distinct old_subscription_identifier)
from(

select*
from(
select
*
from
(
SELECT 
subscription_identifier as purchase
FROM digids_temp_db.prusaving_lead_2022_2023
group by subscription_identifier
) purchase

left join

(
select 
old_subscription_identifier,
access_method_num
FROM `hive_metastore`.`c360_customer_profile`.`l3_customer_profile_union_monthly_feature`
where start_of_month = '2025-10-01'
) profile

on purchase.purchase = profile.old_subscription_identifier

where profile.old_subscription_identifier is not null
) purchase_method

left join

(
select
segment,
mobile_no
from digida_common.tbl_ta_investing_result
where partition_month = '202510'
) investing

on purchase_method.access_method_num = investing.mobile_no

where investing.mobile_no is not null

) inv

group by segment
