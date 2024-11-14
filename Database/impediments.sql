-- Create Impediments table
CREATE TABLE IF NOT EXISTS impediments (
    impediment_id SERIAL PRIMARY KEY, -- Unique ID for each impediment
    sprint_id INT NOT NULL, -- References the sprint in which the impediment occurred
    impediment_description TEXT NOT NULL, -- Description of the impediment
    raised_by_user_id INT NOT NULL, -- The user who raised the impediment
    status VARCHAR(30) CHECK (
        status IN ('Open', 'In Progress', 'Resolved', 'Closed')
    ) DEFAULT 'Open',
    -- Status values:
    -- 'Open'         : The impediment has been identified but not yet addressed.
    -- 'In Progress'  : The impediment is being actively worked on or mitigated.
    -- 'Resolved'     : The impediment has been resolved.
    -- 'Closed'       : The impediment has been closed (whether resolved or deemed no longer relevant).
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Timestamp when the impediment was raised
    resolved_at TIMESTAMP, -- Timestamp when the impediment was resolved
    UNIQUE (sprint_id, impediment_description), -- Ensures no duplicate impediments for the same sprint
    FOREIGN KEY (sprint_id) REFERENCES sprints (sprint_id), -- Links to the sprint
    FOREIGN KEY (raised_by_user_id) REFERENCES users (user_id) -- Links to the user who raised the impediment
);