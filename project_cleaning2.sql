SELECT @@autocommit;
SET autocommit = 1;

UPDATE service_desk_tickets_clean
SET category = CASE
    WHEN TRIM(category) IN ('ACC', 'access', 'Access', 'Acess') THEN 'Access'
    WHEN TRIM(category) IN ('E-mail', 'email', 'Emial', 'Email') THEN 'Email'
    WHEN TRIM(category) IN ('Hard ware', 'Hardware', 'HW') THEN 'Hardware'
    WHEN TRIM(category) IN ('network', 'Network', 'Netwrok', 'NW') THEN 'Network'
    WHEN TRIM(category) IN ('software', 'Software', 'Softwear', 'SW') THEN 'Software'
    ELSE TRIM(category)
END;

UPDATE service_desk_tickets_clean
SET priority = CONCAT(UPPER(LEFT(priority,1)), LOWER(SUBSTRING(priority,2)));

COMMIT;

SELECT DISTINCT category FROM service_desk_tickets_clean ORDER BY category;

SELECT DISTINCT priority FROM service_desk_tickets_clean ORDER BY priority;

