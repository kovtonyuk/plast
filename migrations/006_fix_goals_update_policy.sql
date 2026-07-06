-- Оновлюємо UPDATE політику для goals (дозволяємо встановлювати deleted_at)
DROP POLICY IF EXISTS "Allow authenticated users to update goals" ON goals;
CREATE POLICY "Allow authenticated users to update goals"
  ON goals FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id AND deleted_at IS NULL)
  WITH CHECK (auth.uid() = user_id);
