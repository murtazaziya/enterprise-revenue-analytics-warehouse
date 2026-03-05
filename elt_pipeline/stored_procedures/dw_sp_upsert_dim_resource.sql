CREATE OR ALTER PROCEDURE dw.sp_upsert_dim_resource
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH src_raw AS (
        SELECT
            r.*,
            ROW_NUMBER() OVER (PARTITION BY r.resource_id ORDER BY (SELECT NULL)) AS rn
        FROM stg.dim_resource r
        WHERE r.resource_id IS NOT NULL
    ),
    src AS (
        SELECT
            resource_id,
            resource_name,
            role,
            TRY_CAST(cost_rate_usd_per_hr AS DECIMAL(18,2)) AS cost_rate,
            TRY_CAST(default_bill_rate_usd_per_hr AS DECIMAL(18,2)) AS bill_rate,
            TRY_CAST(active_flag AS BIT) AS active_flag
        FROM src_raw
        WHERE rn = 1
    )
    MERGE dw.dim_resource AS tgt
    USING src
      ON tgt.resource_id = src.resource_id
    WHEN MATCHED AND (
        ISNULL(tgt.resource_name,'') <> ISNULL(src.resource_name,'')
        OR ISNULL(tgt.role,'') <> ISNULL(src.role,'')
        OR ISNULL(tgt.cost_rate,0) <> ISNULL(src.cost_rate,0)
        OR ISNULL(tgt.bill_rate,0) <> ISNULL(src.bill_rate,0)
        OR ISNULL(tgt.active_flag,0) <> ISNULL(src.active_flag,0)
    )
        THEN UPDATE SET
            resource_name = src.resource_name,
            role = src.role,
            cost_rate = src.cost_rate,
            bill_rate = src.bill_rate,
            active_flag = src.active_flag
    WHEN NOT MATCHED BY TARGET
        THEN INSERT (resource_id, resource_name, role, cost_rate, bill_rate, active_flag)
             VALUES (src.resource_id, src.resource_name, src.role, src.cost_rate, src.bill_rate, src.active_flag);
END;
GO