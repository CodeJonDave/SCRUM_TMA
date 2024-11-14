-- Start transaction to ensure all operations are executed together
-- If any operation fails, the entire transaction is rolled back to maintain consistency
BEGIN TRANSACTION;

-- 1. Create the sprints table to store sprint details
CREATE TABLE IF NOT EXISTS sprints (
    sprint_id SERIAL PRIMARY KEY,                           -- Unique ID for each sprint
    product_id INTEGER NOT NULL,                            -- References the product for which the sprint is happening
    start_date DATE NOT NULL,                               -- Start date of the sprint
    end_date DATE NOT NULL,                                 -- End date of the sprint
    status VARCHAR(30) CHECK (status IN ('Planned', 'Active', 'Completed', 'Canceled')) DEFAULT 'Planned',
    -- Status values:
        -- 'Planned'        : The sprint is scheduled but not yet started.
        -- 'Active'         : The sprint is currently in progress.
        -- 'Completed'      : The sprint has finished, and all committed work is done.
        -- 'Cancelled'      : The sprint has been cancelled before completion.
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,         -- Timestamp when the sprint was created
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,         -- TimeStamp when the sprint was updated last

    -- Ensure that the sprints are deleted if the product is deleted
    CONSTRAINT fk_product_id FOREIGN KEY (product_id)
        REFERENCES products(product_id)                     -- Reference to the 'products' table
        ON DELETE CASCADE
);

-- 2. Indexes for faster operations
CREATE INDEX idx_product_id ON sprints (product_id);
CREATE INDEX idx_status ON sprints (status);
CREATE INDEX idx_start_date ON sprints (start_date);
CREATE INDEX idx_end_date ON sprints (end_date);

-- 3. Create the sprints_olap table to log changes in the sprints table
CREATE TABLE IF NOT EXISTS sprints_olap (
    log_id SERIAL PRIMARY KEY,                              -- Unique identifier for each log
    sprint_id INTEGER,                                      -- The ID of the sprint item that changed
    operation_type VARCHAR(10) NOT NULL,
    data JSONB NOT NULL,                                    -- Stores info into JSONB format
    operation_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP      -- Timestamp of the log
);

-- 4. Define function to log changes in the sprint table
CREATE OR REPLACE FUNCTION log_sprints_changes()
RETURNS TRIGGER AS $$
BEGIN
    --Log insert operations
    IF(TG_OP = 'INSERT') THEN
        INSERT INTO sprints_olap(sprint_id, operation_type, data)
        VALUES (New.sprint_id, 'INSERT', row_to_json(NEW));
        RETURN NEW;

    -- Log update operations
    ELSIF (TG_OP = 'UPDATE') THEN
        -- Log update
        INSERT INTO sprints_olap (product_id, operation_type, data)
        VALUES (NEW.sprint_id, 'UPDATE', row_to_json(NEW));
        RETURN NEW;

    -- Log delete operations
    ELSIF (TG_OP ='DELETE') THEN
        INSERT INTO sprints_olap (sprint_id, operation_type, data)
        VALUES (OLD.sprint_id, 'DELETE', OLD.sprint_id);
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- 5. Create a trigger to call the log_sprints_changes function on any insert, update, or delete
CREATE TRIGGER trg_sprints_changes
AFTER INSERT OR UPDATE OR DELETE ON sprints
FOR EACH ROW EXECUTE FUNCTION log_sprints_changes();


-- Commit the transaction to finalize the operation
COMMIT;