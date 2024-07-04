-- Drop the view if it exists
IF OBJECT_ID('dbo.stock_and_order_summary', 'V') IS NOT NULL
    DROP VIEW dbo.stock_and_order_summary;
GO

CREATE VIEW stock_and_order_summary AS
SELECT
distinct 
    soh.id AS stock_on_hand_id,
    soh.stock_on_hand,
    soh.occurred_date AS stock_on_hand_date,
    o.id AS order_id,
    o.created_date AS order_date,
    ol.ordered_quantity,
    f.id AS facility_id,
    f.name AS facility_name,
    gz.reference_id as municipality_id,
    gz2.reference_id as province_id,

    gz.name as municipality_name,
    gz2.name as province_name,
    p.name AS product_name,
    lot.code AS lot_code,
    prg.id AS program_id,
    prg.name AS program_name
FROM
    public_stock_on_hand soh
LEFT JOIN
    public_stock_card sc ON soh.stock_card_id = sc.reference_id
LEFT JOIN
    public_facility f ON sc.facility_id = f.reference_id
LEFT JOIN
    latest_product_version p ON sc.product_id = p.reference_id
LEFT JOIN
    public_lot lot ON sc.lot_id = lot.reference_id
LEFT JOIN
    public_program prg ON sc.program_id = prg.reference_id
LEFT JOIN
    public_order o ON f.reference_id = o.facility_id
LEFT JOIN
    public_order_line ol ON o.reference_id = ol.order_id AND ol.product_id = p.reference_id

LEFT JOIN public_geographic_zone gz on gz.reference_id = f.geographic_zone_id
LEFT JOIN public_geographic_level gl on gz.level_id = gl.reference_id
join public_geographic_zone gz2 on gz2.reference_id = gz.parent_id
join public_geographic_level gl2 on gl2.reference_id = gz2.level_id 
where 
f.active = 1
GO

