
--saving model
--Investing Segment   Ex CG ของกาฟูก
--Big Family Ex CG ของกาฟูก
--Digital Persona   Ex CG ของกาฟูก

--------------------------------------------------------------------------------------------------------

%sql
drop table if exists tle_profile;
create temp view tle_profile
as
(
SELECT *
FROM
(
select row_number() over (partition by crm_sub_id  order by register_date,access_method_num ) as row_id
,access_method_num,card_no,register_date,crm_sub_id,c360_subscription_identifier,charge_type
,(CASE  WHEN coalesce(age,0) between 1 and 20 THEN '1-20'
        WHEN coalesce(age,0) between 21 and 30 THEN '21-30'
        WHEN coalesce(age,0) between 31 and 40 THEN '31-40'
        WHEN coalesce(age,0) between 41 and 50 THEN '41-50'
        WHEN coalesce(age,0) between 51 and 60 THEN '51-60'
        WHEN coalesce(age,0) between 61 and 90 THEN '> 60'
        ELSE 'Unknown'
END) as age_range
,gender
,(CASE  WHEN crm_most_usage_province in ('BANGKOK','NAKHON PATHOM','NONTHABURI','PATHUM THANI','SAMUT PRAKAN',  
        'SAMUT SAKHON') THEN 'BKK&Metropolitan'
        WHEN crm_most_usage_province in ('CHIANG MAI','CHANTHABURI','CHIANG RAI','CHON BURI','KANCHANABURI','KHON KAEN','LAMPANG','NAKHON RATCHASIMA','NAKHON SAWAN','PHITSANULOK','RAYONG','UBON RATCHATHANI','UDON THANI') THEN 'Provincial cities' --'SONGKHLA','KRABI','NAKHON SI THAMMARAT','PHUKET','SURAT THANI'
        WHEN coalesce(crm_most_usage_province,'') = '' THEN 'Unknown'
        ELSE 'Other Province'
END) as most_province_flag
,(CASE  WHEN service_month between 1 and 6 THEN '1-6M'
        WHEN service_month between 7 and 12 THEN '7-12M'
        WHEN service_month between 13 and 36 THEN '13-36M'
        WHEN service_month between 37 and 60 THEN '37-60M'
        WHEN service_month > 60 THEN '>60M'
END) as service_month_range,mobile_segment
from c360_customer_profile.l0_profile_drm_t_active_profile_customer_journey
where partition_month = '202510'
and mobile_status in ('Active','SA')
and crm_sub_id is not null
)AA
WHERE row_id = 1
)

--------------------------------------------------------------------------------------------------------

%sql
drop table if exists tle_myAIS_last3M;
create temp view tle_myAIS_last3M
as
(
SELECT AA.c360_subscription_identifier,'Y' my_active_flag
FROM
(
select c360_subscription_identifier,avg(no_of_trans) as avg_no_of_trans
from  c360_touchpoints.l0_touchpoints_myais_distinct_sub_monthly
where partition_month in ('202508','202509','202510')
and channel = 'myAIS'
group by 1
)as AA
WHERE avg_no_of_trans >= 1
GROUP BY 1
);

--------------------------------------------------------------------------------------------------------

%sql
drop table if exists tle_Profile_join_myAIS_jan25;
create temp view tle_Profile_join_myAIS_jan25
as
(
select A.*
from tle_profile as A
,tle_myAIS_last3M as B
where A.c360_subscription_identifier = B.c360_subscription_identifier
)

--------------------------------------------------------------------------------------------------------

%sql
select count(*),count(distinct crm_sub_id) 
from tle_Profile_join_myAIS_jan25

--------------------------------------------------------------------------------------------------------

--เงื่อนไข
  
--------------------------------------------------------------------------------------------------------
  
%sql
-- Saving Model
drop table if exists tle_saving_model;
create temp view tle_saving_model
as
(
select access_method_num,flag_group from digids_insurance.pru_saving_contact_lead
where flag_group = 'treatment'
group by 1,2
)

--------------------------------------------------------------------------------------------------------
  
%sql
select count(*),count(distinct access_method_num)
from tle_saving_model

--------------------------------------------------------------------------------------------------------

%sql
-- investing segment
drop table if exists tle_investing_segment;
create temp view tle_investing_segment
as
(
select mobile_no access_method_num,pattern_segment
from digida_common.tbl_wisanu_investor_segment_K_complete
where Predict_month = '2025-10-01'
and pattern_segment in ('gold lover','stock and mutualfund interest','fundamental investor','mutualfund lover')
and mobile_no not in (select access_method_num from digids_insurance.pru_saving_contact_lead)
group by 1,2
)

--------------------------------------------------------------------------------------------------------

%sql
select count(*),count(distinct access_method_num)
from tle_investing_segment

--------------------------------------------------------------------------------------------------------

