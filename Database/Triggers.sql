BEGIN TRANSACTION;

-- Update Timestamp
-- Trigger to automatically update the updated_at field in any table when a row is modified
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply the update_timestamp trigger to relevant tables
CREATE TRIGGER update_users_timestamp
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER update_product_backlog_timestamp
BEFORE UPDATE ON product_backlog
FOR EACH ROW
EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER update_sprints_timestamp
BEFORE UPDATE ON sprints
FOR EACH ROW
EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER update_sprint_backlog_timestamp
BEFORE UPDATE ON sprint_backlog
FOR EACH ROW
EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER update_daily_scrum_updates_timestamp
BEFORE UPDATE ON daily_scrum_updates
FOR EACH ROW
EXECUTE FUNCTION update_timestamp();

-- Create Audit Logs
-- Trigger to automatically insert an entry into the audit_log when any table is modified
CREATE OR REPLACE FUNCTION audit_log_trigger()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
        INSERT INTO audit_log (entity_type, entity_id, action_performed, action_by, action_at)
        VALUES (TG_TABLE_NAME, NEW.user_id, TG_OP, CURRENT_USER, CURRENT_TIMESTAMP);
    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO audit_log (entity_type, entity_id, action_performed, action_by, action_at)
        VALUES (TG_TABLE_NAME, OLD.user_id, TG_OP, CURRENT_USER, CURRENT_TIMESTAMP);
    END IF;

    -- Reset the sequences associated with each table
    IF TG_TABLE_NAME = 'users' THEN
        PERFORM setval('user_id_seq', (SELECT COALESCE(MAX(user_id), 1) FROM users));
    ELSIF TG_TABLE_NAME = 'products' THEN
        PERFORM setval('product_id_seq', (SELECT COALESCE(MAX(product_id), 1) FROM products));
    ELSIF TG_TABLE_NAME = 'product_backlog' THEN
        PERFORM setval('backlog_item_id_seq', (SELECT COALESCE(MAX(backlog_item_id), 1) FROM product_backlog));
    ELSIF TG_TABLE_NAME = 'sprint_backlog' THEN
        PERFORM setval('sprint_backlog_item_id_seq', (SELECT COALESCE(MAX(sprint_backlog_item_id), 1) FROM sprint_backlog));
    ELSIF TG_TABLE_NAME = 'sprints' THEN
        PERFORM setval('sprint_id_seq', (SELECT COALESCE(MAX(sprint_id), 1) FROM sprints));
    ELSIF TG_TABLE_NAME = 'daily_scrums' THEN
        PERFORM setval('daily_scrum_id_seq', (SELECT COALESCE(MAX(daily_scrum_id), 1) FROM daily_scrums));
    ELSIF TG_TABLE_NAME = 'increments' THEN
        PERFORM setval('increment_id_seq', (SELECT COALESCE(MAX(increment_id), 1) FROM increments));
    ELSIF TG_TABLE_NAME = 'impediments' THEN
        PERFORM setval('impediment_id_seq', (SELECT COALESCE(MAX(impediment_id), 1) FROM impediments));
    ELSIF TG_TABLE_NAME = 'sprint_goals' THEN
        PERFORM setval('sprint_goal_id_seq', (SELECT COALESCE(MAX(sprint_goal_id), 1) FROM sprint_goals));
    ELSIF TG_TABLE_NAME = 'burndown_chart' THEN
        PERFORM setval('burndown_id_seq', (SELECT COALESCE(MAX(burndown_id), 1) FROM burndown_chart));
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply the audit log trigger to the relevant tables
CREATE TRIGGER audit_log_on_users
AFTER INSERT OR UPDATE OR DELETE ON users
FOR EACH ROW
EXECUTE FUNCTION audit_log_trigger();

CREATE TRIGGER audit_log_on_products
AFTER INSERT OR UPDATE OR DELETE ON products
FOR EACH ROW
EXECUTE FUNCTION audit_log_trigger();

CREATE TRIGGER audit_log_on_backlog
AFTER INSERT OR UPDATE OR DELETE ON product_backlog
FOR EACH ROW
EXECUTE FUNCTION audit_log_trigger();

CREATE TRIGGER audit_log_on_sprints
AFTER INSERT OR UPDATE OR DELETE ON sprints
FOR EACH ROW
EXECUTE FUNCTION audit_log_trigger();

CREATE TRIGGER audit_log_on_sprint_reviews
AFTER INSERT OR UPDATE OR DELETE ON sprint_reviews
FOR EACH ROW
EXECUTE FUNCTION audit_log_trigger();

CREATE TRIGGER audit_log_on_sprint_retrospectives
AFTER INSERT OR UPDATE OR DELETE ON sprint_retrospectives
FOR EACH ROW
EXECUTE FUNCTION audit_log_trigger();

CREATE TRIGGER audit_log_on_sprint_backlog
AFTER INSERT OR UPDATE OR DELETE ON sprint_backlog
FOR EACH ROW
EXECUTE FUNCTION audit_log_trigger();

CREATE TRIGGER audit_log_on_sprint_goals
AFTER INSERT OR UPDATE OR DELETE ON sprint_goals
FOR EACH ROW
EXECUTE FUNCTION audit_log_trigger();

CREATE TRIGGER audit_log_on_increments
AFTER INSERT OR UPDATE OR DELETE ON increments
FOR EACH ROW
EXECUTE FUNCTION audit_log_trigger();

CREATE TRIGGER audit_log_on_impediments
AFTER INSERT OR UPDATE OR DELETE ON impediments
FOR EACH ROW
EXECUTE FUNCTION audit_log_trigger();

CREATE TRIGGER audit_log_on_daily_scrums
AFTER INSERT OR UPDATE OR DELETE ON daily_scrums
FOR EACH ROW
EXECUTE FUNCTION audit_log_trigger();

CREATE TRIGGER audit_log_on_daily_scrum_updates
AFTER INSERT OR UPDATE OR DELETE ON daily_scrum_updates
FOR EACH ROW
EXECUTE FUNCTION audit_log_trigger();

COMMIT;