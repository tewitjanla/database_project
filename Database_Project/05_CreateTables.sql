USE master;
GO

-- 1. รีเซ็ตฐานข้อมูล (ถ้ามีอยู่แล้วให้ลบทิ้งสร้างใหม่)
IF DB_ID('DormitoryBooking') IS NOT NULL
BEGIN
    ALTER DATABASE DormitoryBooking SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DormitoryBooking;
END
GO

CREATE DATABASE DormitoryBooking;
GO
USE DormitoryBooking;
GO

-- 2. สร้างตารางประเภทห้องพัก (RoomTypes)
CREATE TABLE RoomTypes (
    TypeID INT PRIMARY KEY IDENTITY(1,1),
    TypeName NVARCHAR(100) NOT NULL,
    PricePerMonth DECIMAL(10, 2) NOT NULL,
    Capacity INT NOT NULL
);

-- 3. สร้างตารางห้องพัก (Rooms)
CREATE TABLE Rooms (
    RoomID INT PRIMARY KEY IDENTITY(1,1),
    RoomNumber VARCHAR(10) NOT NULL UNIQUE,
    TypeID INT NOT NULL,
    FloorNumber INT NOT NULL,
    Status NVARCHAR(20) DEFAULT N'ว่าง', 
    FOREIGN KEY (TypeID) REFERENCES RoomTypes(TypeID)
);

-- 4. สร้างตารางนักศึกษา (Students)
CREATE TABLE Students (
    StudentID VARCHAR(20) PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Phone VARCHAR(15),
    Email VARCHAR(50)
);

-- 5. สร้างตารางการจอง (Bookings)
CREATE TABLE Bookings (
    BookingID INT PRIMARY KEY IDENTITY(1,1),
    StudentID VARCHAR(20) NOT NULL,
    RoomID INT NOT NULL,
    BookingDate DATE NOT NULL,
    CheckInDate DATE NOT NULL,
    BookingStatus NVARCHAR(20) DEFAULT N'รอยืนยัน', 
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
    FOREIGN KEY (RoomID) REFERENCES Rooms(RoomID)
);

-- 6. สร้างตารางการชำระเงิน (Payments)
CREATE TABLE Payments (
    PaymentID INT PRIMARY KEY IDENTITY(1,1),
    BookingID INT NOT NULL,
    PaymentDate DATE NOT NULL,
    Amount DECIMAL(10, 2) NOT NULL,
    PaymentMethod NVARCHAR(50), 
    FOREIGN KEY (BookingID) REFERENCES Bookings(BookingID)
);
GO