--CREATE TABLE BILLBOARD

CREATE TABLE PUBLIC."Billboard" (
	"date" DATE NULL
	,"rank" int4 NULL
	,song VARCHAR(300) NULL
	,artist VARCHAR(300) NULL
	,"last-week" int4 NULL
	,"peak-rank" int4 NULL
	,"weeks-on-board" int4 NULL
	);

SELECT count(*) AS quantidade
FROM PUBLIC."Billboard" limit 100;

SELECT *
FROM PUBLIC."Billboard" limit 100;

SELECT t1."date"
	,t1."rank"
	,t1.song
	,t1.artist
	,t1."last-week"
	,t1."peak-rank"
	,t1."weeks-on-board"
FROM PUBLIC."Billboard" AS t1 limit 100;

SELECT t1.song
	,t1.artist
FROM PUBLIC."Billboard" AS t1
WHERE t1.artist = 'Chuck Berry';

SELECT t1.artist
	,t1.song
	,count(*) AS "#song"
FROM PUBLIC."Billboard" AS t1
WHERE
	--t1.artist = 'Chuck Berry' or t1.artist = 'Frankie Vaughan'
	t1.artist IN ('Chuck Berry','Frankie Vaughan')
GROUP BY t1.artist, t1.song
ORDER BY "#song" DESC;


