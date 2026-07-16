WITH cleaned_ucars as (
SELECT id, price, year, odometer, manufacturer, LOWER(regexp_replace(model, '^\d{4}\s+', '')) AS model, type, 
cylinders, COALESCE(condition, 'unknown') AS condition, 
COALESCE(title_status,'unknown') AS title_status, fuel, COALESCE(transmission, 'unknown') AS transmission, 
COALESCE(drive,'unknown') AS drive
FROM raw_used_cars
WHERE price BETWEEN 500 AND 200000
AND ((year >= 2024 AND odometer >= 0) OR (year <= 2023 AND odometer >= 500))
AND year IS NOT NULL
AND odometer IS NOT NULL
AND odometer <= 300000
AND year >= 1990
),
c_ranks as (
SELECT manufacturer, model, cylinders, COUNT(*) as cnt, 
ROW_NUMBER() OVER(PARTITION BY manufacturer, model ORDER BY COUNT(*) DESC) as ranks
FROM cleaned_ucars
WHERE cylinders IS NOT NULL
GROUP BY manufacturer, model, cylinders
),
c_first as (
SELECT manufacturer, model, cylinders as typical_cylinders
FROM c_ranks
WHERE ranks = 1
),
m_ranks as (
SELECT model, manufacturer, COUNT(*) as cnt,
ROW_NUMBER() OVER(PARTITION BY model ORDER BY COUNT(*) DESC) as ranks
FROM cleaned_ucars
WHERE manufacturer IS NOT NULL
GROUP BY model, manufacturer
),
m_first as (
SELECT model, manufacturer as typical_manufacturer
FROM m_ranks
WHERE ranks = 1
),
final AS (
SELECT 
u.id, u.price, u.year, u.odometer, 
COALESCE(u.manufacturer, m.typical_manufacturer, 'unknown') as manufacturer,
u.model, u.type, 
COALESCE(u.cylinders,c.typical_cylinders,'unknown') as cylinders, u.condition, u.title_status, u.fuel, u.transmission, u.drive
FROM cleaned_ucars u
LEFT JOIN c_first c
ON u.manufacturer = c.manufacturer AND u.model = c.model
LEFT JOIN m_first m
ON u.model = m.model
)

SELECT * 
FROM final;