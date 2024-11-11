BEGIN TRANSACTION;

-- Create roles
CREATE ROLE project_admin;
CREATE ROLE project_manager;
CREATE ROLE scrum_master;
CREATE ROLE team_member;

-- Grant full usage to project_admin (admin privileges for automation/Department Head)
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO project_admin;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO project_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO project_admin;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON SEQUENCES TO project_admin;

-- Grant privileges to project_manager
-- Select
GRANT SELECT ON ALL TABLES IN SCHEMA public TO project_manager;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO project_manager;
-- Create
GRANT INSERT ON TABLE product_backlog TO project_manager;
GRANT INSERT ON TABLE sprints TO project_manager;
GRANT INSERT ON TABLE increments TO project_manager;
GRANT INSERT ON TABLE sprint_backlog TO project_manager;
GRANT INSERT ON TABLE daily_scrums TO project_manager;
GRANT INSERT ON TABLE daily_scrum_updates TO project_manager;
GRANT INSERT ON TABLE sprint_reviews TO project_manager;
GRANT INSERT ON TABLE sprint_retrospectives TO project_manager;
GRANT INSERT ON TABLE impediments TO project_manager;
GRANT INSERT ON TABLE sprint_goals TO project_manager;
-- Update
GRANT UPDATE ON TABLE product_backlog TO project_manager;
GRANT UPDATE ON TABLE sprints TO project_manager;
GRANT UPDATE ON TABLE increments TO project_manager;
GRANT UPDATE ON TABLE sprint_backlog TO project_manager;
GRANT UPDATE ON TABLE daily_scrums TO project_manager;
GRANT UPDATE ON TABLE daily_scrum_updates TO project_manager;
GRANT UPDATE ON TABLE sprint_reviews TO project_manager;
GRANT UPDATE ON TABLE sprint_retrospectives TO project_manager;
GRANT UPDATE ON TABLE impediments TO project_manager;
GRANT UPDATE ON TABLE sprint_goals TO project_manager;

-- Grant privileges to scrum_master
-- Select
GRANT SELECT ON TABLE users TO scrum_master;
GRANT SELECT ON TABLE product_backlog TO scrum_master;
GRANT SELECT ON TABLE sprints TO scrum_master;
GRANT SELECT ON TABLE sprint_backlog TO scrum_master;
GRANT SELECT ON TABLE sprint_reviews TO scrum_master;
GRANT SELECT ON TABLE sprint_retrospectives TO scrum_master;
GRANT SELECT ON TABLE sprint_goals TO scrum_master;
GRANT SELECT ON TABLE increments TO scrum_master;
GRANT SELECT ON TABLE impediments TO scrum_master;
GRANT SELECT ON TABLE burndown_chart TO scrum_master;
-- Create
GRANT INSERT ON TABLE sprint_backlog TO scrum_master;
GRANT INSERT ON TABLE sprint_reviews TO scrum_master;
GRANT INSERT ON TABLE sprint_retrospectives TO scrum_master;
GRANT INSERT ON TABLE sprint_goals TO scrum_master;
GRANT INSERT ON TABLE increments TO scrum_master;
GRANT INSERT ON TABLE impediments TO scrum_master;
-- Update
GRANT UPDATE ON TABLE sprints TO scrum_master;
GRANT UPDATE ON TABLE sprint_backlog TO scrum_master;
GRANT UPDATE ON TABLE sprint_reviews TO scrum_master;
GRANT UPDATE ON TABLE sprint_retrospectives TO scrum_master;
GRANT UPDATE ON TABLE sprint_goals TO scrum_master;
GRANT UPDATE ON TABLE impediments TO scrum_master;

-- Grant privileges to team_member
-- Select
GRANT SELECT ON TABLE users TO team_member;
GRANT SELECT ON TABLE sprints TO team_member;
GRANT SELECT ON TABLE sprint_backlog TO team_member;
GRANT SELECT ON TABLE sprint_reviews TO team_member;
GRANT SELECT ON TABLE sprint_retrospectives TO team_member;
GRANT SELECT ON TABLE sprint_goals TO team_member;
GRANT SELECT ON TABLE increments TO team_member;
GRANT SELECT ON TABLE impediments TO team_member;
GRANT SELECT ON TABLE burndown_chart TO team_member;
-- No create or update privileges for team_member

COMMIT;
