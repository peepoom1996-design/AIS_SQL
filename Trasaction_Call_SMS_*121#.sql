%sql

drop table if exists trn_calls_history;
create temp view trn_calls_history
as(

SELECT
mobile_no,
substring(partition_date, 1, 6) AS partition_month,
sum(no_of_call) as total_call,
COUNT(DISTINCT partition_date) AS total_days
FROM c360_usage.l0_usage_other_calls_history_ussd
WHERE left(partition_date, 6) IN ('202511','202510')
--AND mobile_no = 'Nk4UDYwOcauqwKe2ZloWO4uB+ABxtEt0r3m1VZhLXfVJ+zkapzPC7Dd9hwqEzkQH'
AND call_b_no = '*121#'
GROUP BY mobile_no, substring(partition_date, 1, 6)

)

----------------------------------------------------------------------------------------------------------

%sql
drop table if exists trn_calls_history_profile_journey;
create temp view trn_calls_history_profile_journey
as(


select
calls_history.mobile_no,
profile_journey.c360_subscription_identifier, 
calls_history.partition_month,
calls_history.total_call,
calls_history.total_days,
profile_journey.customer_type,
profile_journey.network_type,
profile_journey.charge_type
from trn_calls_history calls_history

left join

(
select 
customer_type,
network_type,
charge_type,
access_method_num,
c360_subscription_identifier
from digida_internal_financial.tbl_sern_profile_journey_m102025
) profile_journey

on calls_history.mobile_no = profile_journey.access_method_num

)

----------------------------------------------------------------------------------------------------------

%sql
select
count(mobile_no),
count(distinct mobile_no)
from trn_calls_history_profile_journey

----------------------------------------------------------------------------------------------------------

%sql
select
count(mobile_no),
count(distinct mobile_no)
from trn_calls_history_profile_journey
where c360_subscription_identifier is null;

----------------------------------------------------------------------------------------------------------

%sql
select
*
from trn_calls_history_profile_journey
where c360_subscription_identifier is null;

----------------------------------------------------------------------------------------------------------

%sql
drop table if exists digida_common.trn_calls_history_profile_journey;
create table digida_common.trn_calls_history_profile_journey
as
(
select
calls_history.mobile_no,
profile_journey.c360_subscription_identifier, 
calls_history.partition_month,
calls_history.total_call,
calls_history.total_days,
profile_journey.customer_type,
profile_journey.network_type,
profile_journey.charge_type
from trn_calls_history calls_history

left join

(
select 
customer_type,
network_type,
charge_type,
access_method_num,
c360_subscription_identifier
from digida_internal_financial.tbl_sern_profile_journey_m102025
) profile_journey

on calls_history.mobile_no = profile_journey.access_method_num
)

----------------------------------------------------------------------------------------------------------

%sql
select*
from digida_common.trn_calls_history_profile_journey


