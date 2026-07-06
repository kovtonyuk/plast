-- Створюємо функцію для soft delete goals (обходить RLS)
CREATE OR REPLACE FUNCTION soft_delete_goal(goal_id UUID)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE goals
  SET deleted_at = now()
  WHERE id = goal_id;
END;
$$;
