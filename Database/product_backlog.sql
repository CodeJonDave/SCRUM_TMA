-- Start transaction to ensure all operations are executed together
-- If any operation fails, the entire transaction is rolled back to maintain consistency
BEGIN TRANSACTION;

-- 1. Create the product_backlog table

CREATE TABLE IF NOT EXISTS product_backlog
    (backlog_item_id SERIAL PRIMARY KEY, -- Unique ID for each backlog item
 product_id INTEGER NOT NULL, -- References the product associated with the backlog item
 item_description TEXT NOT NULL, -- Description of the backlog item
 priority INTEGER NOT NULL, -- Priority of the backlog item
 status status VARCHAR(30) CHECK (status IN ('TO_DO',
                                             'IN_PROGRESS',
                                             'BLOCKED',
                                             'IN_REVIEW',
                                             'DONE')) DEFAULT 'TO_DO', -- Status values:
 -- 'To Do'        : Item is yet to be started.
 -- 'In Progress'  : Item is currently being worked on.
 -- 'Blocked'      : Item is blocked due to some external dependency.
 -- 'In Review'    : Item is complete and under review for quality/approval.
 -- 'Done'         : Item is completed.
 due_date DATE, -- Expected completion date for the backlog item
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Timestamp of when the backlog item was created
 updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Timestamp when the backlog item was last updated
 -- Ensure the backlog is deleted if product is deleted
 CONSTRAINT fk_product_id
     FOREIGN KEY (product_id) REFERENCES products(product_id) -- Reference to the 'products' table
 ON DELETE CASCADE);

-- 2. Create indexes for fast lookups

CREATE INDEX idx_product_backlog_priority ON product_backlog (priority);


CREATE INDEX idx_product_backlog_product_id ON product_backlog (product_id);


CREATE INDEX idx_product_backlog_status ON product_backlog (status);


CREATE INDEX idx_product_backlog_due_date ON product_backlog (priority);

-- 3. Create the products_backlog_olap table to log changes in the products table

CREATE TABLE IF NOT EXISTS products_backlog_olap (log_id SERIAL PRIMARY KEY, -- Unique identifier for each log entry.
 backlog_item_id INTEGER, -- The ID of the backlog item that changed.
 operation_type VARCHAR(10) NOT NULL, -- The type of operation: 'INSERT', 'UPDATE', or 'DELETE'.
 data JSONB NOT NULL, -- Stores the full product data in JSONB format.
 operation_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Timestamp of when the operation occurred.
);

-- 4. Define function to log changes in the product_backlog table

CREATE OR REPLACE FUNCTION log_product_backlog_changes() RETURNS TRIGGER AS $$
BEGIN
    -- Log insert operations
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO products_backlog_olap (backlog_item_id, operation_type, data)
        VALUES (NEW.backlog_item_id, 'INSERT', row_to_json(NEW));
        RETURN NEW;

    -- Log update operations
    ELSIF (TG_OP = 'UPDATE') THEN
        -- Log update
        INSERT INTO products_backlog_olap (backlog_item_id, operation_type, data)
        VALUES (NEW.backlog_item_id, 'UPDATE', row_to_json(NEW));
        RETURN NEW;

    -- Set archived status then log delete operations
    ELSIF (TG_OP = 'DELETE') THEN
        -- Log delete
        INSERT INTO products_backlog_olap (backlog_item_id, operation_type, data)
        VALUES (OLD.backlog_item_id, 'DELETE', OLD.backlog_item_id);
        -- Delete
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql; -- Defines the function in PL/pgSQL language

-- 5. Create a trigger to call the log_product_backlog_changes function on any insert, update. or delete

CREATE TRIGGER trg_product_backlog_changes AFTER
INSERT
OR
UPDATE
OR
DELETE ON product_backlog
FOR EACH ROW EXECUTE FUNCTION log_product_backlog_changes();

-- Commit the transaction to finalize the operation

COMMIT;