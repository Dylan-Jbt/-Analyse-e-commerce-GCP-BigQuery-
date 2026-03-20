SELECT
    EXTRACT(YEAR FROM oi.created_at) AS year,
    
    -- Calcul du taux : (Retours) / (Ventes complétées + Retours)
    COUNTIF(oi.status = 'Returned') / 
    COUNTIF(oi.status IN ('Complete', 'Returned')) AS taux_retour

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
  -- On s'assure de ne traiter que les lignes qui entrent dans la définition de "vente" du projet
  AND oi.status IN ('Complete', 'Returned')

GROUP BY year
ORDER BY year