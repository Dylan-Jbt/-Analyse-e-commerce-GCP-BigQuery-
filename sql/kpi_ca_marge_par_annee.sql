SELECT
    -- Extraction de l'année pour la comparaison 2023 vs 2024
    EXTRACT(YEAR FROM oi.created_at) AS year,
    
    -- Calcul du CA : Uniquement sur le statut 'Complete' (convention projet)
    SUM(CASE WHEN oi.status = 'Complete' THEN oi.sale_price ELSE 0 END) AS ca,
    
    -- Calcul de la Marge : (Prix de vente - Coût) pour les ventes complétées
    SUM(CASE WHEN oi.status = 'Complete' THEN oi.sale_price - p.cost ELSE 0 END) AS marge

FROM `bigquery-public-data.thelook_ecommerce.order_items` AS oi
-- Jointure pour lier l'article à la commande globale
JOIN `bigquery-public-data.thelook_ecommerce.orders` AS o 
    ON o.order_id = oi.order_id
-- Jointure pour récupérer les informations produits (cost, department)
JOIN `bigquery-public-data.thelook_ecommerce.products` AS p 
    ON p.id = oi.product_id
-- Jointure pour filtrer sur la localisation de l'utilisateur (France)
JOIN `bigquery-public-data.thelook_ecommerce.users` AS u 
    ON u.id = o.user_id

WHERE u.country = 'France'
  AND p.department = 'Women'
  AND DATE(oi.created_at) BETWEEN '2023-01-01' AND '2024-12-31'

GROUP BY year
ORDER BY year





-- SQL resultats : 
2023 = 7496.180004119873, 3983.3351309010836
2024 = 11497.600009918213, 6071.2850773775654
