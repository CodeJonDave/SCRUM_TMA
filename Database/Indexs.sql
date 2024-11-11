BEGIN TRANSACTION;

-- Indexes for the users table
CREATE INDEX IF NOT EXISTS idx_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_email ON users(user_id);
CREATE INDEX IF NOT EXISTS idx_title ON users(title);

-- Indexes for the products table
CREATE INDEX IF NOT EXISTS idx_product_name ON products(product_name);
CREATE INDEX IF NOT EXISTS idx_product_owner_id ON products(product_owner_id);

-- Indexes for the products backlog table
CREATE INDEX IF NOT EXISTS idx_product_id_on_backlog ON product_backlog(product_id);
CREATE INDEX IF NOT EXISTS idx_priority ON product_backlog(priority);
CREATE INDEX IF NOT EXISTS idx_status_on_backlog ON product_backlog(status);
CREATE INDEX IF NOT EXISTS idx_due_date_on_backlog ON product_backlog(due_date);

-- Indexes for the sprints table
CREATE INDEX IF NOT EXISTS idx_product_id_on_sprints ON sprints(product_id);
CREATE INDEX IF NOT EXISTS idx_status_on_sprints ON sprints(status);
CREATE INDEX IF NOT EXISTS idx_start_date_on_sprints ON sprints(start_date);
CREATE INDEX IF NOT EXISTS idx_end_date_on_sprints ON sprints(end_date);

-- Indexes for the sprint backlog table
CREATE INDEX IF NOT EXISTS idx_sprint_id_on_sprint_backlog ON sprint_backlog(sprint_id);
CREATE INDEX IF NOT EXISTS idx_product_backlog_item_id ON sprint_backlog(product_backlog_item_id);
CREATE INDEX IF NOT EXISTS idx_assigned_team_member_on_sprint_backlog ON sprint_backlog(assigned_team_member);
CREATE INDEX IF NOT EXISTS idx_status_on_sprint_backlog ON sprint_backlog(status);

-- Indexes for the increments table
CREATE INDEX IF NOT EXISTS idx_sprint_id_on_increments ON increments(sprint_id);

-- Indexes for the daily scrums table
CREATE INDEX IF NOT EXISTS idx_sprint_id_on_daily_scrums ON daily_scrums(sprint_id);
CREATE INDEX IF NOT EXISTS idx_meeting_date_on_daily_scrums ON daily_scrums(meeting_date);

-- Indexes for the daily scrum updates table
CREATE INDEX IF NOT EXISTS idx_daily_scrum_id_on_scrum_updates ON daily_scrum_updates(daily_scrum_id);
CREATE INDEX IF NOT EXISTS idx_team_member_on_scrum_updates ON daily_scrum_updates(team_member);

-- Indexes for the sprint reviews table
CREATE INDEX IF NOT EXISTS idx_sprint_id_on_sprint_reviews ON sprint_reviews(sprint_id);
CREATE INDEX IF NOT EXISTS idx_meeting_date_on_sprint_reviews ON sprint_reviews(meeting_date);

-- Indexes for the sprint retrospective table
CREATE INDEX IF NOT EXISTS idx_sprint_id_on_retrospectives ON sprint_retrospectives(sprint_id);
CREATE INDEX IF NOT EXISTS idx_meeting_date_on_retrospective ON sprint_retrospectives(meeting_date);

-- Indexes for the impediments table
CREATE INDEX IF NOT EXISTS idx_sprint_id_on_impediments ON impediments(sprint_id);
CREATE INDEX IF NOT EXISTS idx_raised_by_user_id_on_impediments ON impediments(raised_by_user_id);
CREATE INDEX IF NOT EXISTS idx_status_on_impediments ON impediments(status);

-- Indexes for the sprint goal table
CREATE INDEX IF NOT EXISTS idx_sprint_id_on_sprint_goals ON sprint_goals(sprint_id);
CREATE INDEX IF NOT EXISTS idx_achieved ON sprint_goals(achieved);

-- Indexes for the burn down table
CREATE INDEX IF NOT EXISTS idx_sprint_id_on_burn ON burndown_chart(sprint_id);
CREATE INDEX IF NOT EXISTS idx_burn_date_on_burn ON burndown_chart(burn_date);

-- Indexes for the audit log table
CREATE INDEX IF NOT EXISTS idx_entity_type_on_audit_log ON audit_log(entity_type);
CREATE INDEX IF NOT EXISTS idx_entity_id_on_audit_log ON audit_log(entity_id);
CREATE INDEX IF NOT EXISTS idx_action_by_on_audit_log ON audit_log(action_by);

COMMIT;