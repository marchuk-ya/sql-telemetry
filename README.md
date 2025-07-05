# Telemetry System SQL

### Tables (01_schema.sql):
1. rooms - rooms with unique names
2. sensors - sensors with types V (voltage) or R (resistance)
3. measurements - measurements with timestamps

### Relationships (01_schema.sql):
- Each room has many sensors (1:N)
- Each sensor has many measurements (1:N)
- A sensor can only be in one room
- Sensor names must be unique within a room (but can be repeated across different rooms)

### Test Data (02_test_data.sql):
- room_A: 1 V sensor + 2 R sensors
- room_B: 2 V sensors + 3 R sensors

### Basic Query (03_basic_query.sql)
- Groups data by seconds
- Calculates average values for each sensor type
- Calculates current I = V / R
- Shows NULL if V or R is missing

### Advanced Query (04_advanced_query.sql)
- Uses V as the primary parameter for aggregation
- Generates complete time series with all seconds between min and max timestamps
- Fills missing timestamps with the most recent previous values (forward fill)
- Ensures data completeness through window functions and time series gap filling
