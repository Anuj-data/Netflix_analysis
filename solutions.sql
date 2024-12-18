--Netfilx Project

CREATE TABLE Netflix
(
	show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);


select *
from netflix;

---Business problems 

--1. Count the number of Movies vs TV Shows

select 
	type,
	count(show_id) AS total_content
from
	netflix
group by 
	type;


----2. Find the most common rating for movies and TV shows

SELECT 
    type, 
    rating, 
    rating_count
FROM (
    SELECT 
        type, 
        rating, 
        COUNT(*) AS rating_count,
        RANK() OVER (PARTITION BY type ORDER BY COUNT(*) DESC) AS rank
    FROM 
        netflix
    GROUP BY 
        type, rating
) ranked
WHERE 
    rank = 1;



----3. List all movies released in a specific year (e.g., 2020)

select 
	listed_in,
	release_year
from
	netflix
where
	release_year = 2020;



---4. Find the top 5 countries with the most content on Netflix

SELECT 
    country,
    COUNT(country) AS country_with_most_content
FROM 
    netflix
GROUP BY 
    country
ORDER BY 
    country_with_most_content DESC
LIMIT 5;


--5. Identify the longest movie

SELECT 
	listed_in,
	duration
from
	netflix
where
	duration = (select MAX(duration) from netflix);

---6. Find content added in the last 5 years

select 
	listed_in,
	release_year
from
	netflix
where
	release_year  BETWEEN 2020 AND 2024;


----7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT 
	listed_in AS Movies,
	director
from
	netflix
where 
	director = 'Rajiv Chilaka';


--8. List all TV shows with more than 5 seasons

SELECT
    listed_in,
    CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) AS Number_of_seasons
FROM
    netflix
WHERE
    type = 'TV Show' 
    AND CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) > 5;


--9. Count the number of content items in each genre


SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre,
	COUNT(*) as total_content
FROM netflix
GROUP BY 1


--10.Find each year and the average numbers of content release in India on netflix.
--return top 5 year with highest avg content release!

SELECT 
	country,
	release_year,
	COUNT(show_id) as total_release,
	ROUND(
		COUNT(show_id)::numeric/
								(SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100 
		,2
		)
		as avg_release
FROM netflix
WHERE country = 'India' 
GROUP BY country, 2
ORDER BY avg_release DESC 
LIMIT 5



----11. List all movies that are documentaries

select
	listed_in,
	type
from
	netflix
where
	listed_in like '%Documentaries%';



---12. Find all content without a director


select
	*
from
	netflix
where
	director is null;


---13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

select
	casts,
	listed_in,
	release_year
from
	netflix
where
	casts LIKE '%Salman Khan%'
	AND 
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10


/* 14. Find the top 10 actors who have appeared in the highest number of movies produced in 
India.*/

SELECT
    UNNEST(STRING_TO_ARRAY(casts, ',')) AS actors,
    COUNT(*) AS total_content
FROM
    netflix
WHERE
    country LIKE '%India%'
GROUP BY
    actors
ORDER BY
    total_content DESC
LIMIT
	10;

	
/* 15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.*/

SELECT 
    category,
	TYPE,
    COUNT(*) AS content_count
FROM (
    SELECT 
		*,
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY 1,2
ORDER BY 2



