-- Migration 011: Quests Together RPC

CREATE OR REPLACE FUNCTION get_quests_together(p_user1 UUID, p_user2 UUID)
RETURNS TABLE (
  quest_id UUID,
  quest_title TEXT,
  completed_at TIMESTAMPTZ,
  points_awarded INT,
  media_url TEXT,
  media_type TEXT,
  owner_id UUID,
  owner_username TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    c.quest_id,
    q.title AS quest_title,
    c.completed_at,
    c.points_awarded,
    c.media_url,
    c.media_type,
    c.user_id AS owner_id,
    u.username AS owner_username
  FROM completions c
  JOIN quests q ON c.quest_id = q.id
  JOIN users u ON c.user_id = u.id
  WHERE 
    -- User1 is owner and User2 is tagged
    (c.user_id = p_user1 AND EXISTS (SELECT 1 FROM completion_tags ct WHERE ct.completion_id = c.id AND ct.tagged_user_id = p_user2))
    OR
    -- User2 is owner and User1 is tagged
    (c.user_id = p_user2 AND EXISTS (SELECT 1 FROM completion_tags ct WHERE ct.completion_id = c.id AND ct.tagged_user_id = p_user1))
  ORDER BY c.completed_at DESC;
END;
$$;
