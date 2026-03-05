CREATE TABLE stg.dim_business_unit (
    bu_id VARCHAR(50),
    bu_name VARCHAR(255)
);

CREATE TABLE stg.dim_region (
    region_id VARCHAR(50),
    region_name VARCHAR(255)
);

CREATE TABLE stg.dim_client (
    client_id VARCHAR(50),
    client_name VARCHAR(255),
    industry VARCHAR(100),
    client_tier VARCHAR(50),
    hq_region_id VARCHAR(50),
    created_date VARCHAR(50)
);

CREATE TABLE stg.dim_project_manager (
    pm_id VARCHAR(50),
    pm_name VARCHAR(255),
    pm_email VARCHAR(255)
);

CREATE TABLE stg.dim_project (
    project_id VARCHAR(50),
    project_name VARCHAR(255),
    client_id VARCHAR(50),
    bu_id VARCHAR(50),
    region_id VARCHAR(50),
    pm_id VARCHAR(50),
    billing_model VARCHAR(50),
    start_date VARCHAR(50),
    end_date VARCHAR(50),
    bill_rate_usd_per_hr VARCHAR(50),
    fixed_fee_total_usd VARCHAR(50),
    status VARCHAR(50)
);

CREATE TABLE stg.dim_resource (
    resource_id VARCHAR(50),
    resource_name VARCHAR(255),
    resource_email VARCHAR(255),
    role VARCHAR(100),
    cost_rate_usd_per_hr VARCHAR(50),
    default_bill_rate_usd_per_hr VARCHAR(50),
    active_flag VARCHAR(50)
);

CREATE TABLE stg.fact_resource_allocation_daily (
    date VARCHAR(50),
    project_id VARCHAR(50),
    resource_id VARCHAR(50),
    allocation_pct VARCHAR(50),
    billable_hours VARCHAR(50)
);

CREATE TABLE stg.fact_revenue_daily (
    date VARCHAR(50),
    project_id VARCHAR(50),
    revenue_usd VARCHAR(50),
    cost_usd VARCHAR(50),
    margin_usd VARCHAR(50),
    billable_hours VARCHAR(50),
    distinct_resources VARCHAR(50)
);