-- Таблиця таборів
CREATE TABLE IF NOT EXISTS camps (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  ulad TEXT NOT NULL CHECK (ulad IN ('upp', 'upn', 'upj', 'usp', 'ups')),
  level TEXT NOT NULL CHECK (level IN ('stanych', 'okruzhnuj', 'krajehyj', 'mizhkrajehyj')),
  start_date DATE,
  end_date DATE,
  location TEXT DEFAULT '',
  role TEXT NOT NULL CHECK (role IN ('uchasnyk', 'vykhovnyk', 'provid', 'bulava', 'volonter')),
  result_type TEXT NOT NULL CHECK (result_type IN ('stupin', 'vmilist', 'zdobutakvalifikacija')),
  result_comment TEXT DEFAULT '',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- RLS політика
ALTER TABLE camps ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own camps"
  ON camps FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Видалення старої таблиці camp_entries (якщо є)
DROP TABLE IF EXISTS camp_entries CASCADE;
