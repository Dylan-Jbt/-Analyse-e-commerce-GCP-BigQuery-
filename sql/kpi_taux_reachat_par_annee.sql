WITH client_commandes AS (
    SELECT
        u.id AS user_id,
        EXTRACT(YEAR FROM o.created_at) AS year,
        COUNT(DISTINCT o.order_id) AS nb_commandes
    FROM `bigquery-public-data.thelook_ecommerce.orders` AS o
    JOIN `bigquery-public-data.thelook_ecommerce.users` AS u
        ON u.id = o.user_id
    JOIN `bigquery-public-data.thelook_ecommerce.order_items` AS oi
        ON oi.order_id = o.order_id
    JOIN `bigquery-public-data.thelook_ecommerce.products` AS p
        ON p.id = oi.product_id
    WHERE u.country = 'France'
      AND p.department = 'Women'
      AND DATE(oi.created_at) BETWEEN '2023-01-01' AND '2024-12-31'
      AND oi.status = 'Complete'
    GROUP BY user_id, year
)
SELECT
    year,
    COUNTIF(nb_commandes >= 2) / COUNT(*) AS taux_reachat
FROM client_commandes
GROUP BY year
ORDER BY year;