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
-- Get all timestamps where V measurements exist (main parameter)
v_timestamps AS (
    SELECT DISTINCT 
        room,
        timestamp_second
    FROM sensor_averages 
    WHERE sensor_type = 'V'
),
-- Pivot sensor data to get V and R values
sensor_data_pivoted AS (
    SELECT 
        room,
        timestamp_second,
        MAX(CASE WHEN sensor_type = 'V' THEN avg_value END) AS V,
        MAX(CASE WHEN sensor_type = 'R' THEN avg_value END) AS R
    FROM sensor_averages
    GROUP BY room, timestamp_second
),
-- For each V timestamp, find the most recent R value
v_with_previous_r AS (
    SELECT 
        vt.room,
        vt.timestamp_second,
        sdp.V,
        FIRST_VALUE(sdp.R) OVER (
            PARTITION BY vt.room 
            ORDER BY sdp.timestamp_second DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS R
    FROM v_timestamps vt
    LEFT JOIN sensor_data_pivoted sdp ON vt.room = sdp.room 
        AND sdp.timestamp_second <= vt.timestamp_second
        AND sdp.R IS NOT NULL
),
r_with_previous_v AS (
    SELECT 
        room,
        timestamp_second,
        FIRST_VALUE(V) OVER (
            PARTITION BY room 
            ORDER BY timestamp_second DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS V,
        R
    FROM sensor_data_pivoted 
    WHERE R IS NOT NULL
),
-- Combine V-driven and R-driven data
combined_data AS (
    SELECT room, timestamp_second, V, R FROM v_with_previous_r
    UNION
    SELECT room, timestamp_second, V, R FROM r_with_previous_v
),
final_data AS (
    SELECT 
        room,
        timestamp_second,
        MAX(V) AS V,
        MAX(R) AS R
    FROM combined_data
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
FROM final_data
ORDER BY room, timestamp_second; 