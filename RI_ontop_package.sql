%sql

select
sale_channel,
count(Key_no) as amount

from(

select

ir_package.*,
ontop_package.*
from



(
select 
mobile_no || offering_id || start_package as Key_no,
*
from  digida_temp_db.profile_purchase_packIR_FINAL
where start_package >= '2025-10-01'
and start_package <= '2025-10-31'
--and mobile_no = 'BYqTG9NHzJ8J1bcRUF2CJmKf37SemtK47+d8aJ9qtbps5YpO7hkb8ceKT+QqwOag'
) ir_package

left join

(
select distinct
access_method_num || offering_code || TO_DATE(event_start_dttm, "yyyy-MM-dd'T'HH:mm:ss.SSSXXX") as Key_no_package,
offering_code,
offering_id,
(case when mart_channel is null then cmd_channel_type else mart_channel end) as sale_channel
from c360_sales.l0_sales_drm_t_ontop_package_channel
where partition_date >= '20251001'
and partition_date <= '20251031'
--and access_method_num = 'BYqTG9NHzJ8J1bcRUF2CJmKf37SemtK47+d8aJ9qtbps5YpO7hkb8ceKT+QqwOag'
) ontop_package


on ir_package.Key_no = ontop_package.Key_no_package
)
group by sale_channel
order by amount desc
