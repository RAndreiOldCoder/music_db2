--1. количество исполнителей в каждом жанре;
SELECT g.name genre, COUNT(p.performer_id) count_performers FROM Genres g
LEFT JOIN Genres_Performers p ON g.id = p.genre_id
GROUP BY g.name;
--2. количество треков, вошедших в альбомы 2019-2020 годов;
SELECT COUNT(t.id) count_2019_2020 FROM Tracks t
RIGHT JOIN Albums a ON t.album_id = a.id
WHERE year_ BETWEEN 2019 AND 2020;
--3. средняя продолжительность треков по каждому альбому;
SELECT a.name album, AVG(t.duration) avg_duration FROM Tracks t
RIGHT JOIN Albums a ON t.album_id = a.id
GROUP BY a.name;
--4. все исполнители, которые не выпустили альбомы в 2020 году;
SELECT name FROM Performers 
WHERE name NOT IN (
	SELECT p.name FROM Performers p
	LEFT JOIN Performers_Albums pa ON p.id = pa.performer_id
	LEFT JOIN Albums a ON pa.album_id = a.id
	WHERE year_ = 2020
	);
--5. названия сборников, в которых присутствует конкретный исполнитель (выберите сами);
SELECT DISTINCT c.name collections_with_Maksim FROM Collections c 
JOIN Collections_Tracks ct ON c.id = ct.collection_id
JOIN Tracks t ON ct.track_id = t.id
JOIN Albums a ON t.album_id = a.id
JOIN Performers_Albums pa ON a.id = pa.album_id
JOIN Performers p ON pa.performer_id = p.id
WHERE p.name iLIKE '%%maksim%%';
--6. название альбомов, в которых присутствуют исполнители более 1 жанра;
SELECT DISTINCT a.name FROM Albums a 
JOIN Performers_Albums pa ON a.id = pa.album_id
WHERE pa.performer_id IN (
	SELECT performer_id FROM (
		SELECT gp.performer_id, COUNT(gp.genre_id) FROM Genres_Performers gp
		GROUP BY gp.performer_id
		HAVING COUNT(gp.genre_id)>1
		) Subtable1
	);
--7. наименование треков, которые не входят в сборники;
SELECT name FROM Tracks t 
WHERE id NOT IN (
	SELECT DISTINCT track_id FROM Collections_Tracks); 
--8. исполнителя(-ей), написавшего самый короткий по продолжительности трек (теоретически таких треков может быть несколько);
SELECT DISTINCT p.name FROM Performers p
JOIN Performers_Albums pa ON p.id = pa.performer_id
WHERE album_id IN (
	SELECT album_id FROM Tracks
	WHERE duration = (
		SELECT MIN(duration) FROM Tracks
		)
	);
--9. название альбомов, содержащих наименьшее количество треков.
DROP TABLE IF EXISTS Subtable1;
SELECT a.name, COUNT(t.id) amount INTO Subtable1 FROM Albums a
JOIN Tracks t ON a.id = t.album_id
GROUP BY a.name;

SELECT * FROM Subtable1
WHERE amount = (
	SELECT MIN(amount) FROM Subtable1
	);