-- -- Drop the view if it exists
IF OBJECT_ID('dbo.value_of_stock_near_expiry', 'V') IS NOT NULL
    DROP VIEW dbo.value_of_stock_near_expiry;
GO

CREATE VIEW value_of_stock_near_expiry AS
SELECT
    soh.id AS stock_on_hand_id,
    soh.stock_on_hand,
    soh.occurred_date AS stock_on_hand_date,
    f.id AS facility_id,
    f.name AS facility_name,
    gz.reference_id as municipality_id,
    gz2.reference_id as province_id,

    gz.name as municipality_name,
    gz2.name as province_name,
    p.id AS product_id,
    p.name AS product_name,
    pp.price_per_pack AS unit_cost,
    (soh.stock_on_hand * pp.price_per_pack) AS total_cost,
    lot.code AS lot_code,
    lot.expiration_date AS lot_expiration_date,
    prg.id AS program_id,
    prg.name AS program_name,

    CASE
        WHEN lot.expiration_date BETWEEN CURRENT_TIMESTAMP AND DATEADD(month, 6, CURRENT_TIMESTAMP) THEN 1
        ELSE 0
    END AS IsExpiringSoon

FROM
    public_stock_on_hand soh
JOIN
    public_stock_card sc ON soh.stock_card_id = sc.reference_id
JOIN
    public_facility f ON sc.facility_id = f.reference_id
JOIN
    latest_product_version p ON sc.product_id = p.reference_id
JOIN
    public_program_product pp ON p.reference_id = pp.product_id and pp.product_version_number = p.version_number
JOIN
    public_lot lot ON sc.lot_id = lot.reference_id
JOIN
    public_program prg ON pp.program_id = prg.reference_id
JOIN public_geographic_zone gz on gz.reference_id = f.geographic_zone_id
JOIN public_geographic_level gl on gz.level_id = gl.reference_id
join public_geographic_zone gz2 on gz2.reference_id = gz.parent_id
GO
