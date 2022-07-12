/*Case Study 3: Foodie- Fi
Tools: PostgreSQL
Skills: Join
Author: Hasna Nisrina*/

SET search_path = foodie_fi

--Case Study Question
--A. Customer Journey
SELECT s.customer_id, p.plan_id, p.plan_name, s.start_date
FROM subscriptions AS s
LEFT JOIN plans AS p
ON s.plan_id = p.plan_id
WHERE s.customer_id IN (1,2,11,13,15,16,18,19)

/*Insights
1. Customer 1 started the free trial in August 1, 2020 and subscribed to basic monthly after 7 days trial ended.
2. Customer 2 started the free trial in October 20, 2020 and subscribed to pro annual after 7 days trial ended.
3. Customer 11 started the free trial in November 19, 2020. Unfortunately after free trial period ran out he canceled the service (churn).
4. Customer 13 started the free trial in December 15, 2020 and subscribed to basic monthly after 7 days trial ended. Three months later, he upgraded to the pro monthly plan.
5. Customer 15 started the free trial in March 17, 2020 and subscribed to pro monthly after 7 days trial ended. The next month, he canceled the service (churn).
6. Customer 16 started the free trial in May 31, 2020 and subscribed to basic monthly after 7 days trial ended. Four months later, he upgraded to the pro annual plan.
7. Customer 18 started the free trial in July 6, 2020 and subscribed to pro monthly after 7 days trial ended.
8. Customer 19 started the free trial in June 22, 2020 and subscribed to pro monthly after 7 days trial ended. Two months later, he upgraded to the pro annual plan.
*/