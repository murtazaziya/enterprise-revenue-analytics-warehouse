CREATE OR ALTER PROCEDURE dw.sp_upsert_dim_project
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH src_raw AS (
        SELECT
            p.*,
            ROW_NUMBER() OVER (PARTITION BY p.project_id ORDER BY (SELECT NULL)) AS rn
        FROM stg.dim_project p
        WHERE p.project_id IS NOT NULL
    ),
    src AS (
        SELECT
            r.project_id,
            r.project_name,
            COALESCE(c.client_key, 0) AS client_key,
            COALESCE(b.bu_key, 0) AS bu_key,
            COALESCE(reg.region_key, 0) AS region_key,
            COALESCE(pm.pm_key, 0) AS pm_key,
            r.billing_model,
            TRY_CAST(r.start_date AS DATE) AS start_date,
            TRY_CAST(r.end_date AS DATE) AS end_date,
            TRY_CAST(r.bill_rate_usd_per_hr AS DECIMAL(18,2)) AS bill_rate,
            TRY_CAST(r.fixed_fee_total_usd AS DECIMAL(18,2)) AS fixed_fee_total,
            r.status
        FROM src_raw r
        LEFT JOIN dw.dim_client c         ON r.client_id = c.client_id
        LEFT JOIN dw.dim_business_unit b  ON r.bu_id = b.bu_id
        LEFT JOIN dw.dim_region reg       ON r.region_id = reg.region_id
        LEFT JOIN dw.dim_project_manager pm ON r.pm_id = pm.pm_id
        WHERE r.rn = 1
    )
    MERGE dw.dim_project AS tgt
    USING src
      ON tgt.project_id = src.project_id
    WHEN MATCHED AND (
        ISNULL(tgt.project_name,'') <> ISNULL(src.project_name,'')
        OR ISNULL(tgt.client_key,0) <> ISNULL(src.client_key,0)
        OR ISNULL(tgt.bu_key,0) <> ISNULL(src.bu_key,0)
        OR ISNULL(tgt.region_key,0) <> ISNULL(src.region_key,0)
        OR ISNULL(tgt.pm_key,0) <> ISNULL(src.pm_key,0)
        OR ISNULL(tgt.billing_model,'') <> ISNULL(src.billing_model,'')
        OR ISNULL(tgt.start_date,'1900-01-01') <> ISNULL(src.start_date,'1900-01-01')
        OR ISNULL(tgt.end_date,'1900-01-01') <> ISNULL(src.end_date,'1900-01-01')
        OR ISNULL(tgt.bill_rate,0) <> ISNULL(src.bill_rate,0)
        OR ISNULL(tgt.fixed_fee_total,0) <> ISNULL(src.fixed_fee_total,0)
        OR ISNULL(tgt.status,'') <> ISNULL(src.status,'')
    )
        THEN UPDATE SET
            project_name = src.project_name,
            client_key = src.client_key,
            bu_key = src.bu_key,
            region_key = src.region_key,
            pm_key = src.pm_key,
            billing_model = src.billing_model,
            start_date = src.start_date,
            end_date = src.end_date,
            bill_rate = src.bill_rate,
            fixed_fee_total = src.fixed_fee_total,
            status = src.status
    WHEN NOT MATCHED BY TARGET
        THEN INSERT (
            project_id, project_name, client_key, bu_key, region_key, pm_key,
            billing_model, start_date, end_date, bill_rate, fixed_fee_total, status
        )
        VALUES (
            src.project_id, src.project_name, src.client_key, src.bu_key, src.region_key, src.pm_key,
            src.billing_model, src.start_date, src.end_date, src.bill_rate, src.fixed_fee_total, src.status
        );
END;
GO