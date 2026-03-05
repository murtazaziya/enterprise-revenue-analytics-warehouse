CREATE OR ALTER PROCEDURE dw.sp_upsert_dim_client
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH src_raw AS (
        SELECT
            c.*,
            ROW_NUMBER() OVER (PARTITION BY c.client_id ORDER BY (SELECT NULL)) AS rn
        FROM stg.dim_client c
        WHERE c.client_id IS NOT NULL
    ),
    src AS (
        SELECT
            r.client_id,
            r.client_name,
            r.industry,
            r.client_tier,
            COALESCE(reg.region_key, 0) AS hq_region_key
        FROM src_raw r
        LEFT JOIN dw.dim_region reg
          ON r.hq_region_id = reg.region_id
        WHERE r.rn = 1
    )
    MERGE dw.dim_client AS tgt
    USING src
      ON tgt.client_id = src.client_id
    WHEN MATCHED AND (
        ISNULL(tgt.client_name,'') <> ISNULL(src.client_name,'')
        OR ISNULL(tgt.industry,'') <> ISNULL(src.industry,'')
        OR ISNULL(tgt.client_tier,'') <> ISNULL(src.client_tier,'')
        OR ISNULL(tgt.hq_region_key,0) <> ISNULL(src.hq_region_key,0)
    )
        THEN UPDATE SET
            client_name = src.client_name,
            industry = src.industry,
            client_tier = src.client_tier,
            hq_region_key = src.hq_region_key
    WHEN NOT MATCHED BY TARGET
        THEN INSERT (client_id, client_name, industry, client_tier, hq_region_key)
             VALUES (src.client_id, src.client_name, src.industry, src.client_tier, src.hq_region_key);
END;
GO