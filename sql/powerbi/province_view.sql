IF OBJECT_ID('dbo.province_view', 'V') IS NOT NULL
    DROP VIEW dbo.province_view;
GO
GO
CREATE VIEW [dbo].[province_view]
AS SELECT 
    gz.id AS province_id,
    gz.name AS province_name
FROM 
    public_geographic_zone gz
JOIN 
    public_geographic_level gl
ON 
    gz.level_id = gl.id
WHERE 
    gl.level = 2;



