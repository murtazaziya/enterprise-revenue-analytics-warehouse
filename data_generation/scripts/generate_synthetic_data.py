import os
import random
from dataclasses import dataclass
from datetime import date, datetime
from dateutil.relativedelta import relativedelta

import numpy as np
import pandas as pd
from faker import Faker

fake = Faker()
Faker.seed(42)
np.random.seed(42)
random.seed(42)

# -------------------------
# CONFIG (edit these)
# -------------------------
OUTPUT_DIR = "output"

START_DATE = date(2024, 1, 1)
END_DATE   = date(2025, 12, 31)

N_BUSINESS_UNITS = 8
N_REGIONS = 6
N_CLIENTS = 250
N_PMS = 80
N_PROJECTS = 1200
N_RESOURCES = 600

# Allocation generation
MIN_RESOURCES_PER_PROJECT = 2
MAX_RESOURCES_PER_PROJECT = 12

# Percent chance a project is active on a day within its date range
PROJECT_ACTIVE_PROB = 0.85

# -------------------------
# Helper functions
# -------------------------
def ensure_output_dir():
    os.makedirs(OUTPUT_DIR, exist_ok=True)

def daterange(start: date, end: date):
    # inclusive range
    cur = start
    while cur <= end:
        yield cur
        cur += relativedelta(days=1)

def weighted_choice(items, weights):
    return random.choices(items, weights=weights, k=1)[0]

def make_id(prefix: str, n: int):
    return f"{prefix}{n:05d}"

# -------------------------
# 1) DIM: Business Units
# -------------------------
def generate_business_units(n=N_BUSINESS_UNITS):
    bu_names = [
        "Enterprise SaaS", "HR Tech", "FinTech", "Healthcare", "Retail",
        "Manufacturing", "Public Sector", "Professional Services",
        "Logistics", "Telecom"
    ]
    random.shuffle(bu_names)
    bu_names = bu_names[:n]

    rows = []
    for i, name in enumerate(bu_names, start=1):
        rows.append({
            "bu_id": make_id("BU", i),
            "bu_name": name
        })
    return pd.DataFrame(rows)

# -------------------------
# 2) DIM: Regions (Regional BU)
# -------------------------
def generate_regions(n=N_REGIONS):
    region_names = ["NA", "EU", "UKI", "APAC", "MEA", "LATAM", "ANZ", "India"]
    random.shuffle(region_names)
    region_names = region_names[:n]

    rows = []
    for i, name in enumerate(region_names, start=1):
        rows.append({
            "region_id": make_id("RG", i),
            "region_name": name
        })
    return pd.DataFrame(rows)

# -------------------------
# 3) DIM: Clients
# -------------------------
def generate_clients(n=N_CLIENTS, regions_df=None):
    industries = ["SaaS", "Retail", "Banking", "Insurance", "Healthcare", "Manufacturing", "Education", "Logistics"]
    tiers = ["SMB", "Mid-Market", "Enterprise"]

    region_ids = regions_df["region_id"].tolist()

    rows = []
    for i in range(1, n+1):
        client_name = fake.company().replace(",", "")
        rows.append({
            "client_id": make_id("CL", i),
            "client_name": client_name,
            "industry": random.choice(industries),
            "client_tier": weighted_choice(tiers, weights=[0.35, 0.40, 0.25]),
            "hq_region_id": random.choice(region_ids),
            "created_date": fake.date_between(start_date="-6y", end_date="-1y").isoformat()
        })
    return pd.DataFrame(rows)

# -------------------------
# 4) DIM: Project Managers
# -------------------------
def generate_project_managers(n=N_PMS):
    rows = []
    for i in range(1, n+1):
        name = fake.name()
        rows.append({
            "pm_id": make_id("PM", i),
            "pm_name": name,
            "pm_email": name.lower().replace(" ", ".") + "@example.com"
        })
    return pd.DataFrame(rows)

