-- Create sprint goals table
CREATE TABLE IF NOT EXISTS sprint_goals (
    sprint_goal_id SERIAL PRIMARY KEY, -- Unique identifier for each sprint goal
    sprint_id INT NOT NULL, -- References the sprint for which the goal is set
    goal_description TEXT NOT NULL, -- Describes the specific goal for the sprint
    achieved BOOLEAN DEFAULT FALSE, -- Indicates whether the goal was achieved; defaults to false
    FOREIGN KEY (sprint_id) REFERENCES sprints (sprint_id) -- Links the sprint goal to the sprint
);