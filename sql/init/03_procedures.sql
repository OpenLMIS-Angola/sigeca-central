CREATE PROCEDURE ms.synchronize_facilities(payload JSON)
LANGUAGE plpgsql AS $$
DECLARE
    update_time TIMESTAMPTZ;
    fac JSON;
    serv JSON;
    current_facility_id UUID;
    current_service_id UUID;
BEGIN
    -- Procedure to process Mapa Sanitario payload and save facilities, services and links between them in the ms schema tables
    SELECT NOW() INTO update_time;

    FOR fac IN SELECT * FROM json_array_elements(payload->'unidades')
    LOOP
        -- Update or insert the facility
        IF (SELECT count(*) FROM ms.facility WHERE code = fac->>'codigo') > 0 THEN
            UPDATE ms.facility
            SET reference_id = null, is_deleted = false, last_updated = update_time, name = fac->>'nome', acronym = fac->>'sigla', category = fac->>'categoria', ownership = fac->>'propriedade', management = fac->>'gestao', municipality = fac->>'municipio', province = fac->>'provincia', is_operational = (fac->>'funcionamento')::BOOLEAN, latitude = fac->>'latitude', longitude = fac->>'longitude'
            WHERE code = fac->>'codigo';
        ELSE
            INSERT INTO ms.facility(reference_id, is_deleted, last_updated, name, code, acronym, category, ownership, management, municipality, province, is_operational, latitude, longitude)
            VALUES (null, false, update_time, fac->>'nome', fac->>'codigo', fac->>'sigla', fac->>'categoria', fac->>'propriedade', fac->>'gestao', fac->>'municipio', fac->>'provincia', (fac->>'funcionamento')::BOOLEAN, fac->>'latitude', fac->>'longitude');
        END IF;

        -- Update or insert services associated with the facility      
        FOR serv IN SELECT * FROM json_array_elements(fac->'servicos_oferecidos')
        LOOP
            IF (SELECT count(*) FROM ms.service WHERE code = serv->>'servico_oferecido_id') > 0 THEN
                UPDATE ms.service
                SET reference_id = null, is_deleted = false, last_updated = update_time, name = serv->>'nome'
                WHERE code = serv->>'servico_oferecido_id';
            ELSE
                INSERT INTO ms.service(reference_id, is_deleted, last_updated, name, code)
                VALUES (null, false, update_time, serv->>'nome', serv->>'servico_oferecido_id');
            END IF;

            -- Update facility service link
            SELECT id FROM ms.facility WHERE code = fac->>'codigo' LIMIT 1 INTO current_facility_id;
            select id FROM ms.service WHERE code = serv->>'servico_oferecido_id' LIMIT 1 INTO current_service_id;

            IF (SELECT count(*) FROM ms.facility_service fs WHERE fs.facility_id = current_facility_id and fs.service_id = current_service_id) > 0 THEN
                UPDATE ms.facility_service
                SET reference_id = NULL, is_deleted = false, last_updated = update_time
                WHERE facility_id = current_facility_id and service_id = current_service_id;
            ELSE
                INSERT INTO ms.facility_service(reference_id, is_deleted, last_updated, facility_id, service_id)
                VALUES (null, false, update_time, current_facility_id, current_service_id);
            END IF;
        END LOOP;
    END loop;

    -- Mark all records not present in payload as deleted
    UPDATE ms.facility
    SET is_deleted = true, last_updated = update_time
    WHERE last_updated < update_time AND is_deleted = false;

    UPDATE ms.service
    SET is_deleted = true, last_updated = update_time
    WHERE last_updated < update_time AND is_deleted = false;

    UPDATE ms.facility_service
    SET is_deleted = true, last_updated = update_time
    WHERE last_updated < update_time AND is_deleted = false;
end;
$$;
