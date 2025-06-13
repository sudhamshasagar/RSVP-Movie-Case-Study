USE imdb;

/* Now that you have imported the data sets, let’s explore some of the tables. 
 To begin with, it is beneficial to know the shape of the tables and whether any column has null values.
 Further in this segment, you will take a look at 'movies' and 'genre' tables.*/

-- Q1. Find the total number of rows in each table of the schema?
-- Type your code below:
	
    select count(movie_id) as row_count
    from director_mapping;
    -- There are 3876 rows present in the director_mapping table 
	select count(movie_id) as row_count
    from genre;
    -- There are 14662 rows present in the genre table
	select count(id) as row_count
    from movie;
    -- There are 7997 rows present in the movie table
    select count(id) as row_count
    from names;
    -- There are 25735 rows present in the names table
    select count(movie_id) as row_count
    from ratings;
    -- There are 7997 rows present in the ratings table
    select count(category) as row_count
    from role_mapping;
    -- There are 15615 rows present in the role_mapping table
    
-- Q2. Which columns in the movie table have null values?
-- Type your code below:
	
    select count(*) as total_row_count,
		    sum(id is NULL) as null_in_id,
            sum(title is NULL) as null_in_title,
            sum(year is NULL) as null_in_year,
            sum(date_published is NULL) as null_in_date_Published,
            sum(duration is NULL) as null_in_duration,
            sum(country is NULL) as null_in_country,
            sum(worlwide_gross_income is NULL) as null_in_wgi,
            sum(languages is NULL) as null_in_lang,
            sum(production_company is null) as null_in_prod
	from movie;
--  Country, World Gross Income, Language, Production Company are the four columns with null values
 
-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)

	select year, count(id) as number_of_movies
    from movie
    group by year;
    
    -- 3052 movies released in 217, 2944 in 2018 and 2001 in 2019.
    
    select month(date_published) as month_num, count(id) as number_of_movies
    from movie
    group by month_num
    order by month_num asc;


/*The highest number of movies is produced in the month of March.
So, now that you have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for the last year.*/
  
-- Q4. How many movies were produced in the USA or India in the year 2019??
-- Type your code below:
	
    select count(title) as number_of_movies, 
		   country,
           year
	from movie
    where year = 2019 and (country  = 'USA' or country = 'India')
    group by country, year;

/* USA and India produced more than a thousand movies(you know the exact number!) in the year 2019.
Exploring table Genre would be fun!! 
Let’s find out the different genres in the dataset.*/

-- Q5. Find the unique list of the genres present in the data set?
-- Type your code below:

	select distinct(genre)
    from genre;


/* So, RSVP Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */

-- Q6.Which genre had the highest number of movies produced overall?
-- Type your code below:

	select 
		   count(m.id) as no_of_movies, 
           g.genre
    from movie m
    inner join genre g
    on m.id = g.movie_id
    group by g.genre
    order by  no_of_movies desc;

/* So, based on the insight that just drew, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- Q7. How many movies belong to only one genre?
-- Type your code below:

	with unique_genre as (
		select movie_id
		from genre
        group by movie_id
		having count(distinct genre) = 1
	)
    select count(*) from unique_genre;

/* There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant. 
Now, let's find out the possible duration of RSVP Movies’ next project.*/

-- Q8.What is the average duration of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.)
	
    select round(avg(m.duration)) as avg_duration, g.genre
    from movie m
    inner join genre g
    on m.id = g.movie_id
    group by g.genre
    order by avg_duration desc;


/* Now you know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/

-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
-- (Hint: Use the Rank function)
	
    with genre_ranks as (
		select genre, count(movie_id) as movie_count,
        Dense_rank() Over ( order by count(movie_id)) as genre_rank
        from genre
        group by genre
	)
    select * from genre_ranks
    where genre = 'Thriller';
        

-- Segment 2:




-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|min_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		0		|			5		|	       177		  |	   2000	    		 |		0	       |	8			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+*/
-- Type your code below:

select min(avg_rating) as min_avg_rating, max(avg_rating) as max_avg_rating,
	   min(total_votes) as min_total_votes, max(total_votes) as max_total_votes,
       min(median_rating) as min_median_rating, max(median_rating) as max_median_rating
from ratings;

/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/

	with top_movies as (
			   select m.title,
					  r.avg_rating,
					  dense_rank() OVER (ORDER BY r.avg_rating desc) as movie_rank
					  from movie m
					  inner join ratings r
					  on m.id = r.movie_id
	)
	select * from top_movies
	where movie_rank <=10;

/* Do you find you favourite movie FAN in the top 10 movies with an average rating of 9.6? If not, please check your code again!!
So, now that you know the top 10 movies, do you think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight.*/

-- Q12. Summarise the ratings table based on the movie counts by median ratings.

	select median_rating, count(movie_id) as movie_count
    from ratings
    group by median_rating
    order by movie_count desc;

