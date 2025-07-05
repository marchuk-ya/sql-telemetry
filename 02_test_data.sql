INSERT INTO rooms (name) VALUES 
    ('room_A'),
    ('room_B');

-- Insert sensors for room_A: 1 sensor for V and 2 sensors for R
INSERT INTO sensors (name, room_id, sensor_type) VALUES 
    ('sensor_V_A1', (SELECT id FROM rooms WHERE name = 'room_A'), 'V'),
    ('sensor_R_A1', (SELECT id FROM rooms WHERE name = 'room_A'), 'R'),
    ('sensor_R_A2', (SELECT id FROM rooms WHERE name = 'room_A'), 'R');

-- Insert sensors for room_B: 2 sensors for V and 3 sensors for R
INSERT INTO sensors (name, room_id, sensor_type) VALUES 
    ('sensor_V_B1', (SELECT id FROM rooms WHERE name = 'room_B'), 'V'),
    ('sensor_V_B2', (SELECT id FROM rooms WHERE name = 'room_B'), 'V'),
    ('sensor_R_B1', (SELECT id FROM rooms WHERE name = 'room_B'), 'R'),
    ('sensor_R_B2', (SELECT id FROM rooms WHERE name = 'room_B'), 'R'),
    ('sensor_R_B3', (SELECT id FROM rooms WHERE name = 'room_B'), 'R');

-- Insert test measurements with various scenarios
-- Scenario 1: Normal measurements for all sensors
INSERT INTO measurements (sensor_id, value, timestamp) VALUES 
    ((SELECT id FROM sensors WHERE name = 'sensor_V_A1'), 50.1, '2024-12-30T10:00:01.000001'),
    ((SELECT id FROM sensors WHERE name = 'sensor_R_A1'), 10.5, '2024-12-30T10:00:01.000002'),
    ((SELECT id FROM sensors WHERE name = 'sensor_R_A2'), 10.7, '2024-12-30T10:00:01.000003'),
    
    ((SELECT id FROM sensors WHERE name = 'sensor_V_B1'), 48.2, '2024-12-30T10:00:01.000004'),
    ((SELECT id FROM sensors WHERE name = 'sensor_V_B2'), 48.8, '2024-12-30T10:00:01.000005'),
    ((SELECT id FROM sensors WHERE name = 'sensor_R_B1'), 12.1, '2024-12-30T10:00:01.000006'),
    ((SELECT id FROM sensors WHERE name = 'sensor_R_B2'), 12.3, '2024-12-30T10:00:01.000007'),
    ((SELECT id FROM sensors WHERE name = 'sensor_R_B3'), 12.0, '2024-12-30T10:00:01.000008');

-- Scenario 2: Missing measurement from one sensor (sensor_R_A2 missing at 10:00:02)
INSERT INTO measurements (sensor_id, value, timestamp) VALUES 
    ((SELECT id FROM sensors WHERE name = 'sensor_V_A1'), 50.2, '2024-12-30T10:00:02.000001'),
    ((SELECT id FROM sensors WHERE name = 'sensor_R_A1'), 10.6, '2024-12-30T10:00:02.000002'),
    
    ((SELECT id FROM sensors WHERE name = 'sensor_V_B1'), 48.3, '2024-12-30T10:00:02.000003'),
    ((SELECT id FROM sensors WHERE name = 'sensor_V_B2'), 48.9, '2024-12-30T10:00:02.000004'),
    ((SELECT id FROM sensors WHERE name = 'sensor_R_B1'), 12.2, '2024-12-30T10:00:02.000005'),
    ((SELECT id FROM sensors WHERE name = 'sensor_R_B2'), 12.4, '2024-12-30T10:00:02.000006'),
    ((SELECT id FROM sensors WHERE name = 'sensor_R_B3'), 12.1, '2024-12-30T10:00:02.000007');

-- Scenario 3: Only R measurements, no V measurements (10:00:03)
INSERT INTO measurements (sensor_id, value, timestamp) VALUES 
    ((SELECT id FROM sensors WHERE name = 'sensor_R_A1'), 10.8, '2024-12-30T10:00:03.000001'),
    ((SELECT id FROM sensors WHERE name = 'sensor_R_A2'), 10.9, '2024-12-30T10:00:03.000002'),
    
    ((SELECT id FROM sensors WHERE name = 'sensor_R_B1'), 12.5, '2024-12-30T10:00:03.000003'),
    ((SELECT id FROM sensors WHERE name = 'sensor_R_B2'), 12.6, '2024-12-30T10:00:03.000004'),
    ((SELECT id FROM sensors WHERE name = 'sensor_R_B3'), 12.3, '2024-12-30T10:00:03.000005');

-- Scenario 4: Only V measurements, no R measurements (10:00:04)
INSERT INTO measurements (sensor_id, value, timestamp) VALUES 
    ((SELECT id FROM sensors WHERE name = 'sensor_V_A1'), 50.3, '2024-12-30T10:00:04.000001'),
    
    ((SELECT id FROM sensors WHERE name = 'sensor_V_B1'), 48.4, '2024-12-30T10:00:04.000002'),
    ((SELECT id FROM sensors WHERE name = 'sensor_V_B2'), 49.0, '2024-12-30T10:00:04.000003');

-- Different timestamps within the same second
INSERT INTO measurements (sensor_id, value, timestamp) VALUES 
    ((SELECT id FROM sensors WHERE name = 'sensor_V_A1'), 50.1, '2024-12-30T10:00:05.000001'),
    ((SELECT id FROM sensors WHERE name = 'sensor_V_A1'), 50.2, '2024-12-30T10:00:05.000032'),
    ((SELECT id FROM sensors WHERE name = 'sensor_R_A1'), 10.5, '2024-12-30T10:00:05.000001'),
    ((SELECT id FROM sensors WHERE name = 'sensor_R_A2'), 10.6, '2024-12-30T10:00:05.000003'); 