BEGIN TRANSACTION;


-- Create the users table to store information about users
CREATE TABLE IF NOT EXISTS users (
    user_id SERIAL PRIMARY KEY,                -- Unique ID for each user, automatically increments
    username VARCHAR(100) UNIQUE NOT NULL,     -- Username for the user, must be unique and cannot be null
    first_name VARCHAR(100) NOT NULL,          -- First name of the user, cannot be null
    last_name VARCHAR(100) NOT NULL,           -- Last name of the user, cannot be null
    email VARCHAR(200) UNIQUE NOT NULL,        -- Email address of the user, must be unique and cannot be null
    start_date DATE NOT NULL,                  -- Date when the user started/starts, must be provided
    title VARCHAR(50) NOT NULL,                      -- title that determines permissions
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- Timestamp when the record is created, defaults to current time
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP  -- Timestamp when the record is updated, auto-updates on change
   );

-- Create the products table to store products owned by users
CREATE TABLE IF NOT EXISTS products (
    product_id SERIAL PRIMARY KEY,             -- Unique ID for each product
    product_name VARCHAR(100) UNIQUE NOT NULL, -- Product name, must be unique
    product_owner_id INT,                      -- ID of the user who owns the product
    FOREIGN KEY (product_owner_id) REFERENCES users(user_id)  -- Foreign key to reference the user
);

-- Create the product backlog table
CREATE TABLE IF NOT EXISTS product_backlog (
    backlog_item_id SERIAL PRIMARY KEY,                             -- Unique ID for each backlog item
    product_id INT NOT NULL,                                         -- References the product associated with the backlog item
    item_description TEXT NOT NULL,                                  -- Description of the backlog item
    priority INT NOT NULL,                                           -- Priority of the backlog item
    status VARCHAR(30) CHECK (status IN ('To Do', 'In Progress', 'Blocked', 'In Review', 'Done', 'Archived')) DEFAULT 'To Do',
    -- Status values:
    -- 'To Do'        : Item is yet to be started.
    -- 'In Progress'  : Item is currently being worked on.
    -- 'Blocked'      : Item is blocked due to some external dependency.
    -- 'In Review'    : Item is complete and under review for quality/approval.
    -- 'Done'         : Item is completed.
    -- 'Archived'     : Item is no longer active, archived for historical purposes.
    due_date DATE,                                                   -- Expected completion date for the backlog item
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,                  -- Timestamp of when the backlog item was created
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Timestamp when the backlog item was last updated
    FOREIGN KEY (product_id) REFERENCES products(product_id)          -- Foreign key linking to the products table
);

-- Create the sprints table to store sprint information
CREATE TABLE IF NOT EXISTS sprints (
    sprint_id SERIAL PRIMARY KEY,                                    -- Unique ID for each sprint
    product_id INT NOT NULL,                                          -- References the product for which the sprint is happening
    sprint_goal TEXT NOT NULL,                                        -- The goal of the sprint
    start_date DATE NOT NULL,                                         -- Start date of the sprint
    end_date DATE NOT NULL,                                           -- End date of the sprint
    status VARCHAR(30) CHECK (status IN ('Planned', 'Active', 'Completed', 'Cancelled')) DEFAULT 'Planned',
    -- Status values:
    -- 'Planned'     : The sprint is scheduled but not yet started.
    -- 'Active'      : The sprint is currently in progress.
    -- 'Completed'   : The sprint has finished, and all committed work is done.
    -- 'Cancelled'   : The sprint has been cancelled before completion.
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,                   -- Timestamp when the sprint was created
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Timestamp when the sprint was last updated
    FOREIGN KEY (product_id) REFERENCES products(product_id)           -- Foreign key linking to the product
);

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
    -- 'Removed'       : Item was removed from the sprint backlog, often for reprioritization.
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,                  -- Timestamp of creation
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Timestamp of the last update
    UNIQUE (sprint_id, product_backlog_item_id),                                  -- Ensures a unique combination of sprint and product backlog item
    FOREIGN KEY (assigned_team_member) REFERENCES users(user_id),     -- References the assigned team member
    FOREIGN KEY (sprint_id) REFERENCES sprints(sprint_id),            -- References the sprint
    FOREIGN KEY (product_backlog_item_id) REFERENCES product_backlog(backlog_item_id)  -- Links to product backlog
);

-- Create the increments table to store sprint increments
CREATE TABLE IF NOT EXISTS increments (
    increment_id SERIAL PRIMARY KEY,           -- Unique ID for each increment
    sprint_id INT NOT NULL,                    -- ID of the associated sprint
    increment_description TEXT NOT NULL,          -- Description of the sprint increment
    completed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- Timestamp when the increment is completed
    FOREIGN KEY (sprint_id) REFERENCES sprints(sprint_id)  -- Foreign key to reference the sprint
);

-- Create the daily scrums table to store daily scrum meetings
CREATE TABLE IF NOT EXISTS daily_scrums (
    daily_scrum_id SERIAL PRIMARY KEY,         -- Unique ID for each daily scrum
    sprint_id INT NOT NULL,                    -- ID of the associated sprint
    meeting_date DATE NOT NULL,                -- Date of the scrum meeting
    FOREIGN KEY (sprint_id) REFERENCES sprints(sprint_id)  -- Foreign key to reference the sprint
);

