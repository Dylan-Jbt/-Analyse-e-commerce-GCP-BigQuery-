SELECT
    EXTRACT(YEAR FROM oi.created_at) AS year,
    SUM(CASE WHEN oi.status = 'Complete' THEN oi.sale_price ELSE 0 END) AS ca,
    SUM(CASE WHEN oi.status = 'Complete' THEN oi.sale_price - p.cost ELSE 0 END) AS marge
FROM `bigquery-public-data.thelook_ecommerce.order_items` AS oi
JOIN `bigquery-public-data.thelook_ecommerce.orders` AS o
    ON o.order_id = oi.order_id
JOIN `bigquery-public-data.thelook_ecommerce.products` AS p
    ON p.id = oi.product_id
JOIN `bigquery-public-data.thelook_ecommerce.users` AS u
    ON u.id = o.user_id
WHERE u.country = 'France'
  AND p.department = 'Women'
  AND DATE(oi.created_at) BETWEEN '2023-01-01' AND '2024-12-31'
GROUP BY year
ORDER BY year