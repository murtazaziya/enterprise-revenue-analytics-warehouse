CREATE OR ALTER PROCEDURE dw.sp_upsert_dim_project_manager
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH src AS (
        SELECT pm_id, pm_name, pm_email
        FROM (
            SELECT
                pm_id, pm_name, pm_email,
                ROW_NUMBER() OVER (PARTITION BY pm_id ORDER BY (SELECT NULL)) AS rn
            FROM stg.dim_project_manager
            WHERE pm_id IS NOT NULL
        ) x
        WHERE rn = 1
    )
    MERGE dw.dim_project_manager AS tgt
    USING src
      ON tgt.pm_id = src.pm_id
    WHEN MATCHED AND (
        ISNULL(tgt.pm_name,'') <> ISNULL(src.pm_name,'')
        OR ISNULL(tgt.pm_email,'') <> ISNULL(src.pm_email,'')
    )
        THEN UPDATE SET pm_name = src.pm_name, pm_email = src.pm_email
    WHEN NOT MATCHED BY TARGET
        THEN INSERT (pm_id, pm_name, pm_email)
             VALUES (src.pm_id, src.pm_name, src.pm_email);
END;
GO