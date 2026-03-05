CREATE OR ALTER PROCEDURE dw.sp_run_full_refresh
AS
BEGIN
    SET NOCOUNT ON;

    EXEC dw.sp_seed_unknown_rows;

    EXEC dw.sp_upsert_dim_business_unit;
    EXEC dw.sp_upsert_dim_region;
    EXEC dw.sp_upsert_dim_project_manager;
    EXEC dw.sp_upsert_dim_client;
    EXEC dw.sp_upsert_dim_project;
    EXEC dw.sp_upsert_dim_resource;

    EXEC dw.sp_load_fact_resource_allocation_daily_incr;
    EXEC dw.sp_load_fact_revenue_daily_incr;
END;
GO