%sql
--big family
drop table if exists tle_big_family;
create temp view tle_big_family
as
(
Select *
From
(
select row_number() over (partition by service_mobile_crm_sub_id  order by part_bigfamily_score) as row_id,B.service_mobile_crm_sub_id,round(A.part_bigfamily_score,2) as part_bigfamily_score
from c360s_miscellaneous.fbb_customer_big_family_monthly A
,c360_customer_profile.l0_profile_fbb_t_active_sub_summary_detail B
where A.c360_subscription_identifier = B.c360_subscription_identifier
and A.partition_month = '2025-09-01'
and B.partition_date = '20251124'
)AA
Where row_id = 1
And service_mobile_crm_sub_id is not null
And service_mobile_crm_sub_id not in (select old_subscription_identifier from digids_insurance.pru_saving_contact_lead)
)

--------------------------------------------------------------------------------------------------------

%sql
select count(*),count(distinct service_mobile_crm_sub_id)
from tle_big_family

--------------------------------------------------------------------------------------------------------

%sql
-- persona & demo
drop table if exists tle_persona_demo;
create temp view tle_persona_demo
as
(
select A.mobile_no as access_method_num, A.9cluster_name
from digids_common.dmn_digital_persona_cluster as A
,tle_profile as B
where A.mobile_no = B.access_method_num
and A.partition_month = '202510'
and A.9cluster_name in ('Travel & Finance User','Power Users')
and B.gender = 'F'
and B.most_province_flag in ('BKK&Metropolitan','Provincial cities')
and B.age_range in ('31-40','41-50','51-60','> 60')
and B.charge_type = 'Post-paid'
and B.mobile_segment in ('Classic','Gold','Emerald')
and mobile_no not in (select access_method_num from digids_insurance.pru_saving_contact_lead)
)

--------------------------------------------------------------------------------------------------------

%sql
select count(*),count(distinct access_method_num)
from tle_persona_demo

--------------------------------------------------------------------------------------------------------

%sql
drop table if exists digida_common.tle_profile_sampling_saving_Dec25_final;
create table digida_common.tle_profile_sampling_saving_Dec25_final
as
(
SELECT YYY.*
FROM
(SELECT row_number() over (partition by AAA.crm_sub_id  order by AAA.9cluster_name ) as row_id
,AAA.access_method_num,	AAA.card_no,	AAA.register_date,	AAA.crm_sub_id,	AAA.c360_subscription_identifier,	AAA.charge_type,	AAA.age_range,	AAA.gender,	AAA.most_province_flag,	AAA.service_month_range,	AAA.flag_group as model_group,	AAA.pattern_segment as investing_segment,	AAA.part_bigfamily_score as big_family_score,AAA.9cluster_name as finance_demo,	AAA.group_campaign
FROM
(
SELECT XX.*,
(CASE WHEN XX.flag_group is not null THEN 'saving_model_Dec25'
      WHEN XX.pattern_segment is not null THEN 'saving_investor_Dec25' 
      WHEN XX.part_bigfamily_score is not null THEN 'saving_bigFamily_Dec25'
      WHEN XX.9cluster_name is not null THEN 'saving_persona_demo_Dec25' 
     ELSE 'NONE' END) as group_campaign
FROM
(
select A.*,B.flag_group,C.pattern_segment,D.part_bigfamily_score,E.9cluster_name
from tle_Profile_join_myAIS_jan25 as A

left outer join tle_saving_model as B
on A.access_method_num = B.access_method_num

left outer join tle_investing_segment as C  
on A.access_method_num = C.access_method_num

left outer join tle_big_family as D  
on A.crm_sub_id = D.service_mobile_crm_sub_id

left outer join tle_persona_demo as E  
on A.access_method_num = E.access_method_num
)XX
WHERE XX.flag_group is not null 
OR XX.pattern_segment is not null
OR XX.part_bigfamily_score is not null
OR XX.9cluster_name is not null
)AAA
--WHERE AAA.crm_sub_id not in ('8a7bb50a99c4faa00199c88799705958')
)YYY
WHERE YYY.row_id = 1
)

--------------------------------------------------------------------------------------------------------

%sql
select count(*),count(distinct crm_sub_id)
from digida_common.tle_profile_sampling_saving_Dec25_final

--------------------------------------------------------------------------------------------------------

%sql
select group_campaign,count(*),count(distinct crm_sub_id)
from digida_common.tle_profile_sampling_saving_Dec25_final
group by 1

--------------------------------------------------------------------------------------------------------

--deploy paid media

--------------------------------------------------------------------------------------------------------

%sql
INSERT INTO digida_common.tle_insurance_paidmedia_campaignYDM_Q42025
select c360_subscription_identifier as subscription_identifier
,'Paid Media Campaign(YDM Q42025)' as project_name
,(Case  When group_campaign = 'saving_model_Dec25' Then 'G47'
        When group_campaign = 'saving_investor_Dec25' Then 'G48'
        When group_campaign = 'saving_bigFamily_Dec25' Then 'G49' 
        When group_campaign = 'saving_persona_demo_Dec25' Then 'G50' End) as group_no
,group_campaign
,current_date
from digida_common.tle_profile_sampling_saving_Dec25_final

--------------------------------------------------------------------------------------------------------

%sql
select group_no,campaign_name,count(*)
from digida_common.tle_insurance_paidmedia_campaignYDM_Q42025
where group_no in ('G47','G48','G49','G50')
GROUP BY 1,2
order by 1
