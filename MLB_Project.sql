-- PART I: SCHOOL ANALYSIS
USE mlb_db;
-- 1. View the schools and school details tables
SELECT * FROM schools;
SELECT * FROM school_details;

-- 2. In each decade, how many schools were there that produced players?
SELECT	CONCAT(FLOOR(s.yearID / 10) * 10, 's') AS decade_label, COUNT(DISTINCT s.schoolID) AS num_schools
FROM	schools AS s
LEFT JOIN school_details AS sd
ON		s.schoolID = sd.schoolID
WHERE 	sd.schoolID IS NOT NULL
GROUP BY decade_label
ORDER BY decade_label;

-- 3. What are the names of the top 5 schools that produced the most players?
SELECT	 sd.name_full, COUNT(DISTINCT s.playerID) AS num_players
FROM	 schools s LEFT JOIN school_details sd
		 ON s.schoolID = sd.schoolID
GROUP BY s.schoolID
ORDER BY num_players DESC
LIMIT 	 5;

-- 4. For each decade, what were the names of the top 3 schools that produced the most players?
WITH  plyr_cnt_dec AS 	(SELECT	sd.name_full, COUNT(s.playerID) AS num_of_plyrs,
									CONCAT(FLOOR(s.yearID / 10) * 10, 's') AS decade_label
									FROM	school_details AS sd
									LEFT JOIN schools AS s
									ON		sd.schoolID = s.schoolID
									WHERE	s.schoolID IS NOT NULL
									GROUP BY sd.schoolID, decade_label),	
ranked_schools AS 	(SELECT *,
					ROW_NUMBER() OVER(PARTITION BY decade_label ORDER BY num_of_plyrs DESC) AS school_rank
					FROM plyr_cnt_dec)
            
SELECT  decade_label,
		name_full, school_rank
FROM 	ranked_schools
WHERE	school_rank <=3;
				
-- PART II: SALARY ANALYSIS
-- 1. View the salaries table
SELECT * FROM salaries;

-- 2. Return the top 20% of teams in terms of average annual spending"
WITH ts AS (SELECT 	teamID, yearID, SUM(salary) AS total_spend
			FROM	salaries
			GROUP BY teamID, yearID
			ORDER BY teamID, yearID),
            
	 sp AS (SELECT	teamID, AVG(total_spend) AS avg_spend,
					NTILE(5) OVER (ORDER BY AVG(total_spend) DESC) AS spend_pct
			FROM	ts
			GROUP BY teamID)
            
SELECT	teamID, ROUND(avg_spend / 1000000, 1) AS avg_spend_millions
FROM	sp
WHERE	spend_pct = 1;

-- 3. For each team, show the cumulative sum of spending over the years
WITH ts AS (SELECT	yearID, teamID, SUM(salary) AS total_spend
			FROM	salaries
			GROUP BY yearID, teamID)

SELECT 	teamID, yearID, 
		ROUND(SUM(total_spend) OVER(PARTITION BY teamID ORDER BY yearID) / 1000000, 1) AS spend_in_millions
FROM	ts;

-- 4. Return the first year that each team's cumulative spending surpassed 1 billion
WITH ts AS (SELECT	yearID, teamID, SUM(salary) AS total_spend
			FROM	salaries
			GROUP BY yearID, teamID),
 cs AS (SELECT 	teamID, yearID, 
				ROUND(SUM(total_spend) OVER(PARTITION BY teamID ORDER BY yearID) / 1000000000,2) AS spending_in_billion
		FROM	ts),
rn AS  (SELECT	*,
				ROW_NUMBER() OVER(PARTITION BY teamID ORDER BY spending_in_billion) AS rn
		FROM	cs
		WHERE	spending_in_billion >= 1)

SELECT 	yearID, teamID, spending_in_billion
FROM	rn
WHERE	rn = 1;

-- PART III: PLAYER CAREER ANALYSIS
-- 1. View the players table and find the number of players in the table
SELECT * FROM players;
SELECT 	COUNT(playerID) AS num_of_plyrs 
FROM 	players;

