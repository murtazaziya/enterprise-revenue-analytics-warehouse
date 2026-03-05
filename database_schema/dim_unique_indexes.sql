CREATE UNIQUE INDEX ux_dim_bu_id ON dw.dim_business_unit(bu_id);
CREATE UNIQUE INDEX ux_dim_region_id ON dw.dim_region(region_id);
CREATE UNIQUE INDEX ux_dim_client_id ON dw.dim_client(client_id);
CREATE UNIQUE INDEX ux_dim_pm_id ON dw.dim_project_manager(pm_id);
CREATE UNIQUE INDEX ux_dim_project_id ON dw.dim_project(project_id);
CREATE UNIQUE INDEX ux_dim_resource_id ON dw.dim_resource(resource_id);