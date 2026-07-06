-- Додаємо колонки start_date та end_date до training_entries
ALTER TABLE training_entries ADD COLUMN IF NOT EXISTS start_date TIMESTAMPTZ;
ALTER TABLE training_entries ADD COLUMN IF NOT EXISTS end_date TIMESTAMPTZ;
