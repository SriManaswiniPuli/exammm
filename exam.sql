CREATE TABLE artists (
    artist_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    country VARCHAR(50) NOT NULL,
    birth_year INT NOT NULL
);

CREATE TABLE artworks (
    artwork_id INT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    artist_id INT NOT NULL,
    genre VARCHAR(50) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (artist_id) REFERENCES artists(artist_id)
);

CREATE TABLE sales (
    sale_id INT PRIMARY KEY,
    artwork_id INT NOT NULL,
    sale_date DATE NOT NULL,
    quantity INT NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (artwork_id) REFERENCES artworks(artwork_id)
);

INSERT INTO artists (artist_id, name, country, birth_year) VALUES
(1, 'Vincent van Gogh', 'Netherlands', 1853),
(2, 'Pablo Picasso', 'Spain', 1881),
(3, 'Leonardo da Vinci', 'Italy', 1452),
(4, 'Claude Monet', 'France', 1840),
(5, 'Salvador Dalí', 'Spain', 1904);

INSERT INTO artworks (artwork_id, title, artist_id, genre, price) VALUES
(1, 'Starry Night', 1, 'Post-Impressionism', 1000000.00),
(2, 'Guernica', 2, 'Cubism', 2000000.00),
(3, 'Mona Lisa', 3, 'Renaissance', 3000000.00),
(4, 'Water Lilies', 4, 'Impressionism', 500000.00),
(5, 'The Persistence of Memory', 5, 'Surrealism', 1500000.00);

INSERT INTO sales (sale_id, artwork_id, sale_date, quantity, total_amount) VALUES
(1, 1, '2024-01-15', 1, 1000000.00),
(2, 2, '2024-02-10', 1, 2000000.00),
(3, 3, '2024-03-05', 1, 3000000.00),
(4, 4, '2024-04-20', 2, 1000000.00)

select * from artists
select * from artworks
select * from sales
--### Section 1: 1 mark each

--1. Write a query to display the artist names in uppercase.
select upper(name) from artists;

--2. Write a query to find the total amount of sales for the artwork 'Mona Lisa'.
select title,total_amount from artworks
inner join sales
on artworks.artwork_id=sales.artwork_id
where title='Mona Lisa';
--3. Write a query to calculate the price of 'Starry Night' plus 10% tax.
select price*1.1 from artworks 
where title='Starry Night'
--4. Write a query to extract the year from the sale date of 'Guernica'.
select datepart(year,sale_date) from sales
inner join artworks
on sales.artwork_id=artworks.artwork_id
where title='Guernica'

--### Section 2: 2 marks each

--5. Write a query to display artists who have artworks in multiple genres.
select name,artists.artist_id,count(genre) from artists
inner join artworks
on artists.artist_id=artworks.artist_id
group by name,artists.artist_id,genre
having count(genre)>1

--6. Write a query to find the artworks that have the highest sale total for each genre.
with top_cte
as
(
select title,genre,total_amount,
rank() over (partition by genre order by total_amount desc)  as rankk from artworks
inner join sales
on artworks.artwork_id=sales.artwork_id
group by genre,title,total_amount
)
select * from top_cte where rankk=1;
--7. Write a query to find the average price of artworks for each artist.
select artist_id,avg(price) as avgg from artworks
group by artist_id;

--8. Write a query to find the top 2 highest-priced artworks and the total quantity sold for each.

with top2_ctee
as
(
select title,price,sum(quantity) as total_quantity,
rank() over (order by price desc) as rankk from artworks
inner join sales
on artworks.artwork_id=sales.artwork_id
group by title,price
)
select * from top2_ctee where rankk=1 or rankk=2;
--9. Write a query to find the artists who have sold more artworks than the average number of artworks sold per artist.
select * from artists;
select * from artworks;
select * from sales;

select a.artist_id,a.name from artists a
inner join artworks b
on a.artist_id=b.artist_id
inner join sales s
on b.artwork_id=s.artwork_id
group by a.artist_id,name
having sum(s.quantity)>(select avg(quantity) from sales);

--10. Write a query to display artists whose birth year is earlier than the average birth year of artists from their country.

select [name],birth_year,country 
from artists
where birth_year<(select avg(birth_year) from artists)
group by birth_year,name,country
order by birth_year desc
--11. Write a query to find the artists who have created artworks in both 'Cubism' and 'Surrealism' genres.
select name from artists 
inner join artworks
on artsits.artist_id=artworks.artist_id
where genre='Cubism' and genre='Surrealism';

