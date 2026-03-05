CREATE UNIQUE INDEX ux_fact_revenue ON dw.fact_revenue_daily(date_key, project_key);
CREATE UNIQUE INDEX ux_fact_alloc ON dw.fact_resource_allocation_daily(date_key, project_key, resource_key);