-- Create the daily scrum updates table to store updates from daily scrum meetings
CREATE TABLE IF NOT EXISTS daily_scrum_updates (
    update_id SERIAL PRIMARY KEY,              -- Unique ID for each scrum update
    daily_scrum_id INT NOT NULL,               -- ID of the associated daily scrum
    team_member INT NOT NULL,                  -- ID of the team member providing the update
    work_done_yesterday TEXT NOT NULL,         -- Description of the work done yesterday
    work_planned_today TEXT NOT NULL,          -- Description of the work planned for today
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- Timestamp when the record is created
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- Timestamp when the record is updated
    FOREIGN KEY (daily_scrum_id) REFERENCES daily_scrums(daily_scrum_id),  -- Foreign key to reference the daily scrum
    FOREIGN KEY (team_member) REFERENCES users(user_id)  -- Foreign key to reference the team member (user)
);

-- Create the sprint reviews table to store sprint review meetings
CREATE TABLE IF NOT EXISTS sprint_reviews (
    sprint_review_id SERIAL PRIMARY KEY,       -- Unique ID for each sprint review
    sprint_id INT NOT NULL,                    -- ID of the associated sprint
    meeting_date DATE NOT NULL,                -- Date of the review meeting
    feedback TEXT,                             -- Feedback provided during the review
    FOREIGN KEY (sprint_id) REFERENCES sprints(sprint_id)  -- Foreign key to reference the sprint
);

-- Create the sprint Retrospective table
CREATE TABLE IF NOT EXISTS sprint_retrospectives (
    retrospective_id SERIAL PRIMARY KEY,       -- Unique ID for each sprint retrospective
    sprint_id INT NOT NULL,                    -- ID of the associated sprint
    meeting_date DATE NOT NULL,                -- Date of the retrospective meeting
    went_well TEXT,                            -- Things that went well during the sprint
    needs_improvement TEXT,                    -- Things that need improvement
    actions_to_take TEXT,                      -- Actions to be taken for improvement
    FOREIGN KEY (sprint_id) REFERENCES sprints(sprint_id)  -- Foreign key to reference the sprint
);

-- Create Impediments table
CREATE TABLE IF NOT EXISTS impediments (
    impediment_id SERIAL PRIMARY KEY,                                -- Unique ID for each impediment
    sprint_id INT NOT NULL,                                           -- References the sprint in which the impediment occurred
    impediment_description TEXT NOT NULL,                             -- Description of the impediment
    raised_by_user_id INT NOT NULL,                                   -- The user who raised the impediment
    status VARCHAR(30) CHECK (status IN ('Open', 'In Progress', 'Resolved', 'Closed')) DEFAULT 'Open',
    -- Status values:
    -- 'Open'         : The impediment has been identified but not yet addressed.
    -- 'In Progress'  : The impediment is being actively worked on or mitigated.
    -- 'Resolved'     : The impediment has been resolved.
    -- 'Closed'       : The impediment has been closed (whether resolved or deemed no longer relevant).
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,                   -- Timestamp when the impediment was raised
    resolved_at TIMESTAMP,                                            -- Timestamp when the impediment was resolved
    UNIQUE (sprint_id, impediment_description),                       -- Ensures no duplicate impediments for the same sprint
    FOREIGN KEY (sprint_id) REFERENCES sprints(sprint_id),            -- Links to the sprint
    FOREIGN KEY (raised_by_user_id) REFERENCES users(user_id)         -- Links to the user who raised the impediment
);

-- Create sprint goals table
CREATE TABLE IF NOT EXISTS sprint_goals (
    sprint_goal_id SERIAL PRIMARY KEY,                            -- Unique identifier for each sprint goal
    sprint_id INT NOT NULL,                                        -- References the sprint for which the goal is set
    goal_description TEXT NOT NULL,                                -- Describes the specific goal for the sprint
    achieved BOOLEAN DEFAULT FALSE,                                -- Indicates whether the goal was achieved; defaults to false
    FOREIGN KEY (sprint_id) REFERENCES sprints(sprint_id)          -- Links the sprint goal to the sprint
);

-- Create table for burn down chart
CREATE TABLE IF NOT EXISTS burndown_chart (
    burndown_id SERIAL PRIMARY KEY,                                -- Unique identifier for each burndown chart entry
    sprint_id INT NOT NULL,                                        -- Links the burndown data to a specific sprint
    burn_date DATE NOT NULL,                                       -- The date for which the remaining work is recorded
    remaining_work TIME NOT NULL,                                  -- Amount of remaining work for that date (measured in hours)
    FOREIGN KEY (sprint_id) REFERENCES sprints(sprint_id)          -- Links the burndown chart data to the sprint
);

-- Create audit log table
CREATE TABLE IF NOT EXISTS audit_log (
    log_id SERIAL PRIMARY KEY,                                     -- Unique identifier for each log entry
    entity_type VARCHAR(50) NOT NULL,                              -- The type of entity being logged (e.g., 'User', 'Sprint', 'Product')
    entity_id INT NOT NULL,                                        -- The ID of the entity being affected by the action
    action_performed VARCHAR(50) NOT NULL,                                   -- The type of action being performed (e.g., 'INSERT', 'UPDATE', 'DELETE')
    action_by INT NOT NULL,                                        -- ID of the user who performed the action
    action_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,                 -- Timestamp of when the action was performed
    FOREIGN KEY (action_by) REFERENCES users(user_id)              -- Links the action to the user who performed it
);

COMMIT;