--12. Write a query to find the artworks that have been sold in both January and February 2024.
select title from artworks 
inner join sales
on arworks.artwork_id=sales.artwork_id
where datepart(month,sale_date)=01 and datepart(month,sale_date)=02 and datepart(year,sale_date)=2024
--13. Write a query to display the artists whose average artwork price is higher than every artwork price in the 'Renaissance' genre.
select * from artists;
select * from artworks;
select * from sales;

select artsit_id,artwork_id from artworks
inner join sales
on artworks.artwork_id=sales.artwork_id
group by artist_id,artwork_id
having avg(price)>all(select price from sales where genre='Renaissance')

--14. Write a query to rank artists by their total sales amount and display the top 3 artists.
select top 3 artist_id,rank() over (order by total_amount desc) as rankk 
from artworks
inner join sales
on artworks.artwork_id=sales.artwork_id

--15. Write a query to create a non-clustered index on the `sales` table to improve query performance for queries filtering by `artwork_id`.

CREATE NONCLUSTERED INDEX ix_index
ON sales (artwork_id)
exec sp_helpindex sales
--### Section 3: 3 Marks Questions

--16.  Write a query to find the average price of artworks for each artist and only include artists whose average artwork price is higher than the overall average artwork price.
select a.artist_id,a.name,avg(price) as avgg from artists a
inner join artworks b
on a.artist_id=b.artist_id
inner join sales s
on b.artwork_id=s.artwork_id
group by a.artist_id,a.name
having avg(b.price)>(select avg(price) from sales);
--17.  Write a query to create a view that shows artists who have created artworks in multiple genres.
create view art_mul
as
select name,artists.artist_id,count(genre)  as countt from artists
inner join artworks
on artists.artist_id=artworks.artist_id
group by name,artists.artist_id,genre
having count(genre)>1

select * from art_mul;
--18.  Write a query to find artworks that have a higher price than the average price of artworks by the same artist.

select a.artwork_id from artworks a
inner join artists b
on a.artist_id=b.artist_id
group by a.artwork_id
having b.price>(select avg(price) from artworks);

--### Section 4: 4 Marks Questions

select * from artists
select * from artworks

--19.  Write a query to convert the artists and their artworks into JSON format.
select 
	   artists.artist_id as [@id],
	   artists.name as 'artist.name',
	   artists.country as 'artist.genre',
	   artists.birth_year as 'artist.birthyear',
	   artworks.artwork_id as 'artwork.artworkid',
	   artworks.title as 'artwork.title',
	   artworks.artist_id as 'artwork.id',
	   artworks.genre as 'artwork.genre',
	   artworks.price as 'artwork.price'
from artists
join artworks
on artsits.artist_id=artworks.artist_id
for json path,root('info')

--20.  Write a query to export the artists and their artworks into XML format.



select artists.artist_id as [@artistid],
       artists.name as [artist/name],
	   artists.country as [artist/genre],
	   artists.birth_year as [artist/birthyear],
	   artworks.artwork_id as [artwork/artworkid],
	   artworks.title as [artwork/title],
	   artworks.artist_id as [artwork/artistid],
	   artworks.genre as [artwork/genre],
	   artworks.price as [artwork/price]
from artists
join artworks
on artsits.artist_id=artworks.artist_id
for xml path,root('info')

--#### Section 5: 5 Marks Questions

--21. Create a stored procedure to add a new sale and update the total sales for the artwork. Ensure the quantity is positive, and use transactions to maintain data integrity.
select * from artists
select * from artworks
select * from sales
CREATE PROCEDURE total_salesss
AS  
    SELECT * FROM sales;    
BEGIN TRY 
    Begin transaction
   commit transaction
 END TRY  
BEGIN CATCH  
    rollback 
END CATCH; 

Alter PROCEDURE total_salesss
    @saleid int,
    @artworkid int,
	@saledate date,
	@quantity int,
	@totalamount decimal(10,2)
As
Begin
	Begin Transaction;
	Begin Try
	
	if not Exists (Select artwork_id from sales Where artwork_id= @artworkid)
		throw 60000, 'artwork is not present!!!', 1;

    if not Exists (Select quantity from sales Where quantity>0)
		throw 60000, 'quantity not positive!!!', 1;
	
	 insert into sales values(@saleid,@artworkid,@saledate,@quantity,@totalamount)

	 update sales
	 set total_amount=@totalamount
	 where artwork_id=@artworkid

		
	Commit Transaction;
	End Try
	Begin Catch
		Rollback Transaction
		print Concat('Error number is: ', Error_number());
		print Concat('Error message is: ', Error_message());
		print Concat('Error state is: ', Error_State());
	End Catch
