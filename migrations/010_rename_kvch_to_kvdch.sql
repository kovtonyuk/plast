-- Rename kvch columns to kvdch in training_info table
ALTER TABLE training_info RENAME COLUMN kvch_number TO kvdch_number;
ALTER TABLE training_info RENAME COLUMN kvch_date TO kvdch_date;
ALTER TABLE training_info RENAME COLUMN kvch_commandant TO kvdch_commandant;
ALTER TABLE training_info RENAME COLUMN kvch_comments TO kvdch_comments;
