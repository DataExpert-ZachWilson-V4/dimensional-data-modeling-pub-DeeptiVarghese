INSERT INTO
deeptianievarghese22866.actors_history_scd
WITH
  lagged AS (   --tracking if an actor is active in current and previous years
    SELECT
      actor,
      quality_class,
      current_year,
      CASE  --case statement to determine if actor has records in current year
        WHEN is_active THEN 1
        ELSE 0
      END AS is_active,
       CASE    --case statement to determine if actor's quality class in previous year
        WHEN LAG(quality_class, 1) OVER (
          PARTITION BY
            actor_id
          ORDER BY
            current_year
        ) THEN 1
        ELSE 0
      END AS previous_quality_class,
      CASE    --case statement to determine if actor was active in previous year
        WHEN LAG(is_active, 1) OVER (
          PARTITION BY
            actor_id
          ORDER BY
            current_year
        ) THEN 1
        ELSE 0
      END AS is_active_last_year
    FROM
      deeptianievarghese22866.actors
    WHERE
      current_year <= 2021   --read all historic records upto 2021
  ),
  streaked AS (   --tracking state change for each actor - change from active-->inactive, inactive-->active
    SELECT
      *,
      SUM(            --summing up number of state changes for each actor ordered by year- change from active-->inactive, inactive-->active
        CASE
          WHEN quality_class <> previous_quality_class THEN 1
          WHEN is_active <> is_active_last_year THEN 1
          ELSE 0
        END
      ) OVER (
        PARTITION BY
          actor_id
        ORDER BY
          current_year
      ) AS streak_identifier
    FROM
      lagged
  )
SELECT
  actor,
  quality_class,
  MAX(is_active) = 1 AS is_active,
  MIN(current_year) AS start_date, --start and end year for an actor's active streak
  MAX(current_year) AS end_date,
  2021 as current_year
FROM
  streaked
GROUP BY
  actor,
  quality_class,
streak_identifier
