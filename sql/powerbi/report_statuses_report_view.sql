-- Drop the view if it exists
IF OBJECT_ID('dbo.reporting_status_report', 'V') IS NOT NULL
    DROP VIEW dbo.reporting_status_report;
GO

CREATE VIEW reporting_status_report AS
SELECT 
    r.reference_id AS requisition_id,
    r.created_date,
    r.modified_date,
    r.created_date AS submission_date,
    r.status,
    r.report_only AS requisition_type,
    r.months_in_period AS processing_period,
    r.supplying_facility_id,
    f.reference_id AS facility_id,
    f.name AS facility_name,
    gz.name AS municipality_name,
    gz2.name AS province_name,
    p.reference_id AS program_id,
    p.name AS program_name,
    r.modified_date AS date_of_last_update,
    CAST(YEAR(r.created_date) AS VARCHAR) AS year_string,
    FORMAT(r.created_date, 'yyyy.MM (MMMM)') AS formatted_date_string
FROM 
    public_geographic_zone gz
JOIN 
    public_geographic_level gl ON gz.level_id = gl.reference_id
JOIN 
    public_facility f ON f.geographic_zone_id = gz.reference_id 
JOIN 
    public_geographic_zone gz2 ON gz2.reference_id = gz.parent_id
JOIN 
    public_geographic_level gl2 ON gl2.reference_id = gz2.level_id 
JOIN 
    public_requisition r ON r.facility_id = f.reference_id 
JOIN 
    public_program p ON r.program_id = p.reference_id 
WHERE  f.active = 1;
GO
