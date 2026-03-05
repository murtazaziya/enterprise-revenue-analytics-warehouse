CREATE TABLE dw.dim_business_unit (
    bu_key INT IDENTITY(1,1) PRIMARY KEY,
    bu_id VARCHAR(50) UNIQUE,
    bu_name VARCHAR(255)
);

CREATE TABLE dw.dim_region (
    region_key INT IDENTITY(1,1) PRIMARY KEY,
    region_id VARCHAR(50) UNIQUE,
    region_name VARCHAR(255)
);

CREATE TABLE dw.dim_client (
    client_key INT IDENTITY(1,1) PRIMARY KEY,
    client_id VARCHAR(50) UNIQUE,
    client_name VARCHAR(255),
    industry VARCHAR(100),
    client_tier VARCHAR(50),
    hq_region_key INT
);

CREATE TABLE dw.dim_project_manager (
    pm_key INT IDENTITY(1,1) PRIMARY KEY,
    pm_id VARCHAR(50) UNIQUE,
    pm_name VARCHAR(255),
    pm_email VARCHAR(255)
);

CREATE TABLE dw.dim_project (
    project_key INT IDENTITY(1,1) PRIMARY KEY,
    project_id VARCHAR(50) UNIQUE,
    project_name VARCHAR(255),
    client_key INT,
    bu_key INT,
    region_key INT,
    pm_key INT,
    billing_model VARCHAR(50),
    start_date DATE,
    end_date DATE,
    bill_rate DECIMAL(18,2),
    fixed_fee_total DECIMAL(18,2),
    status VARCHAR(50)
);

CREATE TABLE dw.dim_resource (
    resource_key INT IDENTITY(1,1) PRIMARY KEY,
    resource_id VARCHAR(50) UNIQUE,
    resource_name VARCHAR(255),
    role VARCHAR(100),
    cost_rate DECIMAL(18,2),
    bill_rate DECIMAL(18,2),
    active_flag BIT
);

CREATE TABLE dw.dim_date (
    date_key INT PRIMARY KEY,
    full_date DATE,
    year INT,
    month INT,
    day INT,
    month_name VARCHAR(20),
    quarter INT
);

CREATE TABLE dw.fact_revenue_daily (
    date_key INT,
    project_key INT,
    revenue DECIMAL(18,2),
    cost DECIMAL(18,2),
    margin DECIMAL(18,2),
    billable_hours DECIMAL(18,2),
    distinct_resources INT
);

CREATE TABLE dw.fact_resource_allocation_daily (
    date_key INT,
    project_key INT,
    resource_key INT,
    allocation_pct DECIMAL(5,2),
    billable_hours DECIMAL(18,2)
);