/* Movies with a median rating of 7 is highest in number. 
Now, let's find out the production house with which RSVP Movies can partner for its next project.*/

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??

	select m.production_company, count(m.id) as movie_count,
    DENSE_RANK() over (order by count(m.id) desc) as prod_company_rank
    from movie m
    inner join ratings r
    on m.id = r.movie_id
	where r.avg_rating > 8 AND m.production_company IS NOT NULL
    group by m.production_company;

-- Answer is Dream Warrior Pictures or National Theatre Live or both

-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?


	select g.genre, count(g.movie_id) as movie_count
    from genre g
    inner join ratings r
    on g.movie_id = r.movie_id
    inner join movie m
    on m.id = g.movie_id
    where month(m.date_published) = 3 and m.year = 2017 and country in ('USA') and r.total_votes >1000
    group by g.genre
    order by movie_count desc;


-- Lets try to analyse with a unique problem statement.
-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?


	select m.title, r.avg_rating, g.genre
    from movie m
    inner join ratings r
    on m.id = r.movie_id
    inner join genre g
    on g.movie_id = r.movie_id
    where m.title regexp '^The' and r.avg_rating > 8;


-- You should also try your hand at median rating and check whether the ‘median rating’ column gives any significant insights.
-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
-- Type your code below:
	
	select count(m.id) as movie_count
    from movie m
    inner join ratings r
    on m.id = r.movie_id
    where m.date_published > '2018-04-01'
    and m.date_published < '2019-04-01'
    and r.median_rating = 8;


-- Q17. Do German movies get more votes than Italian movies? 

	select count(r.total_votes) as total_votes , m.country
    from ratings r
    inner join movie m
    on r.movie_id = m.id
    where country in ('Germany', 'Italy')
    group by m.country
    order by total_votes desc;

-- Answer is Yes


-- Segment 3:


-- Q18. Which columns in the names table have null values??

		select sum(name is null) as name_nulls,
			   sum(height is null) as height_nulls,
			   sum(date_of_birth is null) as dob_nulls,
			   sum(known_for_movies is null) as kfm_nulls
		from names;

/* There are no Null value in the column 'name'.
The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/

-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?

	WITH Top_Genre AS (
		SELECT 
			g.genre
		FROM genre g
		JOIN ratings r ON g.movie_id = r.movie_id
		WHERE r.avg_rating > 8
		GROUP BY g.genre
		ORDER BY COUNT(*) DESC
		LIMIT 3
	)

	SELECT 
		n.name AS director_name,
		g.genre,
		COUNT(*) AS movie_count
	FROM director_mapping d
	JOIN names n ON n.id = d.name_id
	JOIN movie m ON m.id = d.movie_id
	JOIN ratings r ON m.id = r.movie_id
	JOIN genre g ON g.movie_id = m.id
	WHERE r.avg_rating > 8
	  AND g.genre IN (SELECT genre FROM Top_Genre)
	GROUP BY n.name, g.genre
	ORDER BY movie_count DESC
	LIMIT 3;

    


/* James Mangold can be hired as the director for RSVP's next project. Do you remeber his movies, 'Logan' and 'The Wolverine'. 
Now, let’s find out the top two actors.*/

-- Q20. Who are the top two actors whose movies have a median rating >= 8?


with actor_movies as (
	select count(ro.movie_id) as movie_count, n.name
	from role_mapping ro
	inner join names n
	on ro.name_id = n.id
    inner join ratings r
    on r.movie_id = ro.movie_id
    where r.median_rating >= 8
	group by n.name
	order by movie_count desc
)
select * from actor_movies;


/* Have you find your favourite actor 'Mohanlal' in the list. If no, please check your code again. 
RSVP Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/

-- Q21. Which are the top three production houses based on the number of votes received by their movies?


select m.production_company, sum(r.total_votes) as vote_count,
ROW_Number() over (order by sum(r.total_votes) desc) as prod_comp_rank
from movie m
inner join ratings r
on m.id = r.movie_id
where m.production_company is not null
group by m.production_company;


-- Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
-- RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
-- Let’s find who these actors could be.*/

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

	WITH actor_data AS (
		SELECT 
			n.name AS actor_name,
			COUNT(DISTINCT m.id) AS movie_count,
			SUM(r.avg_rating * r.total_votes) / SUM(r.total_votes) AS weighted_avg_rating,
			SUM(r.total_votes) AS total_votes
		FROM names n
		JOIN role_mapping ro ON n.id = ro.name_id
		JOIN movie m ON m.id = ro.movie_id
		JOIN ratings r ON r.movie_id = m.id
		WHERE m.country LIKE '%India%'
		GROUP BY n.name
		HAVING COUNT(DISTINCT m.id) >= 5
	)

	SELECT *,
		   RANK() OVER (
			   ORDER BY weighted_avg_rating DESC, total_votes DESC
		   ) AS actor_rank
	FROM actor_data
	LIMIT 10;

-- Top actor is Vijay Sethupathi

