SELECT t1."date"
	,t1."rank"
	,t1.song
	,t1.artist
	,t1."last-week"
	,t1."peak-rank"
	,t1."weeks-on-board"
FROM PUBLIC."Billboard" AS t1 limit 100;

SELECT t1.artist
	,t1.song
FROM PUBLIC."Billboard" AS t1
ORDER BY t1.artist
	,t1.song;

SELECT DISTINCT t1.artist
	,t1.song
FROM PUBLIC."Billboard" AS t1
ORDER BY t1.artist
	,t1.song;

SELECT t1.artist
	,count(*) AS qtd_artist
FROM PUBLIC."Billboard" AS t1
GROUP BY t1.artist
ORDER BY t1.artist;

SELECT t1.song
	,count(*) AS qtd_song
FROM PUBLIC."Billboard" AS t1
GROUP BY t1.song
ORDER BY t1.song;

SELECT DISTINCT t1.artist
	,t2.qtd_artist
	,t1.song
	,t3.qtd_song
FROM PUBLIC."Billboard" AS t1
LEFT JOIN (
	SELECT t1.artist
		,count(*) AS qtd_artist
	FROM PUBLIC."Billboard" AS t1
	GROUP BY t1.artist
	ORDER BY t1.artist
	) AS t2 ON (t1.artist = t2.artist)
LEFT JOIN (
	SELECT t1.song
		,count(*) AS qtd_song
	FROM PUBLIC."Billboard" AS t1
	GROUP BY t1.song
	ORDER BY t1.song
	) AS t3 ON (t1.song = t3.song)
ORDER BY t1.artist
	,t1.song;

-------------------------------------------

WITH cte_artist
AS (
	SELECT t1.artist
		,count(*) AS qtd_artist
	FROM PUBLIC."Billboard" AS t1
	GROUP BY t1.artist
	ORDER BY t1.artist
	)
	,cte_song
AS (
	SELECT t1.song
		,count(*) AS qtd_song
	FROM PUBLIC."Billboard" AS t1
	GROUP BY t1.song
	ORDER BY t1.song
	)
SELECT DISTINCT t1.artist
	,t2.qtd_artist
	,t1.song
	,t3.qtd_song
FROM PUBLIC."Billboard" AS t1
LEFT JOIN cte_artist AS t2 ON (t1.artist = t2.artist)
LEFT JOIN cte_song AS t3 ON (t1.song = t3.song)
ORDER BY t1.artist, t1.song;

----------------------------------------------------------

WITH cte_billboard 
AS (
	SELECT distinct 
	t1.artist
	,t1.song
FROM PUBLIC."Billboard" AS t1
ORDER BY t1.artist, t1.song
)
SELECT * 
--,row_number() over(order by artist, song) as "row_number"
--,row_number() over(partition by artist order by artist, song) as "row_number_artist"
,rank() over(partition by artist order by artist, song) as "rank"
--,lag(song, 1) over(partition by artist order by artist, song) as "lag_song"
--,lead(song, 1) over(partition by artist order by artist, song) as "lead_song"
,first_value(song) over(partition by artist order by artist, song) as "first_song"
,last_value(song) over(partition by artist order by artist, song range between unbounded preceding and unbounded following) as "last_song"
FROM cte_billboard
;

WITH T(StyleID, ID, Nome)
	AS (SELECT 1,1, 'Rhuan' UNION all
		select 1,1, 'Andre' union all
		select 1,2, 'Ana' union all
		select 1,2, 'Marcia' union all
		select 1,3, 'Letícia' union all
		select 1,3, 'Lari' union all
		select 1,4, 'Edson' union all
		select 1,4, 'Marcos' union all
		select 1,5, 'Rhuan' union all
		select 1,5, 'Lari' union all
		select 1,6, 'Daisy' union all
		select 1,6, 'João'
		)
