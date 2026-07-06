-- Додаємо UPDATE політику для goals, бо була тільки INSERT і SELECT
CREATE POLICY "Allow authenticated users to update goals"
  ON goals FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);
