CREATE OR ALTER PROCEDURE dw.sp_load_fact_revenue_daily_incr
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @min_date_key INT;

    -- Compute the minimum date_key present in staging (via dim_date)
    SELECT @min_date_key = MIN(d.date_key)
    FROM stg.fact_revenue_daily r
    JOIN dw.dim_date d
      ON d.full_date = TRY_CAST(r.[date] AS DATE);

    -- If staging has no valid dates, do nothing
    IF @min_date_key IS NULL
        RETURN;

    -- FAST delete using integer key (no join)
    DELETE FROM dw.fact_revenue_daily
    WHERE date_key >= @min_date_key;

    -- Re-insert refreshed rows
    INSERT INTO dw.fact_revenue_daily (
        date_key, project_key, revenue, cost, margin, billable_hours, distinct_resources
    )
    SELECT
        d.date_key,
        COALESCE(p.project_key, 0),
        TRY_CAST(r.revenue_usd AS DECIMAL(18,2)),
        TRY_CAST(r.cost_usd AS DECIMAL(18,2)),
        TRY_CAST(r.margin_usd AS DECIMAL(18,2)),
        TRY_CAST(r.billable_hours AS DECIMAL(18,2)),
        TRY_CAST(r.distinct_resources AS INT)
    FROM stg.fact_revenue_daily r
    JOIN dw.dim_date d
      ON d.full_date = TRY_CAST(r.[date] AS DATE)
    LEFT JOIN dw.dim_project p
      ON r.project_id = p.project_id;
END;
GO