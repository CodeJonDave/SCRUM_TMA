-- Create table for burn down chart

CREATE TABLE IF NOT EXISTS burndown_chart (burndown_id SERIAL PRIMARY KEY, -- Unique identifier for each burndown chart entry
 sprint_id INT NOT NULL, -- Links the burndown data to a specific sprint
 burn_date DATE NOT NULL, -- The date for which the remaining work is recorded
 remaining_work TIME NOT NULL, -- Amount of remaining work for that date (measured in hours)
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                              updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                                           FOREIGN KEY (sprint_id) REFERENCES sprints (sprint_id) -- Links the burndown chart data to the sprint
 );