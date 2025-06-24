-- Calculate average values for each sensor type per room per second
WITH sensor_averages AS (
    SELECT 
        r.name AS room,
        DATE_TRUNC('second', m.timestamp) AS timestamp_second,
        s.sensor_type,
        AVG(m.value) AS avg_value
    FROM measurements m
    JOIN sensors s ON m.sensor_id = s.id
    JOIN rooms r ON s.room_id = r.id
    GROUP BY r.name, DATE_TRUNC('second', m.timestamp), s.sensor_type
),
room_data AS (
    SELECT 
        room,
        timestamp_second,
        MAX(CASE WHEN sensor_type = 'V' THEN avg_value END) AS V,
        MAX(CASE WHEN sensor_type = 'R' THEN avg_value END) AS R
    FROM sensor_averages
    GROUP BY room, timestamp_second
)

SELECT 
    room,
    timestamp_second AS timestamp,
    CASE 
        WHEN V IS NOT NULL AND R IS NOT NULL AND R != 0 
        THEN ROUND((V / R)::DECIMAL(10, 3), 3)
    END AS I,
    ROUND(V::DECIMAL(10, 3), 3) AS V,
    ROUND(R::DECIMAL(10, 3), 3) AS R
FROM room_data
ORDER BY room, timestamp_second; 