End

exec total_salesss @saleid=1,@artworkid=1,@saledate='2024-03-23',@quantity=3,@totalamount=4000000
--22. Create a multi-statement table-valued function (MTVF) to return the total quantity sold for each genre and use it in a query to display the results.
create function dbo.mtvf()
returns @tot_quan table(genre varchar(100),quantity int)
as
begin
insert into @tot_quan
select genre,sum(quantity) as quantityy from sales 
inner join artworks
on sales.artwork_id=artworks.artwork_id
group by genre
return;
end  

select * from dbo.mtvf();


--23. Create a scalar function to calculate the average sales amount for artworks in a given genre and write a query to use this function for 'Impressionism'.

drop function dbo.avg_sales
Create Function dbo.avg_saless(@genre varchar(100))
Returns int
As
Begin
Return 
(
select avg(total_amount)  as avgg from sales inner join artworks on sales.artwork_id=artworks.artwork_id where genre=@genre group by artworks.artwork_id
)
End;
select dbo.avg_saless ('Impressionism');

--24. Create a trigger to log changes to the `artworks` table into an `artworks_log` table, capturing the `artwork_id`, `title`, and a change description.
create table artworks_log
(
  artwork_id int,
  title varchar(100),
  change_des varchar(100)
)

insert into artworks_log values
(1,'title1','change1'),
(2,'title2','change2'),
(3,'title3','change3')
Create Trigger trg_updating
on artworks
After update--action
As
Begin
if update(title)
	 begin
	  Insert into 
	select i.artwork_id,d.title,i.title
	from inserted i
	join Deleted d  
    on i.artwork_id=d.artwork_id
	end     
End  

select * from artworks
select * from artworks_log 
--25. Write a query to create an NTILE distribution of artists based on their total sales, divided into 4 tiles.
[13:33] Akhila Mucharla
select name,sum(total_amount),rank() over (order by sum(total_amount) desc)  as sales_amount,NTILE(4) OVER (ORDER BY sum(total_amount) desc) as Group_Number from sales s

join artworks ar on s.artwork_id = ar.artwork_id

join artists a on ar.artist_id = a.artist_id

Group by a.artist_id,name



### Normalization (5 Marks)

26. **Question:**
    Given the denormalized table `ecommerce_data` with sample data:

| id  | customer_name | customer_email      | product_name | product_category | product_price | order_date | order_quantity | order_total_amount |
| --- | ------------- | ------------------- | ------------ | ---------------- | ------------- | ---------- | -------------- | ------------------ |
| 1   | Alice Johnson | alice@example.com   | Laptop       | Electronics      | 1200.00       | 2023-01-10 | 1              | 1200.00            |
| 2   | Bob Smith     | bob@example.com     | Smartphone   | Electronics      | 800.00        | 2023-01-15 | 2              | 1600.00            |
| 3   | Alice Johnson | alice@example.com   | Headphones   | Accessories      | 150.00        | 2023-01-20 | 2              | 300.00             |
| 4   | Charlie Brown | charlie@example.com | Desk Chair   | Furniture        | 200.00        | 2023-02-10 | 1              | 200.00             |

Normalize this table into 3NF (Third Normal Form). Specify all primary keys, foreign key constraints, unique constraints, not null constraints, and check constraints.
create table customers
(
customer_id int primary key identity(1,1,
customer_name varchar(100) not null ,
customer_email varchar(100) not null)

create table products
(product_id int primary key identity(1,1),
product_name varchar(100) not null,
product_price int not null,
product_category int not null)

create table orders
(order_id int primary key identity(1,1),
order_date date not null ,
order_quantity int not null,
order total_ampunt int not null)

create table inj(
id int primay key identity(1,1),
product_id int,
order_id int,
foreign key(customer_id) refrences customers(customer_id),
foreign key(product_id) refrences products(product_id),
foreign key(order_id) refrences products(order_id),




### ER Diagram (5 Marks)

27. Using the normalized tables from Question 27, create an ER diagram. Include the entities, relationships, primary keys, foreign keys, unique constraints, not null constraints, and check constraints. Indicate the associations using proper ER diagram notation.