-- Додаємо deleted_at колонку для soft delete
ALTER TABLE goals ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ;

-- Оновлюємо існуючі RLS політики для goals (тепер з фільтром на deleted_at)
DROP POLICY IF EXISTS "Allow authenticated users to insert goals" ON goals;
CREATE POLICY "Allow authenticated users to insert goals"
  ON goals FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id AND deleted_at IS NULL);

DROP POLICY IF EXISTS "Allow authenticated users to read goals" ON goals;
CREATE POLICY "Allow authenticated users to read goals"
  ON goals FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id AND deleted_at IS NULL);

-- Додаємо UPDATE політику
DROP POLICY IF EXISTS "Allow authenticated users to update goals" ON goals;
CREATE POLICY "Allow authenticated users to update goals"
  ON goals FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id AND deleted_at IS NULL)
  WITH CHECK (auth.uid() = user_id AND deleted_at IS NULL);

-- Додаємо DELETE політику (для soft delete)
DROP POLICY IF EXISTS "Allow authenticated users to delete goals" ON goals;
CREATE POLICY "Allow authenticated users to delete goals"
  ON goals FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);