SELECT *,
	ROW_NUMBER() OVER(PARTITION BY styleID ORDER BY ID) AS "ROW_NUMBER",
	RANK() OVER(PARTITION BY styleID ORDER BY ID) AS "RANK",
	DENSE_RANK() OVER(PARTITION BY styleID ORDER BY ID) AS "DENSE_RANK",
	percent_rank() OVER(PARTITION BY styleID ORDER BY ID) AS "PERCENT_RANK",
	cume_dist() OVER(PARTITION BY styleID ORDER BY ID) AS "CUME_DIST",
	cume_dist() OVER(PARTITION BY styleID ORDER BY ID DESC) AS "CUME_DIST_DESC",
	first_value (Nome) OVER(PARTITION BY styleID ORDER BY ID) AS "FIRST_VALUE",
	last_value(Nome) OVER(PARTITION BY styleID ORDER BY ID) AS "LAST_VALUE",
	nth_value (Nome,5) OVER(PARTITION BY styleID ORDER BY ID) AS "NTH_VALUE",
	ntile (5) OVER(ORDER BY StyleID) AS "NTILE_5",
	lag (Nome, 1) OVER(ORDER BY ID) AS "LAG_NAME",
	lead (Nome, 1) OVER(ORDER BY ID) AS "LEAD_NAME"
FROM T;

-------------------------------------------------------------------------------------

CREATE TABLE tb_web_site AS (
WITH cte_dedup_artist AS (
SELECT t1."date"
	,t1."rank"
	,t1.artist
	,row_number() over(partition by artist order by artist, "date") AS dedup
FROM PUBLIC."Billboard" AS t1
ORDER BY t1.artist, t1."date"
)
SELECT t1."date"
	,t1."rank"
	,t1.artist
FROM cte_dedup_artist AS t1
WHERE t1.dedup = 1
);

SELECT * FROM tb_web_site 
	

CREATE TABLE tb_artist AS (
	SELECT t1."date"
	,t1."rank"
	,t1.artist
	,t1.song 
FROM PUBLIC."Billboard" AS t1 
WHERE t1.artist = 'AC/DC' 
ORDER BY t1.artist, t1.song, t1."date"
);

DROP TABLE tb_artist;

SELECT * FROM tb_artist ;

CREATE VIEW vw_artist AS(
WITH cte_dedup_artist AS (
SELECT t1."date"
	,t1."rank"
	,t1.artist
	,row_number() over(partition by artist order by artist, "date") AS dedup
FROM tb_artist  AS t1
ORDER BY t1.artist, t1."date"
)
SELECT t1."date"
	,t1."rank"
	,t1.artist
FROM cte_dedup_artist AS t1
WHERE t1.dedup = 1
)
;

DROP VIEW vw_artist;

SELECT * FROM vw_artist


INSERT INTO tb_artist (
SELECT t1."date"
	,t1."rank"
	,t1.artist
	,t1.song 
FROM PUBLIC."Billboard" AS t1 
WHERE t1.artist LIKE 'Elvis%' 
ORDER BY t1.artist, t1.song, t1."date"
);

SELECT * FROM vw_artist


CREATE VIEW vw_song as(
WITH cte_dedup_artist AS (
SELECT t1."date"
	,t1."rank"
	,t1.artist
	,t1.song
	,row_number() OVER (PARTITION BY artist, song ORDER BY artist, song, "date") AS dedup
FROM tb_artist AS t1
ORDER BY t1.artist, t1.song,t1."date"
)
SELECT t1."date"
	,t1."rank"
	,t1.artist
	,t1.song
FROM cte_dedup_artist AS t1
WHERE t1.dedup = 1
);

SELECT * FROM vw_song;


INSERT INTO tb_artist (
SELECT t1."date"
	,t1."rank"
	,t1.artist
	,t1.song 
FROM PUBLIC."Billboard" AS t1
WHERE t1.artist LIKE 'Adele%'
ORDER BY t1.artist, t1.song, t1."date"
);

SELECT * FROM vw_artist;
SELECT * FROM vw_song;

DROP VIEW vw_song;

CREATE VIEW vw_song AS(
WITH cte_dedup_artist AS(
SELECT t1."date"
	,t1."rank"
	,t1.song
	,row_number() over(partition by song order by song,  "date") as dedup
FROM tb_artist  AS t1
ORDER BY t1.song, t1."date"
)
SELECT t1."date"
	,t1."rank"
	,t1.song
FROM cte_dedup_artist AS t1
WHERE t1.dedup = 1
);

SELECT * FROM vw_song;
