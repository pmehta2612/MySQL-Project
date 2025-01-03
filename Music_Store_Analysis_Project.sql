-- Music Store Data Analysis
-- Easy-Level Questions
-- Question 1: Who is the senior most employee based on job title?
select *
from employee
order by levels desc
limit 1;

-- Question 2: Which countries have the most Invoices?
select billing_country as Country, count(invoice_id) as Invoices
from invoice
group by billing_country
order by invoices desc;

-- Question 3: What are top 3 values of total invoice?
select total
from invoice
order by total desc
limit 3;

-- Question 4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
-- Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals
select billing_city as City, sum(total) as Invoice_Totals
from invoice
group by billing_city
order by Invoice_Totals desc
limit 1;

-- Question 5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
-- Write a query that returns the person who has spent the most money.
select c.customer_id, c.first_name, c.last_name, sum(i.invoice_id) as Invoices
from invoice i
join customer c
on i.customer_id = c.customer_id
group by c.customer_id, c.first_name, c.last_name
order by Invoices desc
limit 1;

-- Moderate Level Questions
-- Question 6: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
-- Return your list ordered alphabetically by email starting with A.
select distinct c.email, c.first_name, c.last_name
from customer c
join invoice i
on c.customer_id = i.customer_id
join invoice_line il
on i.invoice_id = il.invoice_id
where track_id in ( select t.track_id
					  from track t
					  join genre g
					  on t.genre_id = g.genre_id
					  where g.name like 'Rock' )
order by c.email asc;

-- Question 7: Let's invite the artists who have written the most rock music in our dataset. 
-- Write a query that returns the Artist name and total track count of the top 10 rock bands
select a.artist_id, a.name, count(a.artist_id) as Number_of_Songs
from track t
join album ab
on t.album_id = ab.album_id
join artist a
on ab.artist_id = a.artist_id
join genre g
on t.genre_id = g.genre_id
where g.name like 'Rock'
group by a.artist_id, a.name
order by Number_of_Songs desc
limit 10;

-- Question 8: Return all the track names that have a song length longer than the average song length. 
-- Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first
select name, milliseconds
from track 
where milliseconds >
(select avg(milliseconds) as Avg_Song_Length
from track)
order by milliseconds desc;

-- Advanced Level Questions
-- Question 9: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent
with best_selling_artists as (
select a.artist_id as Artist_id, a.name as Artist_name, sum(il.unit_price * il.quantity) as Total_Sales
from invoice_line il
join track t
on il.track_id = t.track_id
join album al
on t.album_id = al.album_id
join artist a
on al.artist_id = a.artist_id
group by a.artist_id, a.name
order by Total_sales desc
limit 1
)
select c.customer_id, c.first_name, c.last_name, bsa.Artist_name, sum(il.unit_price * il.quantity) as Total_Spent
from customer c
join invoice i
on c.customer_id = i.customer_id
join invoice_line il
on i.invoice_id = il.invoice_id
join track t
on t.track_id = il.track_id
join album al
on al.album_id = t.album_id
join best_selling_artists bsa
on bsa.artist_id = al.artist_id
group by 1,2,3,4
order by 5 desc;

-- Question 10: We want to find out the most popular music Genre for each country. We determine the most popular genre 
-- as the genre with the highest amount of purchases. Write a query that returns each country along with the top Genre. 
-- For countries where the maximum number of purchases is shared return all Genres
with popular_genre as (
select c.country as Country, count(il.quantity) as Purachases, g.genre_id, g.name,
row_number() over (partition by c.country order by count(il.quantity) desc) as Row_Num
from customer c
join invoice i
on c.customer_id = i.customer_id
join invoice_line il
on il.invoice_id = i.invoice_id
join track t
on t.track_id = il.track_id
join genre g
on g.genre_id = t.genre_id
group by 1,3,4
order by 1 asc, 2 desc
)
select * from popular_genre
where row_num <= 1;

-- Question 11: Write a query that determines the customer that has spent the most on music for each country. 
-- Write a query that returns the country along with the top customer and how much they spent. 
-- For countries where the top amount spent is shared, provide all customers who spent this amount

-- Method - 1 (Recursive CTE)
with recursive customer_on_country as
(
select c.customer_id, c.first_name, c.last_name, i.billing_country, sum(i.total) as Total_Spent
from customer c
join invoice i
on c.customer_id = i.customer_id
group by 1,2,3,4
order by 1,5 desc
),
country_max_spending as
(
select billing_country, max(Total_Spent) as Maximum_Spend
from customer_on_country
group by 1
order by 2 desc
)
select cc.first_name, cc.last_name, cc.billing_country as Country, cc.Total_Spent
from customer_on_country cc
join country_max_spending cms
on cc.billing_country = cms.billing_country
where cc.total_spent = cms.Maximum_Spend
order by 1 desc;

-- Method - 2 (CTE)
with country_spending as (
select c.customer_id as Cust_ID, c.first_name as First_Name, c.last_name as Last_Name, i.billing_country as Country, sum(i.total) as Total_Spent,
row_number() over (partition by i.billing_country order by sum(i.total) desc) as Row_Num
from customer c
join invoice i
on c.customer_id = i.customer_id
group by 1,2,3,4
order by 4 asc, 5 desc
)
select *
from country_spending
where row_num <= 1;