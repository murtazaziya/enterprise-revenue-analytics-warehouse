--fact_revenue_daily
ALTER TABLE dw.fact_revenue_daily
ADD CONSTRAINT fk_rev_date
FOREIGN KEY (date_key) REFERENCES dw.dim_date(date_key);

ALTER TABLE dw.fact_revenue_daily
ADD CONSTRAINT fk_rev_project
FOREIGN KEY (project_key) REFERENCES dw.dim_project(project_key);

--fact_resource_allocation_daily
ALTER TABLE dw.fact_resource_allocation_daily
ADD CONSTRAINT fk_alloc_date
FOREIGN KEY (date_key) REFERENCES dw.dim_date(date_key);

ALTER TABLE dw.fact_resource_allocation_daily
ADD CONSTRAINT fk_alloc_project
FOREIGN KEY (project_key) REFERENCES dw.dim_project(project_key);

ALTER TABLE dw.fact_resource_allocation_daily
ADD CONSTRAINT fk_alloc_resource
FOREIGN KEY (resource_key) REFERENCES dw.dim_resource(resource_key);