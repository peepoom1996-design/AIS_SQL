%sql
CREATE TABLE digida_internal_common.purchase_insurance AS

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

on purchase.purchase = profile.old_subscription_identifier

---------------------------------------------------------------------------------------------------------------------


df = spark.sql("""

select
*
from digida_internal_common.purchase_insurance

""")
 
pdf = df.toPandas()


---------------------------------------------------------------------------------------------------------------------


# เซฟไฟล์ลง DBFS
pdf.to_csv("/dbfs/FileStore/purchase_insurance.csv", index=False)

# แสดงลิงก์ให้ดาวน์โหลด
displayHTML(f"<a href='/files/purchase_insurance.csv' download>📥 Download CSV</a>")
