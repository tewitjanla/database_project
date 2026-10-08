USE DormitoryBooking;
GO

-- 1. ดูสถานะห้องพักทั้งหมดในตึก ว่าห้องไหนว่าง ไม่ว่าง หรือซ่อมอยู่ (เรียงตามเบอร์ห้อง)
SELECT 
    r.RoomNumber AS 'หมายเลขห้อง',
    t.TypeName AS 'ประเภทห้อง',
    t.PricePerMonth AS 'ราคา/เดือน',
    r.Status AS 'สถานะปัจจุบัน'
FROM Rooms r
JOIN RoomTypes t ON r.TypeID = t.TypeID
ORDER BY r.RoomNumber;

-- 2. ค้นหารายชื่อนักศึกษาที่ 'จองห้องแล้วแต่ยังไม่ได้จ่ายเงิน' (รอยืนยัน)
SELECT 
    b.BookingID AS 'รหัสการจอง',
    s.StudentID AS 'รหัสนักศึกษา',
    s.FirstName + ' ' + s.LastName AS 'ชื่อ-นามสกุล',
    r.RoomNumber AS 'ห้องที่จอง',
    b.BookingDate AS 'วันที่ทำรายการ'
FROM Bookings b
JOIN Students s ON b.StudentID = s.StudentID
JOIN Rooms r ON b.RoomID = r.RoomID
WHERE b.BookingStatus = N'รอยืนยัน';

-- 3. สรุปรายได้รวมของหอพัก แยกตาม 'ช่องทางการชำระเงิน'
SELECT 
    PaymentMethod AS 'ช่องทางการชำระเงิน',
    COUNT(PaymentID) AS 'จำนวนรายการ (ครั้ง)',
    SUM(Amount) AS 'รายได้รวม (บาท)'
FROM Payments
GROUP BY PaymentMethod
ORDER BY SUM(Amount) DESC;

-- 4. สรุปความนิยม: แต่ละ 'ประเภทห้อง' มีคนจองสำเร็จไปแล้วกี่ห้อง
SELECT 
    t.TypeName AS 'ประเภทห้อง',
    COUNT(b.BookingID) AS 'จำนวนห้องที่ถูกจอง (ห้อง)'
FROM Bookings b
JOIN Rooms r ON b.RoomID = r.RoomID
JOIN RoomTypes t ON r.TypeID = t.TypeID
WHERE b.BookingStatus = N'ยืนยันแล้ว'
GROUP BY t.TypeName
ORDER BY COUNT(b.BookingID) DESC;

-- 5. ตรวจสอบว่า 'นักศึกษาคนไหนเคยยกเลิกการจองบ้าง' พร้อมเหตุผล(ถ้าระบุ)
SELECT 
    s.StudentID AS 'รหัสนักศึกษา',
    s.FirstName + ' ' + s.LastName AS 'ชื่อ-นามสกุล',
    r.RoomNumber AS 'ห้องที่เคยจอง',
    b.BookingDate AS 'วันที่เคยจอง',
    b.BookingStatus AS 'สถานะ'
FROM Bookings b
JOIN Students s ON b.StudentID = s.StudentID
JOIN Rooms r ON b.RoomID = r.RoomID
WHERE b.BookingStatus = N'ยกเลิก';

-- 6. ดูรายชื่อนักศึกษาและห้องที่เข้าพัก แยกตาม 'ชั้น' (เรียงลำดับชั้นและเบอร์ห้อง)
SELECT 
    r.FloorNumber AS 'ชั้น',
    r.RoomNumber AS 'หมายเลขห้อง',
    t.TypeName AS 'ประเภทห้อง',
    s.FirstName + ' ' + s.LastName AS 'ผู้เข้าพัก'
FROM Rooms r
JOIN RoomTypes t ON r.TypeID = t.TypeID
-- ใช้ LEFT JOIN เผื่อห้องไหนว่างจะแสดงเป็น NULL แทนที่จะหายไปเลย
LEFT JOIN Bookings b ON r.RoomID = b.RoomID AND b.BookingStatus = N'ยืนยันแล้ว'
LEFT JOIN Students s ON b.StudentID = s.StudentID
ORDER BY r.FloorNumber, r.RoomNumber;

-- 7. ดูข้อมูลการจองห้องพักทั้งหมดของนักศึกษา (เช็กประวัติทั้งหมด)
SELECT 
    s.StudentID AS 'รหัสนักศึกษา',
    s.FirstName + ' ' + s.LastName AS 'ชื่อ-นามสกุล',
    COUNT(b.BookingID) AS 'จำนวนครั้งที่จอง',
    -- ใช้ฟังก์ชัน STRING_AGG เพื่อรวมรหัสห้องที่จองมาแสดงในช่องเดียว (เฉพาะ SQL Server 2017+)
    STRING_AGG(r.RoomNumber, ', ') AS 'ห้องที่เกี่ยวข้อง'
FROM Students s
LEFT JOIN Bookings b ON s.StudentID = b.StudentID
LEFT JOIN Rooms r ON b.RoomID = r.RoomID
GROUP BY s.StudentID, s.FirstName, s.LastName
ORDER BY s.StudentID;