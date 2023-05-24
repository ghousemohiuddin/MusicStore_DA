select * from album;
select * from artist;
select * from customer;
select * from employee;
select * from genre;
select * from invoice;
select * from invoice_line;
select * from media_type;
select * from playlist;
select * from playlist_track;
select * from track;

/*--1. Who is the senior most employee based on job title?*/
select * from employee where reports_to is null;

/*--2. Which countries have the most Invoices?*/
select billing_country, count(billing_country) bc from invoice group by billing_country order by bc desc limit 5;

/*--3. What are top 3 values of total invoice?*/
select * from invoice order by total desc limit 3;

/*--4. Which city has the best customers? 
--We would like to throw a promotional Music Festival in the city we made the most money. 
--Write a query that returns one city that has the highest sum of invoice totals. 
--Return both the city name & sum of all invoice totals.*/
select billing_city, sum(total) from invoice group by billing_city order by sum(total) desc limit 1;

/*--5. Who is the best customer? 
--The customer who has spent the most money will be declared the best customer. 
--Write a query that returns the person who has spent the most money.*/
select c.customer_id,c.first_name,c.last_name,sum(i.total) from customer c 
inner join invoice i on c.customer_id=i.customer_id group by c.customer_id order by sum(i.total) desc limit 1;

/*--6. Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
--Return your list ordered alphabetically by email starting with A.*/
select distinct c.email,c.first_name,c.last_name,g.name from customer c 
inner join invoice i on c.customer_id=i.customer_id 
inner join invoice_line il on i.invoice_id=il.invoice_id
inner join track t on il.track_id=t.track_id
inner join genre g on t.genre_id=g.genre_id
where g.name='Rock' order by email asc;

/*--7. Lets invite the artists who have written the most rock music in our dataset. 
--Write a query that returns the Artist name and total track count of the top 10 rock bands*/
select ar.artist_id,ar.name, count(ar.artist_id) tracks_count  from artist ar 
inner join album al on ar.artist_id=al.artist_id
inner join track t on al.album_id=t.album_id
inner join genre g on g.genre_id=t.genre_id
where g.name='Rock'
group by ar.artist_id order by tracks_count desc limit 10; 

/*--8. Return all the track names that have a song length longer than the average song length. 
--Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first.*/
select name, milliseconds from track 
where milliseconds > (select avg(milliseconds) from track) order by milliseconds desc;

/*--9. Find how much amount spent by each customer on artists? 
--Write a query to return customer name, artist name and total spent*/
with best_selling_artist as (
	select ar.artist_id as artist_id, ar.name as artist_name,sum(il.unit_price*il.quantity) as total_sales
	from invoice_line il 
	inner join track t on il.track_id=t.track_id
	inner join album al on al.album_id=t.album_id
	inner join artist ar on ar.artist_id=al.artist_id
	group by 1 order by 3 desc 
)
select c.customer_id, c.first_name,c.last_name,b.artist_name,sum(il.unit_price*il.quantity) as total_spent
from customer c 
inner join invoice i on c.customer_id=i.customer_id
inner join invoice_line il on il.invoice_id=i.invoice_id
inner join track t on t.track_id=il.track_id
inner join album al on al.album_id=t.album_id
inner join best_selling_artist b on b.artist_id=al.artist_id
group by 1,2,3,4
order by 1;

/*--10. We want to find out the most popular music Genre for each country. 
--We determine the most popular genre as the genre with the highest amount of purchases. 
--Write a query that returns each country along with the top Genre. 
--For countries where the maximum number of purchases is shared return all Genres*/
with popular_genre as
(
	select c.country, g.name, g.genre_id, count(il.quantity) as purchases,
	row_number() over(partition by c.country order by count(il.quantity) desc) as row_num
	from customer c 
	inner join invoice i on i.customer_id=c.customer_id
	inner join invoice_line il on il.invoice_id=i.invoice_id
	inner join track t on t.track_id=il.track_id
	inner join genre g on g.genre_id=t.genre_id
	group by 1,2,3 order by 1 asc, 4 desc
)
select * from popular_genre where row_num<=1;


/*11. Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount.*/
with customer_with_country as(
	select c.customer_id, first_name,last_name,billing_country, sum(total) as total_spending,
	row_number() over(partition by billing_country order by sum(total) desc) as row_num
	from customer c
	inner join invoice i on i.customer_id=c.customer_id
	group by 1,2,3,4
	order by 4 asc, 5 desc
)
select * from customer_with_country where row_num <= 1;




