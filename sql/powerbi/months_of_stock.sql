-- Drop the view if it exists
IF OBJECT_ID('dbo.months_of_stock', 'V') IS NOT NULL
    DROP VIEW dbo.months_of_stock;
GO

-- Create the view
CREATE VIEW [dbo].[months_of_stock]
AS
SELECT
    pv.province_name AS Province,
    mv.municipality_name AS Municipality,
    pf.name AS Facility,
    pf.description AS Program,
    pp.code AS ProductCode,
    pp.name AS ProductName,
    psoh.stock_on_hand AS SOH,
    rl.average_consumption AS AMC,
    (psoh.stock_on_hand / rl.average_consumption) AS MOS
FROM 
    public_facility pf
JOIN 
    dbo.municipality_view mv ON pf.geographic_zone_id = mv.municipality_id
JOIN 
    dbo.province_view pv ON mv.province_id = pv.province_id
JOIN 
    public_stock_card sc ON pf.id = sc.facility_id
JOIN 
    public_stock_card_line scl ON sc.id = scl.stock_card_id
JOIN 
    public_stock_on_hand psoh ON sc.id = psoh.stock_card_id
JOIN 
    public_product pp ON sc.product_id = pp.id
JOIN 
    public_requisition_line rl ON pp.id = rl.product_id;

