DROP FUNCTION IF EXISTS get_filtered_quests(uuid, uuid, text, boolean, boolean, boolean, text);
DROP FUNCTION IF EXISTS get_filtered_quests(uuid, text, uuid, text, boolean, boolean, boolean);

CREATE OR REPLACE FUNCTION get_filtered_quests(
  p_user_id      UUID,
  p_city_id      UUID    DEFAULT NULL,
  p_category     TEXT    DEFAULT NULL,
  p_is_completed BOOLEAN DEFAULT NULL,
  p_sort_popular BOOLEAN DEFAULT FALSE,
  p_friends_only BOOLEAN DEFAULT FALSE,
  p_status       TEXT    DEFAULT 'active'
)
RETURNS TABLE (
  id                    UUID,
  title                 TEXT,
  description           TEXT,
  category              TEXT,
  city_id               UUID,
  city_name             TEXT,
  status                TEXT,
  created_by            UUID,
  created_at            TIMESTAMPTZ,
  current_points        INT,
  completion_count      INT,
  avg_difficulty_rating NUMERIC,
  rating_count          INT,
  net_votes             INT,
  lat                   DOUBLE PRECISION,
  lng                   DOUBLE PRECISION
)
LANGUAGE sql STABLE
AS $$
  SELECT
    q.id,
    q.title,
    q.description,
    q.category,
    q.city_id,
    c.name AS city_name,
    q.status,
    q.created_by,
    q.created_at,
    q.current_points,
    q.completion_count,
    q.avg_difficulty_rating,
    q.rating_count,
    q.net_votes,
    q.lat,
    q.lng
  FROM quests q
  JOIN cities c ON c.id = q.city_id
  WHERE
    (p_status IS NULL OR q.status = p_status)
    AND (p_city_id IS NULL OR q.city_id = p_city_id)
    AND (p_category IS NULL OR q.category = p_category)
    AND (
      p_is_completed IS NULL
      OR (p_is_completed = TRUE  AND     EXISTS (SELECT 1 FROM completions co WHERE co.quest_id = q.id AND co.user_id = p_user_id))
      OR (p_is_completed = FALSE AND NOT EXISTS (SELECT 1 FROM completions co WHERE co.quest_id = q.id AND co.user_id = p_user_id))
    )
    AND (
      NOT p_friends_only
      OR q.created_by IN (
        SELECT CASE WHEN sender_id = p_user_id THEN receiver_id ELSE sender_id END
        FROM friend_requests
        WHERE status = 'accepted'
          AND (sender_id = p_user_id OR receiver_id = p_user_id)
      )
    )
  ORDER BY
    CASE WHEN p_sort_popular THEN q.net_votes END DESC NULLS LAST,
    q.created_at DESC
$$;
