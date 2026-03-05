CREATE OR ALTER PROCEDURE dw.sp_upsert_dim_business_unit
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH src AS (
        SELECT bu_id, bu_name
        FROM (
            SELECT
                bu_id, bu_name,
                ROW_NUMBER() OVER (PARTITION BY bu_id ORDER BY (SELECT NULL)) AS rn
            FROM stg.dim_business_unit
            WHERE bu_id IS NOT NULL
        ) x
        WHERE rn = 1
    )
    MERGE dw.dim_business_unit AS tgt
    USING src
      ON tgt.bu_id = src.bu_id
    WHEN MATCHED AND ISNULL(tgt.bu_name,'') <> ISNULL(src.bu_name,'')
        THEN UPDATE SET bu_name = src.bu_name
    WHEN NOT MATCHED BY TARGET
        THEN INSERT (bu_id, bu_name) VALUES (src.bu_id, src.bu_name);
END;
GO