# IT Service Desk Analytics Dashboard

An end-to-end data analytics project that cleans, models, and visualizes IT helpdesk ticket data to answer key operational questions around SLA performance, root causes, agent productivity, and customer satisfaction.

**Tools used:** MySQL (data cleaning) → Power BI (data modeling, DAX, dashboard)

---

## Business Context

Every organization with an internal IT team generates helpdesk ticket data — hardware issues, software bugs, network problems, access requests, and email issues. This project simulates that environment to answer a core business question:

> **"Where are the bottlenecks in our IT support process, and what should leadership focus on to improve SLA compliance and customer satisfaction?"**

## Business Questions Answered

1. **SLA Compliance** — What percentage of tickets are resolved within SLA, and which category, priority, or department has the most breaches?
2. **Ticket Volume & Trends** — How does ticket volume change over time? Are there spikes?
3. **Root Cause Analysis** — Which categories and subcategories generate the most tickets, and are they concentrated in specific departments?
4. **Agent Performance & Workload** — Which agents resolve tickets fastest? Is workload balanced?
5. **Customer Satisfaction** — Does resolution time or category affect CSAT scores?
6. **Backlog & Reopened Tickets** — How many tickets remain unresolved, and how often are tickets reopened?

---

## Dataset

- **Size:** 1,650 cleaned rows (originally 1,683 before deduplication)
- **Period covered:** January 2 – May 31, 2024
- **Format:** Synthetic ticket data (CSV), intentionally generated with realistic messiness — inconsistent category naming, mixed date formats, duplicate rows, and missing values — to replicate a real-world data cleaning scenario

**Columns:** `ticket_id`, `created_date`, `resolved_date`, `category`, `subcategory`, `priority`, `status`, `agent_name`, `department`, `sla_target_hours`, `sla_breached`, `customer_satisfaction`, `resolution_time_hours`

---

## Data Cleaning (MySQL)

Raw data was imported into MySQL and cleaned using SQL before loading into Power BI. Key steps:

- **Deduplication:** Removed 33 exact duplicate rows using `ROW_NUMBER() OVER (PARTITION BY ticket_id)`
- **Category standardization:** Consolidated 19 inconsistent category spellings (`HW`, `hardware`, `Hard ware`, etc.) into 5 clean values using `CASE` + `TRIM`
- **Priority standardization:** Fixed hidden case-sensitivity duplicates (`medium` vs `Medium`) that were masked by MySQL's default case-insensitive collation — caught using a `BINARY` comparison
- **Missing value handling:** Filled genuine data-entry gaps (`department`, `subcategory`, `agent_name`) with explicit placeholders (`Unknown`, `Unspecified`, `Unassigned`); intentionally left `resolved_date` and `customer_satisfaction` blank where the blank itself is meaningful (open tickets have no resolution date; not all customers respond to surveys)
- **Date parsing:** Detected and converted 4 mixed date formats (`YYYY-MM-DD`, `DD/MM/YYYY`, `MM-DD-YYYY`, `DD-Mon-YYYY`) into proper `DATETIME` using `REGEXP` pattern matching + `STR_TO_DATE`
- **Derived field:** Calculated `resolution_time_hours` using `TIMESTAMPDIFF`, cross-validated against the existing `sla_breached` flag for logical consistency

---

## Data Modeling (Power BI)

- Built a dedicated `DateTable` using `CALENDAR()`, marked as an official Date Table to enable time-intelligence
- Created a date-only key (`CreatedDateOnly`) to resolve a relationship mismatch caused by time-of-day components in the raw date column
- Established a one-to-many relationship (`DateTable[Date]` → `CreatedDateOnly`) with single-direction cross-filtering

## Key DAX Measures

| Measure | Purpose |
|---|---|
| `SLA Compliance %` | % of judged tickets that met their SLA target |
| `Avg Resolution Time (hrs)` | Average time to resolve a ticket |
| `Backlog` | Count of currently unresolved tickets |
| `Reopen Rate %` | % of tickets reopened after resolution |
| `Avg CSAT` | Average customer satisfaction score (1–5) |
| `SLA Breach % by Category` | Breach rate broken down by ticket category |
| `Reopened Count` | Count of tickets with reopened status, by category |

Measures were built defensively (e.g., using `<> ""` instead of `ISBLANK()` for text columns, and `IFERROR` wrapping for type conversions) after discovering that MySQL-sourced text columns store missing values as empty strings rather than true nulls — a distinction that silently broke early versions of the SLA and CSAT calculations until caught through manual cross-validation.

---

## Dashboard Pages

### 1. Executive Overview
Headline KPIs, SLA breach rate by category, ticket status breakdown, SLA compliance by department, and monthly ticket volume trend.

### 2. Root Cause Analysis
Ticket volume by category & subcategory (treemap), subcategory volume segmented by priority, and a category-by-department breakdown.

### 3. Agent Performance
Agent workload distribution, a full agent performance summary table, a combo chart comparing workload against resolution speed, and SLA outcome distribution — filterable by department and priority.

### 4. Satisfaction & Quality
Customer satisfaction by category, backlog breakdown by category and priority, reopen rate trend over time, and reopened tickets by category — filterable by priority.

---

## Key Insights

- Overall SLA compliance sits at **73%**, with **Access** and **Email** categories showing the highest breach rates
- Ticket volume peaked in **February 2024** before trending downward through May
- **Software** is the single largest ticket category, with **Application Crash** as the most common subcategory
- Agent workload is uneven — the busiest agent handles noticeably more tickets than the least busy, without a proportional increase in resolution time
- **82 tickets** remain unassigned, representing an operational gap worth addressing
- Reopen rate is highest for **Email**-related tickets, suggesting first-time resolution quality issues in that category

---

## Skills Demonstrated

- SQL data cleaning: deduplication, regex-based parsing, conditional standardization, derived columns
- Data validation discipline: cross-checking calculated fields against source logic, catching two live calculation bugs (SLA %, CSAT) through manual verification rather than assuming correctness
- Power BI data modeling: star-schema-style date table, relationship troubleshooting (granularity mismatches)
- DAX: `CALCULATE`, `FILTER`, `DIVIDE`, `AVERAGEX`, `SUMMARIZE`, `TOPN`, `IFERROR`, time intelligence groundwork
- Dashboard design: business-question-driven page structure, deliberate visual variety (no repeated chart types), KPI card hierarchy

---

## Tools

- **MySQL Workbench** — data cleaning and transformation
- **Power BI Desktop** — data modeling, DAX measures, dashboard design
