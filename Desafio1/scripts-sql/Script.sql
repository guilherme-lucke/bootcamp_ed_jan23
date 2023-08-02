--Criação das tabelas

CREATE TABLE PUBLIC."results" (
	"date" DATE NULL
	,"home_team" VARCHAR(300) NULL
	,"away_team" VARCHAR(300) NULL
	,"home_score" int4 NULL
	,"away_score" int4 NULL
	,tournament VARCHAR(300) NULL
	,city VARCHAR(300) NULL
	,country VARCHAR(300) NULL
	,neutral boolean NULL
	);


CREATE TABLE PUBLIC."goalscorers" (
	"date" DATE NULL
	,"home_team" VARCHAR(300) NULL
	,"away_team" VARCHAR(300) NULL
	,team VARCHAR(300) NULL
	,scorer VARCHAR(300) NULL
	,"minute" VARCHAR(300) NULL
	,"own—goal" boolean NULL
	,penalty boolean NULL
	);

SELECT count(*)
FROM goalscorers AS g
WHERE minute = 'NA';

UPDATE goalscorers
SET "minute" = NULL
WHERE "minute" = 'NA';

ALTER TABLE public.goalscorers 
ALTER COLUMN "minute" TYPE INT 
USING "minute"::int;


CREATE TABLE PUBLIC."shootouts" (
	"date" DATE NULL
	,"home_team" VARCHAR(300) NULL
	,"away_team" VARCHAR(300) NULL 
	,winner VARCHAR(300) NULL
	);

--Análise de Dados

-- Maiores Marcadores de Todos os Tempos em Competições Internacionais

SELECT scorer, count(*) AS total_goals
FROM goalscorers g
WHERE scorer != 'NA'
GROUP BY scorer
; 


-- Maiores Marcadores por Décadas em Competições Internacionais

WITH decades AS (
SELECT scorer,
CASE 
	WHEN extract(year FROM DATE) < 1920 THEN '1910s'
	WHEN extract(year FROM DATE) BETWEEN 1920 AND 1929 THEN '1920s'
	WHEN extract(year FROM DATE) BETWEEN 1930 AND 1939 THEN '1930s'
	WHEN extract(year FROM DATE) BETWEEN 1940 AND 1949 THEN '1940s'
	WHEN extract(year FROM DATE) BETWEEN 1950 AND 1959 THEN '1950s'
	WHEN extract(year FROM DATE) BETWEEN 1960 AND 1969 THEN '1960s'
	WHEN extract(year FROM DATE) BETWEEN 1970 AND 1979 THEN '1970s'
	WHEN extract(year FROM DATE) BETWEEN 1980 AND 1989 THEN '1980s'
	WHEN extract(year FROM DATE) BETWEEN 1990 AND 1999 THEN '1990s'
	WHEN extract(year FROM DATE) BETWEEN 2000 AND 2009 THEN '2000s'
	WHEN extract(year FROM DATE) BETWEEN 2010 AND 2019 THEN '2010s'
	WHEN extract(year FROM DATE) > 2019 THEN '2020s'
END AS decade
FROM goalscorers g
WHERE scorer != 'NA'
),
goals_decade AS (
SELECT scorer, decade, count(*) AS total_goals
FROM decades
GROUP BY scorer
	,decade
ORDER BY total_goals DESC
)
SELECT * FROM 
	(
		SELECT *,
		rank() OVER (PARTITION BY decade ORDER BY total_goals DESC) AS decade_rank
		FROM goals_decade
		ORDER BY decade_rank, decade DESC
	) g
WHERE decade_rank <= 1
;
 
-- Maiores Marcadores de Penaltis em Competições Internacionais

SELECT scorer, count(*) AS total_goals
FROM goalscorers g
WHERE scorer != 'NA'
	AND penalty IS True
GROUP BY scorer
ORDER BY total_goals DESC
;

-- Maiores Marcadores de Penaltis por Décadas em Competições Internacionais

WITH decades AS (
SELECT scorer,
CASE 
	WHEN extract(year FROM DATE) < 1920 THEN '1910s'
	WHEN extract(year FROM DATE) BETWEEN 1920 AND 1929 THEN '1920s'
	WHEN extract(year FROM DATE) BETWEEN 1930 AND 1939 THEN '1930s'
	WHEN extract(year FROM DATE) BETWEEN 1940 AND 1949 THEN '1940s'
	WHEN extract(year FROM DATE) BETWEEN 1950 AND 1959 THEN '1950s'
	WHEN extract(year FROM DATE) BETWEEN 1960 AND 1969 THEN '1960s'
	WHEN extract(year FROM DATE) BETWEEN 1970 AND 1979 THEN '1970s'
	WHEN extract(year FROM DATE) BETWEEN 1980 AND 1989 THEN '1980s'
	WHEN extract(year FROM DATE) BETWEEN 1990 AND 1999 THEN '1990s'
	WHEN extract(year FROM DATE) BETWEEN 2000 AND 2009 THEN '2000s'
	WHEN extract(year FROM DATE) BETWEEN 2010 AND 2019 THEN '2010s'
	WHEN extract(year FROM DATE) > 2019 THEN '2020s'
END AS decade
FROM goalscorers g
WHERE scorer != 'NA' AND penalty IS True
),
goals_decade AS (
SELECT scorer, decade, count(*) AS total_goals
FROM decades
GROUP BY scorer, decade
ORDER BY total_goals DESC
)
SELECT * FROM 
	(
	 SELECT *,
	 rank() OVER (
			PARTITION BY decade ORDER BY total_goals DESC) AS decade_rank
	FROM goals_decade
	ORDER BY decade_rank
		,decade DESC
	) g
WHERE decade_rank <= 1
; 

-- Hat-Tricks

WITH hat_tricks AS (
SELECT DATE , home_team, away_team, scorer, count(*) AS total_goals
FROM goalscorers g
WHERE scorer != 'NA'
GROUP BY DATE, home_team, away_team, scorer
HAVING count(*) > 2
ORDER BY total_goals DESC
)
SELECT scorer, count(*)
FROM hat_tricks
GROUP BY scorer
ORDER BY 2 DESC
;

-- Jogadores que marcam gols em mais minutos diferentes

SELECT scorer, count(DISTINCT minute) AS count_diff_minutes
FROM goalscorers g
WHERE scorer != 'NA'
GROUP BY scorer
ORDER BY count_diff_minutes DESC
;

-- Minuto em que ocorrem maior parte dos gols

SELECT minute, count(*)
FROM goalscorers g
WHERE minute IS NOT NULL
GROUP BY minute
ORDER BY 2 DESC
;
