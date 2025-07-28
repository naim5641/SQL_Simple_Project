-- SQL Mini Project 10/10
-- SQL Mentor User Performance

-- DROP TABLE user_submissions; 

CREATE TABLE user_submissions (
    id SERIAL PRIMARY KEY,
    user_id BIGINT,
    question_id INT,
    points INT,
    submitted_at TIMESTAMP WITH TIME ZONE,
    username VARCHAR(50)
);

SELECT * FROM user_submissions;


-- Q.1 List all distinct users and their stats (return user_name, total_submissions, points earned)
-- Q.2 Calculate the daily average points for each user.
-- Q.3 Find the top 3 users with the most positive submissions for each day.
-- Q.4 Find the top 5 users with the highest number of incorrect submissions.
-- Q.5 Find the top 10 performers for each week.


-- Please note for each questions return current stats for the users
-- user_name, total points earned, correct submissions, incorrect submissions no


-- -------------------
-- My Solutions
-- -------------------

-- Q.1 List all distinct users and their stats (return user_name, total_submissions, points earned)

-- SELECT 
-- 	COUNT(DISTINCT username)
-- FROM user_submissions


SELECT 
	username,
	COUNT(id) as total_submissions,
	SUM(points) as points_earned
FROM user_submissions
GROUP BY username
ORDER BY total_submissions DESC


-- -- Q.2 Calculate the daily average points for each user.
-- each day
-- each user and their daily avg points
-- group by day and user

select 
	username,
	-- Extract (day from submitted at) as day using TO_CHAR FUNCTION
	TO_CHAR(submitted_at, 'DD - MM') as day,
	AVG(points) as Daily_avg_Points
from user_submissions
group by 1,2
order by username

SELECT * FROM user_submissions;



-- Q.3 Find the top 3 users with the most correct submissions for each day.

-- each day
-- most correct submissions

WITH Daily_submission
AS
(
	SELECT
		username,
		-- Extract (day from submitted at) as day using TO_CHAR FUNCTION
		TO_CHAR(submitted_at, 'DD - MM') as daily,
		SUM(CASE
			WHEN points > 0 THEN 1 ELSE 0
		END) as Currect_submission
	FROM user_submissions
	GROUP BY 1,2
	ORDER BY 3 DESC

),
user_rank
AS
(
	SELECT
		username,
		daily,
		Currect_submission,
		DENSE_RANK() OVER(PARTITION BY daily ORDER BY Currect_submission DESC) AS rnk
	FROM Daily_submission	
	
)

SELECT 
	username,
	daily,
	Currect_submission
FROM user_rank
WHERE rnk <= 3

SELECT * FROM user_submissions;


-- Q.4 Find the top 5 users with the highest number of incorrect submissions.

SELECT
	username,
	SUM(CASE
			WHEN points < 0 THEN 1 ELSE 0
		END) AS Incourrent_Submission,
	SUM(CASE
			WHEN points > 0 THEN 1 ELSE 0
		END) AS courrent_Submission,
	SUM(CASE
			WHEN points < 0 THEN points ELSE 0
		END) AS Incourrent_Submission_Points,
	SUM(CASE
			WHEN points > 0 THEN points ELSE 0
		END) AS courrent_Submission_points,
	SUM(points) as Total_points_Earned
from user_submissions
GROUP BY 1
ORDER BY  Incourrent_Submission DESC


-- Q.5 Find the top 10 performers for each week.

-- EACH WEAK
-- TOP 10 PERFORMERS

SELECT * FROM
(SELECT
	-- EXTRACT WEAK
	--TO_CHAR()
	EXTRACT( WEEK FROM submitted_at) as week_no,
	username,
	SUM(points) as Total_points_earned,
	DENSE_RANK() OVER(PARTITION BY EXTRACT( WEEK FROM submitted_at) ORDER BY SUM(points) DESC) AS rnk
FROM  user_submissions
GROUP BY 1,2
ORDER BY  week_no, Total_points_earned DESC
)
WHERE rnk <= 10

	

