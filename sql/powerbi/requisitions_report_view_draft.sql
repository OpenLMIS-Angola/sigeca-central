-- Drop the view if it exists
IF OBJECT_ID('dbo.requisitions_report', 'V') IS NOT NULL
    DROP VIEW dbo.requisitions_report;
GO

CREATE VIEW dbo.requisitions_report AS
SELECT
    r.id AS requisition_id,
    r.created_date,
    r.modified_date,
    r.stock_count_date AS submission_date,
    r.status,
    r.report_only AS requisition_type,
    r.months_in_period AS processing_period,
    r.supplying_facility_id,
    f.reference_id AS facility_id,
    f.name AS facility_name,
    sf.name AS supplying_facility_name,
    gz.id AS geographic_zone_id,
    gz.name AS geographic_zone_name,
    CASE 
        WHEN gl.level = 2 THEN gz.name 
        ELSE pgz.name 
    END AS province_name,
    CASE 
        WHEN gl.level = 3 THEN gz.name 
        ELSE pgz.name 
    END AS municipality_name,
    p.id AS program_id,
    p.name AS program_name,
    r.modified_date AS date_of_last_update,
    'https://test.siglofa.sisangola.org/#!/' + CAST(r.reference_id AS VARCHAR) + '/fullSupply?fullSupplyListPage=0&fullSupplyListSize=10/' as action_link,
    'view' as actions
FROM
    public_requisition r
JOIN
    public_facility f ON r.facility_id = f.reference_id
LEFT JOIN 
    public_facility sf ON r.supplying_facility_id = sf.reference_id
JOIN
    public_geographic_zone gz ON f.geographic_zone_id = gz.reference_id
JOIN
    public_geographic_level gl ON gz.level_id = gl.reference_id
LEFT JOIN
    public_geographic_zone pgz ON gz.parent_id = pgz.reference_id
JOIN
    public_program p ON r.program_id = p.reference_id
WHERE
    f.active = 1;
GO

