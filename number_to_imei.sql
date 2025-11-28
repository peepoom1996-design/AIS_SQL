%sql
select *
from c360_customer_profile.l0_profile_drm_t_active_profile_customer_journey
where partition_month = '202510' and imei = '35235550516442'