# -------------------------
# 5) DIM: Projects
# -------------------------
def generate_projects(n=N_PROJECTS, clients_df=None, bu_df=None, regions_df=None, pms_df=None):
    billing_models = ["T&M", "Fixed Fee", "Retainer"]
    project_status = ["Active", "Completed", "On Hold"]

    client_ids = clients_df["client_id"].tolist()
    bu_ids = bu_df["bu_id"].tolist()
    region_ids = regions_df["region_id"].tolist()
    pm_ids = pms_df["pm_id"].tolist()

    rows = []
    for i in range(1, n+1):
        client_id = random.choice(client_ids)
        bu_id = random.choice(bu_ids)
        region_id = random.choice(region_ids)
        pm_id = random.choice(pm_ids)

        # Project start between START_DATE - 12 months and END_DATE - 3 months
        start = fake.date_between_dates(
            date_start=START_DATE - relativedelta(months=12),
            date_end=END_DATE - relativedelta(months=3)
        )
        # Project duration 1 to 18 months
        duration_months = int(np.random.choice([1,2,3,6,9,12,18], p=[0.08,0.10,0.14,0.22,0.16,0.20,0.10]))
        end = start + relativedelta(months=duration_months)

        # Clamp end date to END_DATE
        if end > END_DATE:
            end = END_DATE

        model = weighted_choice(billing_models, weights=[0.55, 0.25, 0.20])

        # Rate card (for T&M/Retainer)
        bill_rate = int(np.random.normal(loc=110, scale=25))
        bill_rate = max(50, min(bill_rate, 250))

        # Fixed fee estimate (for fixed fee projects)
        fixed_fee_total = int(abs(np.random.normal(loc=250000, scale=150000)))
        fixed_fee_total = max(25000, min(fixed_fee_total, 2000000))

        rows.append({
            "project_id": make_id("PR", i),
            "project_name": f"{fake.bs().title().replace(',', '')}",
            "client_id": client_id,
            "bu_id": bu_id,
            "region_id": region_id,
            "pm_id": pm_id,
            "billing_model": model,
            "start_date": start.isoformat(),
            "end_date": end.isoformat(),
            "bill_rate_usd_per_hr": bill_rate if model in ["T&M", "Retainer"] else None,
            "fixed_fee_total_usd": fixed_fee_total if model == "Fixed Fee" else None,
            "status": weighted_choice(project_status, weights=[0.75, 0.20, 0.05])
        })

    return pd.DataFrame(rows)

# -------------------------
# 6) DIM: Resources
# -------------------------
def generate_resources(n=N_RESOURCES):
    roles = [
        ("Data Engineer", 55, 95),
        ("Analytics Engineer", 60, 105),
        ("BI Developer", 45, 85),
        ("Data Analyst", 40, 75),
        ("ML Engineer", 70, 130),
        ("Backend Engineer", 65, 120),
        ("QA Engineer", 35, 65),
        ("Project Coordinator", 30, 55),
    ]

    rows = []
    for i in range(1, n+1):
        name = fake.name()
        role, cost_min, bill_min = random.choice(roles)

        # cost rate and bill rate (bill > cost)
        cost_rate = round(float(np.random.uniform(cost_min, cost_min + 25)), 2)
        bill_rate = round(float(np.random.uniform(bill_min, bill_min + 35)), 2)

        rows.append({
            "resource_id": make_id("RS", i),
            "resource_name": name,
            "resource_email": name.lower().replace(" ", ".") + "@example.com",
            "role": role,
            "cost_rate_usd_per_hr": cost_rate,
            "default_bill_rate_usd_per_hr": bill_rate,
            "active_flag": 1
        })
    return pd.DataFrame(rows)

# -------------------------
# 7) FACT: Daily Resource Allocation
# -------------------------
def generate_daily_allocations(projects_df, resources_df):
    projects_df = projects_df.copy()
    projects_df["start_date"] = pd.to_datetime(projects_df["start_date"]).dt.date
    projects_df["end_date"] = pd.to_datetime(projects_df["end_date"]).dt.date

    resource_ids = resources_df["resource_id"].tolist()

    allocation_rows = []

    # To avoid insane runtime, we generate allocations only for days a project is active
    for _, pr in projects_df.iterrows():
        pr_id = pr["project_id"]
        start = max(pr["start_date"], START_DATE)
        end = min(pr["end_date"], END_DATE)

        # choose a stable project team
        team_size = random.randint(MIN_RESOURCES_PER_PROJECT, MAX_RESOURCES_PER_PROJECT)
        team = random.sample(resource_ids, k=team_size)

        for d in daterange(start, end):
            # project not active every day
            if random.random() > PROJECT_ACTIVE_PROB:
                continue

            # each team member might not be allocated that day
            for rs_id in team:
                if random.random() < 0.55:
                    # allocated
                    allocation_pct = float(np.random.choice([0.25, 0.50, 0.75, 1.00], p=[0.25, 0.35, 0.20, 0.20]))
                    # hours 0-8 scaled by allocation
                    hours = round(float(np.random.uniform(2, 8) * allocation_pct), 2)

                    allocation_rows.append({
                        "date": d.isoformat(),
                        "project_id": pr_id,
                        "resource_id": rs_id,
                        "allocation_pct": allocation_pct,
                        "billable_hours": hours
                    })

    return pd.DataFrame(allocation_rows)

