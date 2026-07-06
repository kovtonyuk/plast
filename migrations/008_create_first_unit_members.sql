-- Створюємо таблицю first_unit_members якщо не існує
CREATE TABLE IF NOT EXISTS first_unit_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  first_unit_id UUID NOT NULL REFERENCES first_units(id) ON DELETE CASCADE,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  date_of_birth TIMESTAMPTZ,
  address TEXT DEFAULT '',
  phone TEXT DEFAULT '',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- RLS
ALTER TABLE first_unit_members ENABLE ROW LEVEL SECURITY;

-- Політика для INSERT
CREATE POLICY "Allow authenticated users to insert first_unit_members"
  ON first_unit_members FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = (SELECT user_id FROM first_units WHERE id = first_unit_id));

-- Політика для SELECT
CREATE POLICY "Allow authenticated users to read first_unit_members"
  ON first_unit_members FOR SELECT
  TO authenticated
  USING (auth.uid() = (SELECT user_id FROM first_units WHERE id = first_unit_id));

-- Політика для UPDATE
CREATE POLICY "Allow authenticated users to update first_unit_members"
  ON first_unit_members FOR UPDATE
  TO authenticated
  USING (auth.uid() = (SELECT user_id FROM first_units WHERE id = first_unit_id))
  WITH CHECK (auth.uid() = (SELECT user_id FROM first_units WHERE id = first_unit_id));

-- Політика для DELETE
CREATE POLICY "Allow authenticated users to delete first_unit_members"
  ON first_unit_members FOR DELETE
  TO authenticated
  USING (auth.uid() = (SELECT user_id FROM first_units WHERE id = first_unit_id));
