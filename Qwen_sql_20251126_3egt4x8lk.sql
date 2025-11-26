SELECT user_id
FROM users a
WHERE 
  -- 条件1: 免费用户
  a.plan_type = 'free'
  
  -- 条件2: 有效登录次数 > 免费用户平均有效登录次数
  AND (
      SELECT COUNT(*)
      FROM logins c
      WHERE c.user_id = a.user_id
        AND c.login_date IS NOT NULL  -- 有效登录
  ) > (
      SELECT AVG(
          (SELECT COUNT(*)
           FROM logins d
           WHERE d.user_id = e.user_id
             AND d.login_date IS NOT NULL  -- 🔥 关键：有效登录
          )
      )
      FROM users e
      WHERE e.plan_type = 'free'
  )
  
  -- 条件3: 近7天无登录
  AND NOT EXISTS (
      SELECT 1
      FROM logins f
      WHERE f.user_id = a.user_id
        AND f.login_date > '2024-03-25'
  )
  
  -- 条件4: 从未付费
  AND NOT EXISTS (
      SELECT 1
      FROM payments g
      WHERE g.user_id = a.user_id
        AND g.amount IS NOT NULL
  );