# -------------------------
# 8) FACT: Daily Revenue (derived from allocations)
# -------------------------
def generate_daily_revenue(projects_df, resources_df, allocations_df):
    # Join to get rates
    proj_rates = projects_df[["project_id", "billing_model", "bill_rate_usd_per_hr"]].copy()
    res_rates = resources_df[["resource_id", "cost_rate_usd_per_hr", "default_bill_rate_usd_per_hr"]].copy()

    alloc = allocations_df.merge(res_rates, on="resource_id", how="left").merge(proj_rates, on="project_id", how="left")

    # billing rate: use project rate if exists, otherwise resource default
    alloc["effective_bill_rate"] = alloc["bill_rate_usd_per_hr"].fillna(alloc["default_bill_rate_usd_per_hr"])
    alloc["revenue_usd"] = (alloc["billable_hours"] * alloc["effective_bill_rate"]).round(2)
    alloc["cost_usd"] = (alloc["billable_hours"] * alloc["cost_rate_usd_per_hr"]).round(2)
    alloc["margin_usd"] = (alloc["revenue_usd"] - alloc["cost_usd"]).round(2)

    # Aggregate to project-day grain
    fact = alloc.groupby(["date", "project_id"], as_index=False).agg(
        revenue_usd=("revenue_usd", "sum"),
        cost_usd=("cost_usd", "sum"),
        margin_usd=("margin_usd", "sum"),
        billable_hours=("billable_hours", "sum"),
        distinct_resources=("resource_id", "nunique")
    )

    return fact

# -------------------------
# Main
# -------------------------
def main():
    ensure_output_dir()

    bu_df = generate_business_units()
    regions_df = generate_regions()
    clients_df = generate_clients(regions_df=regions_df)
    pms_df = generate_project_managers()
    projects_df = generate_projects(clients_df=clients_df, bu_df=bu_df, regions_df=regions_df, pms_df=pms_df)
    resources_df = generate_resources()

    # Save dims
    bu_df.to_csv(os.path.join(OUTPUT_DIR, "dim_business_unit.csv"), index=False)
    regions_df.to_csv(os.path.join(OUTPUT_DIR, "dim_region.csv"), index=False)
    clients_df.to_csv(os.path.join(OUTPUT_DIR, "dim_client.csv"), index=False)
    pms_df.to_csv(os.path.join(OUTPUT_DIR, "dim_project_manager.csv"), index=False)
    projects_df.to_csv(os.path.join(OUTPUT_DIR, "dim_project.csv"), index=False)
    resources_df.to_csv(os.path.join(OUTPUT_DIR, "dim_resource.csv"), index=False)

    # Facts
    allocations_df = generate_daily_allocations(projects_df, resources_df)
    allocations_df.to_csv(os.path.join(OUTPUT_DIR, "fact_resource_allocation_daily.csv"), index=False)

    revenue_df = generate_daily_revenue(projects_df, resources_df, allocations_df)
    revenue_df.to_csv(os.path.join(OUTPUT_DIR, "fact_revenue_daily.csv"), index=False)

    # Print quick stats
    print("Generated files in:", OUTPUT_DIR)
    print("Rows:")
    print("  dim_business_unit:", len(bu_df))
    print("  dim_region:", len(regions_df))
    print("  dim_client:", len(clients_df))
    print("  dim_project_manager:", len(pms_df))
    print("  dim_project:", len(projects_df))
    print("  dim_resource:", len(resources_df))
    print("  fact_resource_allocation_daily:", len(allocations_df))
    print("  fact_revenue_daily:", len(revenue_df))

if __name__ == "__main__":
    main()