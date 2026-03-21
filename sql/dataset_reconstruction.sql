-- Reconstruction du sous-périmètre
-- France × Women × 2023-2024
-- Source : bigquery-public-data.thelook_ecommerce

SELECT
    -- Dates
    DATE(oi.created_at) AS item_date,
    DATE(o.created_at) AS order_date,

    -- Identifiants
    o.order_id,
    oi.id AS order_item_id,
    u.id AS user_id,

    -- Statut & prix
    oi.status,
    oi.sale_price,
    p.cost,

    -- Produit
    p.brand,
    p.category,
    p.department,
    p.name AS product_name,

    -- Client / géographie
    u.gender,
    u.country,
    u.state,
    u.city

FROM `bigquery-public-data.thelook_ecommerce.order_items` AS oi

-- Jointure commandes
LEFT JOIN `bigquery-public-data.thelook_ecommerce.orders` AS o
    ON oi.order_id = o.order_id

-- Jointure produits
LEFT JOIN `bigquery-public-data.thelook_ecommerce.products` AS p
    ON oi.product_id = p.id

-- Jointure utilisateurs
LEFT JOIN `bigquery-public-data.thelook_ecommerce.users` AS u
    ON o.user_id = u.id

-- Filtres du périmètre
WHERE
    u.country = 'France'
    AND p.department = 'Women'
    AND DATE(oi.created_at) BETWEEN '2023-01-01' AND '2024-12-31'

-- Tri pour stabilité du dataset
ORDER BY
    item_date,
    o.order_id,
    order_item_id