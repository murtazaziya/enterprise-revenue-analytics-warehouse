CREATE OR ALTER PROCEDURE dw.sp_load_fact_resource_allocation_daily_incr
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @min_date DATE;

    SELECT @min_date = MIN(TRY_CAST([date] AS DATE))
    FROM stg.fact_resource_allocation_daily;

    IF @min_date IS NULL
        RETURN;

    -- Delete only the affected date range
    DELETE f
    FROM dw.fact_resource_allocation_daily f
    JOIN dw.dim_date d
      ON f.date_key = d.date_key
    WHERE d.full_date >= @min_date;

    -- Re-insert refreshed rows
    INSERT INTO dw.fact_resource_allocation_daily (
        date_key,
        project_key,
        resource_key,
        allocation_pct,
        billable_hours
    )
    SELECT
        d.date_key,
        COALESCE(p.project_key, 0),
        COALESCE(res.resource_key, 0),
        TRY_CAST(a.allocation_pct AS DECIMAL(5,2)),
        TRY_CAST(a.billable_hours AS DECIMAL(18,2))
    FROM stg.fact_resource_allocation_daily a
    JOIN dw.dim_date d
      ON d.full_date = TRY_CAST(a.[date] AS DATE)
    LEFT JOIN dw.dim_project p
      ON a.project_id = p.project_id
    LEFT JOIN dw.dim_resource res
      ON a.resource_id = res.resource_id;
END;
GO