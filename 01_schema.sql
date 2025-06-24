CREATE TABLE rooms (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE sensors (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    room_id INTEGER NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,
    sensor_type CHAR(1) NOT NULL CHECK (sensor_type IN ('V', 'R')),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,

    UNIQUE(room_id, name)
);

CREATE TABLE measurements (
    id SERIAL PRIMARY KEY,
    sensor_id INTEGER NOT NULL REFERENCES sensors(id) ON DELETE CASCADE,
    value DECIMAL(10, 3) NOT NULL,
    timestamp TIMESTAMPTZ NOT NULL CHECK (timestamp <= NOW()),
    created_at TIMESTAMPTZ DEFAULT clock_timestamp()
);

CREATE INDEX idx_sensors_room_id ON sensors(room_id);
CREATE INDEX idx_sensors_type ON sensors(sensor_type);
CREATE INDEX idx_sensors_type_room_id ON sensors(sensor_type, room_id);

CREATE INDEX idx_measurements_sensor_id ON measurements(sensor_id);
CREATE INDEX idx_measurements_timestamp ON measurements(timestamp);
CREATE INDEX idx_measurements_sensor_timestamp ON measurements(sensor_id, timestamp);
CREATE INDEX idx_measurements_sensor_timestamp_desc ON measurements(sensor_id, timestamp DESC);