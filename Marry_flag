%sql

select count(*)
from(

select distinct
subscription_identifier,
CASE 
    WHEN kid_features_flag = 'Y'  or big_family_flag = 'Y' THEN 'Y'
    ELSE 'N'
END AS Marry_flag
from(

SELECT distinct
prusaving.subscription_identifier,
CASE 
    WHEN family.subscription_identifier IS NULL THEN 'N'
    ELSE 'Y'
END AS kid_features_flag,
big_family.big_family_flag

FROM digids_temp_db.prusaving_lead_2022_2023 prusaving

left JOIN

(select 
distinct subscription_identifier
from digide_common.family_with_kid_features
) family

on prusaving.subscription_identifier = family.subscription_identifier

left JOIN

(
SELECT DISTINCT
sv.subscription_identifier,
--subfbb.c360_subscription_identifier,
CASE 
    WHEN fm.c360_subscription_identifier IS NULL THEN 'N'
    ELSE 'Y'
END AS big_family_flag 

FROM digids_temp_db.prusaving_lead_2022_2023 sv

left JOIN 

(select 
service_mobile_crm_sub_id,
c360_subscription_identifier
from c360_customer_profile.l0_profile_fbb_t_active_sub_summary_detail
where partition_date = '20251122') subfbb

on sv.subscription_identifier = subfbb.service_mobile_crm_sub_id

left JOIN
(
select
c360_subscription_identifier
from c360s_miscellaneous.fbb_customer_big_family_monthly
where partition_month = '2025-09-01'
) fm

on subfbb.c360_subscription_identifier = fm.c360_subscription_identifier
)big_family

on prusaving.subscription_identifier = big_family.subscription_identifier
)Marry_flag
)
where Marry_flag = 'Y'
