-- Create the Sprint BackLog Table
CREATE TABLE IF NOT EXISTS sprint_backlog (
    sprint_backlog_item_id SERIAL PRIMARY KEY,                       -- Unique ID for each sprint backlog item
    sprint_id INT NOT NULL,                                          -- Sprint associated with the backlog item
    product_backlog_item_id INT,                                                  -- Product Backlog item ID (linked to product backlog)
    assigned_team_member INT NOT NULL,                               -- Team member responsible for the backlog item
    status VARCHAR(30) CHECK (status IN ('To Do', 'In Progress', 'Blocked', 'In Review', 'Done', 'Carried Over', 'Removed')) DEFAULT 'To Do',
    -- Status values:
    -- 'To Do'         : Item is yet to be started.
    -- 'In Progress'   : Item is being actively worked on.
    -- 'Blocked'       : Item cannot proceed due to an issue.
    -- 'In Review'     : Item is under review for quality or acceptance criteria.
    -- 'Done'          : Item has been completed.
    -- 'Carried Over'  : Item was not completed during the sprint and will carry over to the next sprint.
    -- 'Removed'       : Item was removed from the sprint backlog, often for re-prioritization.
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,                  -- Timestamp of creation
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Timestamp of the last update
    UNIQUE (sprint_id, product_backlog_item_id),                                  -- Ensures a unique combination of sprint and product backlog item
    FOREIGN KEY (assigned_team_member) REFERENCES users(user_id),     -- References the assigned team member
    FOREIGN KEY (sprint_id) REFERENCES sprints(sprint_id),            -- References the sprint
    FOREIGN KEY (product_backlog_item_id) REFERENCES product_backlog(backlog_item_id)  -- Links to product backlog