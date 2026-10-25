CREATE DATABASE IF NOT EXISTS library;
USE library;

CREATE TABLE category (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);
 
CREATE TABLE publisher (
    pub_id INT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    address VARCHAR(255)
);
 
CREATE TABLE member (
    member_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address VARCHAR(255),
    join_date DATETIME
);
 
CREATE TABLE book (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    price DECIMAL(8,2),
    pub_id INT,
    category_id INT,
    CONSTRAINT FOREIGN KEY (pub_id) REFERENCES publisher(pub_id),
    CONSTRAINT FOREIGN KEY (category_id) REFERENCES category(category_id)
);
 
CREATE TABLE borrowing_book (
    member_id INT,
    book_id INT,
    borrow_date DATETIME,
    due_date DATETIME,
    return_date DATETIME,
    PRIMARY KEY (member_id, book_id, borrow_date),
    CONSTRAINT FOREIGN KEY (member_id) REFERENCES member(member_id),
    CONSTRAINT FOREIGN KEY (book_id)   REFERENCES book(book_id)
);

-- ---------------------------------------------------------------------------

SELECT name FROM member WHERE join_date > '2000-09-01';

SELECT name, pub_id FROM publisher;

SELECT * FROM member WHERE join_date >= '1995-10-01' AND join_date <  '2019-10-02';

SELECT * FROM book WHERE pub_id = 2 OR (price >= 15 AND price <= 20);

SELECT * FROM borrowing_book WHERE member_id = 5;
