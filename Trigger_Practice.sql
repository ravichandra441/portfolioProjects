select * from sys.databases

USE SqlPractice

SELECT * FROM SYS.tables

CREATE TABLE Stock(ItemNo VARCHAR(Max) , ItemDescription VARCHAR(MAX) , Quantity INT)

INSERT INTO Stock
SELECT '103','Computers',200 UNION ALL
SELECT '104','Books',250

SELECT * INTO Dup_Stock FROM Stock

CREATE TABLE Orders(OrderNo VARCHAR(Max) 
            ,OrderDate DATE DEFAULT(GETDATE())
			, ItemNo VARCHAR(MAX) 
			, OrderQuantity INT)


SELECT * FROM Orders

--Write a program to update the stock level whenever order is issued

CREATE PROC usp_Update_Stock_Level
(
  @OrderNum VARCHAR(MAX)
 ,@ItemNum VARCHAR(MAX)
 ,@OrderQty INT
 )
 AS
 BEGIN
      DECLARE @Check_Qty INT
	  SELECT @Check_Qty = Quantity FROM Stock WHERE ItemNo = @ItemNum
	  IF(@Check_Qty>@OrderQty)
	  BEGIN
	       INSERT INTO Orders(OrderNo,ItemNo,OrderQuantity) VALUES(@OrderNum,@ItemNum,@OrderQty)
		   PRINT 'Order is received'
		   UPDATE Stock SET Quantity = (SELECT Quantity FROM Stock WHERE ItemNo = @ItemNum)-@OrderQty WHERE ItemNo=@ItemNum
		   PRINT 'Updated stock level'
	  END
	  ELSE
	  BEGIN
	       PRINT 'Ordered quantity is not available'
	  END
 END

 EXEC usp_Update_Stock_Level 1,104,5

 SELECT * FROM Stock
 SELECT * FROM Dup_Stock
 SELECT * FROM Orders

--Write a program to update the stock level whenever order is issued USING TRIGGER

ALTER TRIGGER trg_Update_Stock
ON Orders
FOR INSERT
AS 
  BEGIN
       DECLARE @PId VARCHAR(MAX),@QtyStock VARCHAR(MAX),@QtyOrder INT
	   SELECT @PId = ItemNo FROM inserted
	   SELECT @QtyStock = Quantity FROM Stock WHERE ItemNo = @PId
	   SELECT @QtyOrder = OrderQuantity FROM inserted
	BEGIN TRAN
	        IF(@QtyOrder>@QtyStock)
			BEGIN
			    PRINT 'Quatity should not exceed stock limit'
				ROLLBACK TRAN
			END
			ELSE
			  BEGIN
			       UPDATE Stock SET Quantity = Quantity - @QtyOrder WHERE ItemNo = @PId
				   PRINT 'STOCK QUANTITY UPDATED'
				   COMMIT TRAN
			  END
  END
			   


INSERT INTO Orders(OrderNo,ItemNo,OrderQuantity) VALUES(3,103,10)















 



