-- 2. For each player, calculate their age at their first game, their last game, and their career length (all in years). Sort from longest career to shortest career.
SELECT	nameGiven, 
		TIMESTAMPDIFF(YEAR, CAST(CONCAT(birthYear, '-', birthMonth, '-', birthDay) AS DATE), debut) AS age,
        TIMESTAMPDIFF(YEAR, CAST(CONCAT(birthYear, '-', birthMonth, '-', birthDay) AS DATE), finalGame) AS last_game,
        TIMESTAMPDIFF(YEAR,debut, finalGame) AS career_length
FROM	players
ORDER BY career_length DESC;

-- 3. What team did each player play on for their starting and ending years?
SELECT * FROM players;
SELECT * FROM salaries;

SELECT 	p.nameGiven,
		s.yearID AS starting_year, s.teamID AS starting_team,
        e.yearID AS ending_year, e.teamID AS ending_team,
        TIMESTAMPDIFF(YEAR,debut, finalGame) AS career_length
FROM	players p INNER JOIN salaries s
							ON p.playerID = s.playerID
							AND YEAR(p.debut) = s.yearID
				  INNER JOIN salaries e
							ON p.playerID = e.playerID
							AND YEAR(p.finalGame) = e.yearID;

-- 4. How many players started and ended on the same team and also played for over a decade?
WITH cd AS (SELECT 	p.nameGiven,
					s.yearID AS starting_year, s.teamID AS starting_team,
					e.yearID AS ending_year, e.teamID AS ending_team,
					TIMESTAMPDIFF(YEAR,debut, finalGame) AS career_length
			FROM	players p INNER JOIN salaries s
										ON p.playerID = s.playerID
										AND YEAR(p.debut) = s.yearID
							  INNER JOIN salaries e
										ON p.playerID = e.playerID
										AND YEAR(p.finalGame) = e.yearID)

SELECT	* 
FROM	cd
WHERE	starting_team  = ending_team 
AND		career_length > 10;
-- PART IV: PLAYER COMPARISON ANALYSIS
-- 1. View the players table
SELECT * FROM players;
-- 2. Which players have the same birthday?
WITH bn AS (SELECT	CAST(CONCAT(birthYear, '-', birthMonth, '-', birthDay) AS DATE) AS birthdate,
					nameGiven
			FROM	players)
            
SELECT	birthdate, GROUP_CONCAT(nameGiven SEPARATOR ', ') AS players
FROM	bn
WHERE	YEAR(birthdate) BETWEEN 1980 AND 1990
GROUP BY birthdate
ORDER BY birthdate;

-- 3. Create a summary table that shows for each team, what percent of players bat right, left and both
SELECT	s.teamID,
		ROUND(SUM(CASE WHEN p.bats = 'R' THEN 1 ELSE 0 END) / COUNT(s.playerID) * 100, 1) AS bats_right,
        ROUND(SUM(CASE WHEN p.bats = 'L' THEN 1 ELSE 0 END) / COUNT(s.playerID) * 100, 1) AS bats_left,
        ROUND(SUM(CASE WHEN p.bats = 'B' THEN 1 ELSE 0 END) / COUNT(s.playerID) * 100, 1) AS bats_both
FROM	salaries s LEFT JOIN players p
		ON s.playerID = p.playerID
GROUP BY s.teamID;

-- 4. How have average height and weight at debut game changed over the years, and what's the decade-over-decade difference?
WITH hw AS (SELECT	FLOOR(YEAR(debut) / 10) * 10 AS decade,
					AVG(height) AS avg_height, AVG(weight) AS avg_weight
			FROM	players
			GROUP BY decade)
            
SELECT	decade,
		avg_height - LAG(avg_height) OVER(ORDER BY decade) AS height_diff,
        avg_weight - LAG(avg_weight) OVER(ORDER BY decade) AS weight_diff
FROM	hw
WHERE	decade IS NOT NULL;