-- Drop the view if it exists
IF OBJECT_ID('dbo.historical_demand_summary', 'V') IS NOT NULL
    DROP VIEW dbo.historical_demand_summary;
GO

CREATE VIEW historical_demand_summary AS
SELECT
    soh.occured_date,
    f.id AS facility_id,
    f.name AS facility_name,
    mv.municipality_id,
    mv.municipality_name,
    pv.province_id,
    pv.province_name,
    p.id AS product_id,
    p.name AS product_name,
    prg.id AS program_id,
    prg.name AS program_name,
    soh.stock_on_hand AS demand_quantity
FROM
    public_stock_on_hand soh
JOIN
    public_stock_card sc ON soh.stock_card_id = sc.id
JOIN
    public_facility f ON sc.facility_id = f.id
JOIN
    dbo.municipality_view mv ON f.geographic_zone_id = mv.municipality_id
JOIN
    dbo.province_view pv ON mv.province_id = pv.province_id
JOIN
    public_product p ON sc.product_id = p.id
JOIN
    public_program prg ON sc.program_id = prg.id
UNION ALL
SELECT
    r.stock_count_date AS occured_date,
    f.id AS facility_id,
    f.name AS facility_name,
    mv.municipality_id,
    mv.municipality_name,
    pv.province_id,
    pv.province_name,
    p.id AS product_id,
    p.name AS product_name,
    prg.id AS program_id,
    prg.name AS program_name,
    rl.total_consumed_quantity AS demand_quantity
FROM
    public_requisition r
JOIN
    public_requisition_line rl ON r.id = rl.requisition_id
JOIN
    public_facility f ON r.facility_id = f.id
JOIN
    dbo.municipality_view mv ON f.geographic_zone_id = mv.municipality_id
JOIN
    dbo.province_view pv ON mv.province_id = pv.province_id
JOIN
    public_product p ON rl.product_id = p.id
JOIN
    public_program prg ON r.program_id = prg.id
UNION ALL
SELECT
    o.created_date AS occured_date,
    f.id AS facility_id,
    f.name AS facility_name,
    mv.municipality_id,
    mv.municipality_name,
    pv.province_id,
    pv.province_name,
    p.id AS product_id,
    p.name AS product_name,
    prg.id AS program_id,
    prg.name AS program_name,
    ol.ordered_quantity AS demand_quantity
FROM
    public_order o
JOIN
    public_order_line ol ON o.id = ol.order_id
JOIN
    public_facility f ON o.facility_id = f.id
JOIN
    dbo.municipality_view mv ON f.geographic_zone_id = mv.municipality_id
JOIN
    dbo.province_view pv ON mv.province_id = pv.province_id
JOIN
    public_product p ON ol.product_id = p.id
JOIN
    public_program prg ON o.program_id = prg.id;
GO

