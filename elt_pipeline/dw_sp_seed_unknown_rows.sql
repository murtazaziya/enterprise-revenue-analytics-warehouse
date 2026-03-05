CREATE OR ALTER PROCEDURE dw.sp_seed_unknown_rows
AS
BEGIN
    SET NOCOUNT ON;

    /* dim_business_unit */
    IF NOT EXISTS (SELECT 1 FROM dw.dim_business_unit WHERE bu_key = 0)
    BEGIN
        SET IDENTITY_INSERT dw.dim_business_unit ON;
        INSERT INTO dw.dim_business_unit (bu_key, bu_id, bu_name)
        VALUES (0, 'UNKNOWN', 'Unknown');
        SET IDENTITY_INSERT dw.dim_business_unit OFF;
    END

    /* dim_region */
    IF NOT EXISTS (SELECT 1 FROM dw.dim_region WHERE region_key = 0)
    BEGIN
        SET IDENTITY_INSERT dw.dim_region ON;
        INSERT INTO dw.dim_region (region_key, region_id, region_name)
        VALUES (0, 'UNKNOWN', 'Unknown');
        SET IDENTITY_INSERT dw.dim_region OFF;
    END

    /* dim_client */
    IF NOT EXISTS (SELECT 1 FROM dw.dim_client WHERE client_key = 0)
    BEGIN
        SET IDENTITY_INSERT dw.dim_client ON;
        INSERT INTO dw.dim_client (client_key, client_id, client_name, industry, client_tier, hq_region_key)
        VALUES (0, 'UNKNOWN', 'Unknown', NULL, NULL, 0);
        SET IDENTITY_INSERT dw.dim_client OFF;
    END

    /* dim_project_manager */
    IF NOT EXISTS (SELECT 1 FROM dw.dim_project_manager WHERE pm_key = 0)
    BEGIN
        SET IDENTITY_INSERT dw.dim_project_manager ON;
        INSERT INTO dw.dim_project_manager (pm_key, pm_id, pm_name, pm_email)
        VALUES (0, 'UNKNOWN', 'Unknown', NULL);
        SET IDENTITY_INSERT dw.dim_project_manager OFF;
    END

    /* dim_project */
    IF NOT EXISTS (SELECT 1 FROM dw.dim_project WHERE project_key = 0)
    BEGIN
        SET IDENTITY_INSERT dw.dim_project ON;
        INSERT INTO dw.dim_project (
            project_key, project_id, project_name,
            client_key, bu_key, region_key, pm_key,
            billing_model, start_date, end_date,
            bill_rate, fixed_fee_total, status
        )
        VALUES (
            0, 'UNKNOWN', 'Unknown',
            0, 0, 0, 0,
            NULL, NULL, NULL,
            NULL, NULL, NULL
        );
        SET IDENTITY_INSERT dw.dim_project OFF;
    END

    /* dim_resource */
    IF NOT EXISTS (SELECT 1 FROM dw.dim_resource WHERE resource_key = 0)
    BEGIN
        SET IDENTITY_INSERT dw.dim_resource ON;
        INSERT INTO dw.dim_resource (
            resource_key, resource_id, resource_name,
            role, cost_rate, bill_rate, active_flag
        )
        VALUES (
            0, 'UNKNOWN', 'Unknown',
            NULL, NULL, NULL, 1
        );
        SET IDENTITY_INSERT dw.dim_resource OFF;
    END
END;
GO