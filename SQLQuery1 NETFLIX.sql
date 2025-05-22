SELECT * FROM netflix_titles

--1. Count the number of Movies & Shows
SELECT type,
    COUNT(*) AS Total_no_of_Content
FROM netflix_titles
GROUP BY type

--2. Find the most common rating for movies and tv shows 
WITH Rating_table AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS Rating_Count,
        RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) AS Ranking
    FROM netflix_titles
    GROUP BY type, rating
)
SELECT *
FROM Rating_table
WHERE Ranking = 1

--3.List all the movies released in a specific year (eg.2020)
SELECT * FROM netflix_titles
WHERE release_year = '2020' AND type = 'Movie'

--4. Find the top 5 countries with the most content on Netflix
WITH COUNTRY_TABLE AS (
						SELECT 
							title,
							LTRIM(RTRIM(value)) AS country
						FROM netflix_titles
						CROSS APPLY 
							STRING_SPLIT(country, ',')
						WHERE country IS NOT NULL
						)
SELECT TOP 5 country,
		COUNT(*) AS CONTENT_COUNT
FROM COUNTRY_TABLE
GROUP BY country
ORDER BY CONTENT_COUNT DESC

--5. Identify the longest movie or TV show duration
WITH Duration_Parsed AS (
						  SELECT 
							type,
							title,
							duration,
							CAST(LEFT(duration, CHARINDEX(' ', duration) - 1) AS INT) AS duration_num
						  FROM netflix_titles
						)
SELECT type, title, duration
FROM Duration_Parsed
WHERE duration_num = (
					  SELECT MAX(duration_num)
					  FROM Duration_Parsed AS dp2
					  WHERE dp2.type = Duration_Parsed.type
					)
ORDER BY type
  
--6. Find content added in the last 5 years
SELECT title, release_year
FROM netflix_titles
WHERE release_year >= YEAR(GETDATE()) - 5
ORDER BY release_year DESC

--7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
SELECT * FROM netflix_titles
WHERE director LIKE '%Rajiv Chilaka%'

--8. List all TV shows with more than 5 seasons
WITH Duration_Parsed AS (
						  SELECT 
							type,
							title,
							duration,
							CAST(LEFT(duration, CHARINDEX(' ', duration) - 1) AS INT) AS duration_num
						  FROM netflix_titles
						)
SELECT type, title, duration
FROM Duration_Parsed
WHERE duration_num > 5 AND type = 'TV Show'
--9. Count the number of content items in each genre
WITH GENRE_TABLE AS (
						SELECT 
							title,
							LTRIM(RTRIM(value)) AS GENRE
						FROM netflix_titles
						CROSS APPLY 
							STRING_SPLIT(listed_in, ',')
						)
SELECT GENRE, COUNT(*) AS NO_OF_CONTENT_ITEMS
 FROM GENRE_TABLE
 GROUP BY GENRE
--10. Find each year and the average numbers of content released in INDIA. return top 5 year with highest avg content release
WITH COUNTRY_TABLE AS (
						SELECT 
							title,
							release_year,
							LTRIM(RTRIM(value)) AS country
						FROM netflix_titles
						CROSS APPLY 
							STRING_SPLIT(country, ',')
						WHERE country IS NOT NULL
						),
	Yearly_India_Content AS (
		SELECT 
			release_year,
			COUNT(*) AS content_count
		FROM COUNTRY_TABLE
		WHERE country = 'India'
		GROUP BY release_year
	)
SELECT TOP 5 release_year,
    AVG(content_count * 1.0) AS avg_content_per_year_in_india
FROM Yearly_India_Content
GROUP BY release_year
ORDER BY avg_content_per_year_in_india DESC
--11. List all movies that are documentaries
WITH GENRE_TABLE AS (
						SELECT 
							title,
							type,
							LTRIM(RTRIM(value)) AS GENRE
						FROM netflix_titles
						CROSS APPLY 
							STRING_SPLIT(listed_in, ',')
						)
SELECT *
 FROM GENRE_TABLE
  WHERE GENRE = 'Documentaries' AND type = 'Movie'

--12. Find all content without a director
SELECT * FROM netflix_titles
WHERE director IS NULL

--13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
SELECT *
FROM netflix_titles
WHERE cast LIKE '%Salman Khan%' AND release_year >= YEAR(GETDATE()) - 10

--14. Find the top 10 actors who have appeared in the highest number of movies produced in India
WITH ACTORS_TABLE AS (
						SELECT 
							title,
							LTRIM(RTRIM(value)) AS Actors
						FROM netflix_titles
						CROSS APPLY 
							STRING_SPLIT(cast, ',')
						WHERE country LIKE '%India%'
						)
SELECT TOP 10 Actors,
			COUNT(*) AS NO_OF_MOVIES
FROM ACTORS_TABLE
GROUP BY Actors
ORDER BY NO_OF_MOVIES DESC

//*15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field.
Label content containing these keywords as 'Bad' and all othercontent as 'Good'. Count how many items fall into each category.*//
WITH CATEGORY_TABLE AS(
		SELECT title,
		CASE 
			WHEN description LIKE '%kill%' OR description LIKE '%violence%' THEN 'Bad'
			ELSE 'Good'
		END AS content_category
		FROM netflix_titles
		)
SELECT content_category,
	COUNT (*) AS NO_OF_CONTENT_ITEMS
FROM CATEGORY_TABLE
GROUP BY content_category