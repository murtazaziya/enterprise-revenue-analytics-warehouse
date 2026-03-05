CREATE OR ALTER PROCEDURE dw.sp_upsert_dim_region
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH src AS (
        SELECT region_id, region_name
        FROM (
            SELECT
                region_id, region_name,
                ROW_NUMBER() OVER (PARTITION BY region_id ORDER BY (SELECT NULL)) AS rn
            FROM stg.dim_region
            WHERE region_id IS NOT NULL
        ) x
        WHERE rn = 1
    )
    MERGE dw.dim_region AS tgt
    USING src
      ON tgt.region_id = src.region_id
    WHEN MATCHED AND ISNULL(tgt.region_name,'') <> ISNULL(src.region_name,'')
        THEN UPDATE SET region_name = src.region_name
    WHEN NOT MATCHED BY TARGET
        THEN INSERT (region_id, region_name) VALUES (src.region_id, src.region_name);
END;
GO