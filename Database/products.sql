-- Start transaction to ensure all operations are executed together
BEGIN TRANSACTION;

-- 1. Create the products table to store product details
CREATE TABLE IF NOT EXISTS products (
    product_id SERIAL PRIMARY KEY,                                      -- Auto-incremented product identifier.
    product_name VARCHAR(255) NOT NULL,                                 -- Name of the product, required.
    description TEXT,                                                   -- Optional detailed product description.
    product_owner_id UUID NOT NULL,                                     -- References the owner in the 'users' table.
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,                     -- Timestamp when the product was created.
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,                     -- Timestamp when the product was last updated.

    -- Ensure the product owner exists in the 'users' table
    CONSTRAINT fk_product_owner FOREIGN KEY (product_owner_id)
        REFERENCES users(user_id)                                       -- Reference to the 'users' table.
        ON UPDATE CASCADE                                               -- Update products if the user_id changes.
);

-- 2. Create an index on the product_owner_id for faster lookups by owner
CREATE INDEX idx_product_owner ON products (product_owner_id);
CREATE INDEX idx_product_name ON products (product_name);

-- 3. Create the products_olap table to log changes in the products table
CREATE TABLE IF NOT EXISTS products_olap (
    log_id SERIAL PRIMARY KEY,                                          -- Unique identifier for each log entry.
    product_id INTEGER,                                                 -- The ID of the product that changed.
    operation_type VARCHAR(10) NOT NULL,                                -- The type of operation: 'INSERT', 'UPDATE', or 'DELETE'.
    data JSONB NOT NULL,                                                -- Stores the full product data in JSONB format.
    operation_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP                  -- Timestamp of when the operation occurred.
);

-- 4. Define the function to log changes to the products table
CREATE OR REPLACE FUNCTION log_product_changes()
RETURNS TRIGGER AS $$
BEGIN
    -- Log insert operations
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO products_olap (product_id, operation_type, data)
        VALUES (NEW.product_id, 'INSERT', row_to_json(NEW));            -- Logs the new product data.
        RETURN NEW;

    -- Log update operations
    ELSIF (TG_OP = 'UPDATE') THEN
        -- Update 'updated_at' timestamp on each update
        NEW.updated_at = CURRENT_TIMESTAMP;                             -- Manually update 'updated_at' on update.

        INSERT INTO products_olap (product_id, operation_type, data)
        VALUES (NEW.product_id, 'UPDATE', row_to_json(NEW));            -- Logs the updated product data.
        RETURN NEW;

    -- Log delete operations
    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO products_olap (product_id, operation_type, data)
        VALUES (OLD.product_id, 'DELETE', row_to_json(OLD));            -- Logs the deleted product data.
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;                                                    -- Defines the function in PL/pgSQL language.

-- 5. Create a trigger to call the log_product_changes function on any insert, update, or delete
CREATE TRIGGER trg_products_changes
AFTER INSERT OR UPDATE OR DELETE ON products
FOR EACH ROW EXECUTE FUNCTION log_product_changes();                    -- The trigger executes the logging function for every affected row.

-- Commit the transaction to apply all changes
COMMIT;
