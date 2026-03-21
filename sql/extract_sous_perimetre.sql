SELECT
    -- Dates (Traçabilité temporelle)
    oi.created_at AS order_item_created_at,
    o.created_at AS order_created_at,

    -- Informations transactionnelles (Calcul CA, Marge et Taux de retour)
    oi.status,
    oi.sale_price,
    p.cost,

    -- Informations produit (Analyses par catégories et marques)
    p.brand,
    p.category,
    p.department,
    p.name AS product_name,

    -- Identifiants (Clés pour agrégations et jointures Power BI)
    o.order_id,
    oi.id AS order_item_id,
    u.id AS user_id,

    -- Informations client / géographie (Analyses spatiales et segmentation)
    u.gender,
    u.country,
    u.state,
    u.city

FROM `bigquery-public-data.thelook_ecommerce.order_items` AS oi
JOIN `bigquery-public-data.thelook_ecommerce.orders` AS o
    ON o.order_id = oi.order_id
JOIN `bigquery-public-data.thelook_ecommerce.products` AS p
    ON p.id = oi.product_id
JOIN `bigquery-public-data.thelook_ecommerce.users` AS u
    ON u.id = o.user_id

WHERE 
    u.country = 'France'
    AND p.department = 'Women'
    AND DATE(oi.created_at) BETWEEN '2023-01-01' AND '2024-12-31'

ORDER BY 
    oi.created_at,
    o.order_id,
    oi.id;