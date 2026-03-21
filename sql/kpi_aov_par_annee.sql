SELECT
    -- Dimension temporelle pour la comparaison annuelle
    EXTRACT(YEAR FROM o.created_at) AS year,

    -- Calcul du Panier Moyen : (Somme CA) / (Nombre de commandes distinctes)
    SUM(
        CASE 
            WHEN oi.status = 'Complete' THEN oi.sale_price 
            ELSE 0 
        END
    )
    /
    NULLIF(
        COUNT(DISTINCT 
            CASE 
                WHEN oi.status = 'Complete' THEN o.order_id 
                ELSE NULL 
            END
        ), 
        0
    ) AS panier_moyen

FROM `bigquery-public-data.thelook_ecommerce.order_items` AS oi
-- Jointures standard du périmètre d'étude
JOIN `bigquery-public-data.thelook_ecommerce.orders` AS o ON o.order_id = oi.order_id
JOIN `bigquery-public-data.thelook_ecommerce.products` AS p ON p.id = oi.product_id
JOIN `bigquery-public-data.thelook_ecommerce.users` AS u ON u.id = o.user_id

WHERE 
    u.country = 'France'
    AND p.department = 'Women'
    AND DATE(oi.created_at) BETWEEN '2023-01-01' AND '2024-12-31'

GROUP BY year
ORDER BY year




-- SQL resultats : 
2023 = 102.68739731671059
2024 = 78.2149660538654
