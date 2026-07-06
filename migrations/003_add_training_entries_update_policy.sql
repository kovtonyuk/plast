-- Додаємо UPDATE політику для training_entries
CREATE POLICY "Allow authenticated users to update training_entries"
  ON training_entries FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);
