-- Drop the view if it exists
IF OBJECT_ID('dbo.value_of_holding_stock_per_supplier_view', 'V') IS NOT NULL
    DROP VIEW dbo.value_of_holding_stock_per_supplier_view;
GO

CREATE VIEW value_of_holding_stock_per_supplier_view AS
SELECT
soh.id AS stock_on_hand_id,
    soh.stock_on_hand,
    soh.occurred_date AS stock_on_hand_date,
    f.id AS facility_id,
    f.name AS facility_name,
    gl.id AS geographic_level_id,
    gl.name AS geographic_level_name,
    p.id AS product_id,
    p.name AS product_name,
    pp.price_per_pack AS unit_cost,
    (soh.stock_on_hand * pp.price_per_pack) AS total_cost,
    lot.code AS lot_code,
    prg.id AS program_id,
    prg.name AS program_name,
    sc.facility_id AS supply_source_id,
    sf.name AS supply_source_name,
    gz.name AS municipality_name,
    gz2.name AS province_name
    -- count(*)
FROM
    public_stock_on_hand soh
JOIN
    public_stock_card sc ON soh.stock_card_id = sc.reference_id
JOIN
    public_facility f ON sc.facility_id = f.reference_id
JOIN
    public_geographic_zone gz ON f.geographic_zone_id = gz.reference_id
JOIN
    public_geographic_level gl ON gz.level_id = gl.reference_id
JOIN
    latest_product_version p ON sc.product_id = p.reference_id
JOIN
    public_program_product pp ON p.reference_id = pp.product_id AND pp.program_id = sc.program_id AND pp.product_version_number = p.version_number
JOIN
    public_lot lot ON sc.lot_id = lot.reference_id
JOIN
    public_program prg ON pp.program_id = prg.reference_id AND sc.program_id = prg.reference_id

join public_geographic_zone gz2 on gz2.reference_id = gz.parent_id
join public_geographic_level gl2 on gl2.reference_id = gz2.level_id 

JOIN
    public_facility sf ON sc.facility_id = sf.reference_id
GO
