-- ============================================================
-- CONSUMER BEHAVIOUR ANALYSIS — CLOTHING RETAIL
-- SQL business questions (MySQL)
-- Dataset: consumer_shopping_trends (11,789 respondents)
-- Author: Ebenezer Osei Asibey Antwi
-- ============================================================


-- ============================================================
-- Q1: Behavioural profile of each shopping preference group
-- Identifies the key attitudinal drivers that separate
-- online, store, and hybrid shoppers.
-- Finding: Online shoppers score higher on tech-savviness
-- (6.58 vs 5.40) and lower on need-to-touch-feel (4.30 vs 5.62).
-- ============================================================

SELECT
  shopping_preference,
  COUNT(*)                                      AS total_customers,
  ROUND(AVG(tech_savvy_score), 2)               AS avg_tech_savvy,
  ROUND(AVG(online_payment_trust_score), 2)     AS avg_payment_trust,
  ROUND(AVG(need_touch_feel_score), 2)          AS avg_touch_feel,
  ROUND(AVG(daily_internet_hours), 1)           AS avg_internet_hours,
  ROUND(AVG(impulse_buying_score), 2)           AS avg_impulse_buying,
  ROUND(AVG(brand_loyalty_score), 2)            AS avg_brand_loyalty,
  ROUND(AVG(social_media_hours), 1)             AS avg_social_media_hrs
FROM consumer_shopping_trends
GROUP BY shopping_preference
ORDER BY FIELD(shopping_preference, 'Online', 'Hybrid', 'Store');


-- ============================================================
-- Q2: Does city tier predict shopping channel preference?
-- Shows the online/hybrid/store split within each city tier.
-- Uses a subquery so the percentage (window function) and the
-- aggregates do not conflict at the same query level.
-- ============================================================

SELECT
  city_tier,
  shopping_preference,
  customers,
  ROUND(customers * 100.0 / tier_total, 1)      AS pct_within_tier,
  avg_online_spend,
  avg_monthly_orders
FROM (
  SELECT
    city_tier,
    shopping_preference,
    COUNT(*)                                    AS customers,
    SUM(COUNT(*)) OVER (PARTITION BY city_tier) AS tier_total,
    ROUND(AVG(avg_online_spend), 0)             AS avg_online_spend,
    ROUND(AVG(monthly_online_orders), 1)        AS avg_monthly_orders
  FROM consumer_shopping_trends
  GROUP BY city_tier, shopping_preference
) t
ORDER BY city_tier, customers DESC;


-- ============================================================
-- Q3: Which age group spends the most online vs in-store?
-- Buckets customers by age and compares spend by preference.
-- The online_vs_store_gap column shows whether each group
-- spends more online (positive) or in-store (negative).
-- ============================================================

SELECT
  CASE
    WHEN age BETWEEN 18 AND 30 THEN '18-30'
    WHEN age BETWEEN 31 AND 45 THEN '31-45'
    WHEN age BETWEEN 46 AND 60 THEN '46-60'
    ELSE '61+'
  END                                           AS age_group,
  shopping_preference,
  COUNT(*)                                      AS customers,
  ROUND(AVG(monthly_income), 0)                 AS avg_income,
  ROUND(AVG(avg_online_spend), 0)               AS avg_online_spend,
  ROUND(AVG(avg_store_spend), 0)                AS avg_store_spend,
  ROUND(AVG(avg_online_spend) -
        AVG(avg_store_spend), 0)                AS online_vs_store_gap
FROM consumer_shopping_trends
GROUP BY age_group, shopping_preference
ORDER BY age_group, customers DESC;


-- ============================================================
-- Q4: What friction points block online adoption?
-- Compares online vs store shoppers on the attitudes that
-- create resistance to buying online.
-- Finding: need-to-touch-feel is the #1 barrier for store
-- shoppers (5.62 vs 4.30 for online shoppers).
-- ============================================================

SELECT
  shopping_preference,
  ROUND(AVG(need_touch_feel_score), 2)          AS touch_feel_barrier,
  ROUND(AVG(online_payment_trust_score), 2)     AS payment_trust,
  ROUND(AVG(delivery_fee_sensitivity), 2)       AS delivery_fee_concern,
  ROUND(AVG(free_return_importance), 2)         AS returns_importance,
  ROUND(AVG(avg_delivery_days), 2)              AS avg_delivery_days,
  ROUND(AVG(return_frequency), 2)               AS return_frequency
FROM consumer_shopping_trends
WHERE shopping_preference IN ('Online', 'Store')
GROUP BY shopping_preference;


-- ============================================================
-- Q5: Profile of the hybrid shopper — the highest-value segment
-- Hybrid shoppers engage across both channels. Identifying their
-- traits tells the retailer who to prioritise.
-- Finding: though only 3% of the sample, they show the highest
-- impulse-buying (5.69) and brand-loyalty (5.67) scores.
-- ============================================================

SELECT
  shopping_preference,
  COUNT(*)                                      AS customers,
  ROUND(AVG(impulse_buying_score), 2)           AS impulse_buying,
  ROUND(AVG(brand_loyalty_score), 2)            AS brand_loyalty,
  ROUND(AVG(monthly_online_orders +
            monthly_store_visits), 1)           AS total_touchpoints,
  ROUND(AVG(avg_online_spend +
            avg_store_spend), 0)                AS total_avg_spend,
  ROUND(AVG(discount_sensitivity), 2)           AS discount_sensitivity,
  ROUND(AVG(environmental_awareness), 2)        AS eco_awareness
FROM consumer_shopping_trends
GROUP BY shopping_preference
ORDER BY total_avg_spend DESC;
