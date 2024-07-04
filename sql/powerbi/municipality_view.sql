IF OBJECT_ID('dbo.municipality_view', 'V') IS NOT NULL
    DROP VIEW dbo.municipality_view;
GO
CREATE VIEW dbo.municipality_view AS
SELECT 
    gz.id AS municipality_id,
    gz.name AS municipality_name,
    gz.parent_id AS province_id
FROM 
    public_geographic_zone gz
JOIN 
    public_geographic_level gl
ON 
    gz.level_id = gl.id
WHERE 
    gl.level = 3;


