create database miniproject08;
use miniproject08;


create table Customer(
	CustomerID int primary key auto_increment,
    CustomerName nvarchar(50) not null,
    Email varchar(50) not null unique,
	Gender int Default 1 not null CHECK(Gender>=0 and Gender<=1), 
    DOB DATE,
    is_VIP int DEFAULT 0 not null CHECK(is_VIP >= 0 and is_VIP <= 1)
);


create table Category(
		CategoryID int primary key auto_increment,
        CategoryName VARCHAR(100) NOT NULL
);

create table Product(
	ProductID int primary key auto_increment,
    ProductName varchar(30) not null,
    Price DECIMAL(18,2) check(Price >= 0) DEFAULT 0,
    CategoryID int,
    foreign key (CategoryID) references Category(CategoryID)
);

create table Orders(
	OrderID int primary key auto_increment,
    OrderDate DATETIME default current_timestamp,
    CustomerID int NOT NULL,
    Foreign key (CustomerID) references Customer(CustomerID)
);
-- DATETIME : lấy giờ Chung (tgian ở hệ thống)
-- TIMEStamp : lấy giờ theo quốc gia


create table Order_Detail(
	OrderDeitalID int primary key auto_increment,
    OrderID int,
    ProductID int,
    Quantity int not null check(Quantity >= 0),
    UnitPrice DECIMAL(18,2) not null CHECK(unitPrice >= 0),
    foreign key (OrderID) references Orders(OrderID),
    foreign key (ProductID) references Product(ProductID)
);


-- Phần 2: Dữ liệu
INSERT INTO Customer (CustomerName, Email, Gender, DOB , is_VIP) 
VALUES
('Nguyễn Văn An', 'nva@email.com', 1, '2000-01-15', 1),
('Trần Thị Bình', 'ttb@email.com', 0, '1998-05-20', 0),
('Lê Văn Cường', 'lvc@email.com', 1, '1995-10-10', 1),
('Phạm Thị Dung', 'ptd@email.com', 0, '2002-03-05', 1),
('Hoàng Văn Em', 'hve@email.com', 1, '1999-07-25', 0);
	

INSERT INTO Category (CategoryName) 
VALUES
('Điện tử'),
('Gia dụng'),
('Thời trang'),
('Sách'),
('Thực phẩm');


INSERT INTO Product (ProductName, Price, CategoryID) 
VALUES
('Laptop Dell', 15000000, 1),
('Nồi cơm điện', 500000, 2),
('Áo sơ mi', 200000, 3),
('Sách Lập trình SQL', 150000, 4),
('Bánh ngọt', 30000, 5),
('Smartphone X', 10000000, 1),
('Bàn ủi hơi nước', 450000, 2),
('Quần Jean Nam', 350000, 3),
('Truyện tranh Conan', 25000, 4),
('Nước ngọt Coca', 15000, 5);


INSERT INTO Orders (OrderDate, CustomerID) 
VALUES
('2026-04-20 08:00:00', 1),
('2026-04-21 09:30:00', 2),
('2026-04-21 10:15:00', 3),
('2026-04-22 14:00:00', 4),
('2026-04-22 15:45:00', 5),
('2026-04-23 09:00:00', 1),
('2026-04-23 10:30:00', 2),
('2026-04-24 11:00:00', 3),
('2026-04-24 15:20:00', 5),
('2026-04-25 08:45:00', 5);


INSERT INTO Order_Detail (OrderID, ProductID, Quantity, UnitPrice) 
VALUES
(1, 1, 1, 15000000), 
(2, 2, 2, 500000),  
(3, 3, 3, 200000),   
(4, 4, 1, 150000), 
(5, 5, 5, 30000),
(6, 6, 1, 10000000), 
(7, 7, 2, 450000), 
(8, 8, 1, 350000), 
(9, 9, 3, 25000),  
(10, 10, 10, 15000);


-- Phần 3: cập nhật dữ liệu ---
-- 1. cập nhật giá bán cho 1 sản phẩm
UPDATE Product
SET price = 100000
WHERE ProductID = 2;


UPDATE Customer 
Set Email = 'nguyenvanan@gmail.com'
WHERE CustomerId = 1;





-- Phần 4: Xóa dữ liệu
DELETE FROM Order_Detail
WHERE OrderID IN (SELECT OrderID FROM Orders WHERE OrderDate < NOW());

DELETE FROM Orders
WHERE orderDate < NOW();





-- Phần 5: Truy vấn dữ liệu----
SELECT * FROM Customer;
SELECT * FROM Category;
SELECT * FROM Product;
SELECT * FROM Orders;
SELECT * FROM Order_Detail;

-- 1.
SELECT CustomerName, Email,
	(case 
		WHEN Gender = 1 then 'Nam'
        ELSE 'Nữ'
	END) AS 'Giới tính'
FROM Customer;


-- 2. 
SELECT * , (YEAR(NOW()) - YEAR(DOB)) as Age
FROM Customer 
ORDER BY Age 
LIMIT 3;

-- 3.
SELECT OrderDeitalID, c.CustomerName, p.ProductName, o.OrderDate
FROM Orders o
JOIN Customer c ON c.CustomerID = o.CustomerID
JOIN Order_Detail od ON od.OrderID = o.OrderID
JOIN Product p ON p.ProductID = od.ProductID;


-- 4.
SELECT c.CategoryID , c.CategoryName, Count(ProductID) as 'Số lượng'
FROM Product p
JOIN Category c ON c.CategoryID = p.CategoryID
GROUP BY CategoryName, c.CategoryID 
HAVING Count(ProductID) >= 2;



-- 5.
SELECT *
FROM Product
WHERE price > (Select avg(price) FROM Product);

-- 6.
SELECT * FROM Customer c
WHERE CustomerID NOT IN(SELECT CustomerID FROM Orders o WHERE c.CustomerID = o.CustomerID);


-- 7.
SELECT CategoryName, TotalRevenue
FROM (

    SELECT c.CategoryName, SUM(od.UnitPrice * od.Quantity) as TotalRevenue
    FROM Category c
    JOIN Product p ON c.CategoryID = p.CategoryID
    JOIN Order_Detail od ON p.ProductID = od.ProductID
    GROUP BY c.CategoryID, c.CategoryName
) AS SalesPerCategory
WHERE TotalRevenue > (
    SELECT AVG(TotalRevenue) * 1.2
    FROM (
        SELECT SUM(UnitPrice * Quantity) as TotalRevenue
        FROM Order_Detail od
        JOIN Product p ON od.ProductID = p.ProductID
        GROUP BY p.CategoryID
    ) AS Sub
);



-- 8.
SELECT  CategoryName, MAX(price) 'Tiền lớn nhất theo loại'
FROM Product p
JOIN category c ON c.CategoryID = p.CategoryID
GROUP BY CategoryName;


-- 9.
SELECT CustomerName as 'Khách hàng VIP'
FROM Customer
WHERE is_VIP = 1
AND CustomerID IN (
    SELECT CustomerID
    FROM Orders
    WHERE OrderID IN (
        SELECT OrderID
        FROM Order_Detail
        WHERE ProductID IN (
            SELECT ProductID
            FROM Product
            WHERE CategoryID IN (
                SELECT CategoryID
                FROM Category
                WHERE CategoryName = 'Điện tử'
            )
        )
    )
);

