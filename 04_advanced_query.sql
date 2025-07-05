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
-- Generate complete time series with all seconds between min and max timestamps
time_series AS (
    SELECT 
        room,
        generate_series(
            MIN(timestamp_second),
            MAX(timestamp_second),
            INTERVAL '1 second'
        ) AS timestamp_second
    FROM v_timestamps
    GROUP BY room
),
-- Fill missing timestamps with previous values using window functions
filled_data AS (
    SELECT 
        ts.room,
        ts.timestamp_second,
        -- Fill V values: use the most recent V value up to current timestamp
        FIRST_VALUE(sdp.V) OVER (
            PARTITION BY ts.room 
            ORDER BY sdp.timestamp_second DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS V,
        -- Fill R values: use the most recent R value up to current timestamp
        FIRST_VALUE(sdp.R) OVER (
            PARTITION BY ts.room 
            ORDER BY sdp.timestamp_second DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS R
    FROM time_series ts
    LEFT JOIN sensor_data_pivoted sdp ON ts.room = sdp.room 
        AND sdp.timestamp_second <= ts.timestamp_second
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
FROM filled_data
ORDER BY room, timestamp_second; 