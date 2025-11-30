-- 1. Create the Database
CREATE DATABASE IF NOT EXISTS wms_db;
USE wms_db;

-- 2. Users Table (Core for Authentication)
CREATE TABLE Users (
    UserID INT AUTO_INCREMENT PRIMARY KEY,
    Username VARCHAR(50) UNIQUE NOT NULL,
    PasswordHash CHAR(60) NOT NULL, -- Use CHAR(60) for Bcrypt hash
    Email VARCHAR(100) UNIQUE NOT NULL,
    UserType ENUM('Customer', 'Supplier', 'Admin') NOT NULL,
    RegistrationDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Customers Table
CREATE TABLE Customers (
    CustomerID INT AUTO_INCREMENT PRIMARY KEY,
    UserID INT UNIQUE NOT NULL,
    Name VARCHAR(100) NOT NULL,
    ShippingAddress TEXT,
    BillingAddress TEXT,
    Phone VARCHAR(20),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

-- 4. Suppliers Table
CREATE TABLE Suppliers (
    SupplierID INT AUTO_INCREMENT PRIMARY KEY,
    UserID INT UNIQUE NOT NULL,
    Name VARCHAR(100) NOT NULL,
    ContactPerson VARCHAR(100),
    Phone VARCHAR(20),
    Email VARCHAR(100),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

-- 5. Categories Table
CREATE TABLE Categories (
    CategoryID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(50) UNIQUE NOT NULL,
    Description TEXT
);

-- 6. Products Table
CREATE TABLE Products (
    ProductID INT AUTO_INCREMENT PRIMARY KEY,
    CategoryID INT NOT NULL,
    SupplierID INT NOT NULL,
    Name VARCHAR(255) NOT NULL,
    SKU VARCHAR(50) UNIQUE NOT NULL, -- Stock Keeping Unit
    Description TEXT,
    UnitPrice DECIMAL(10, 2) NOT NULL CHECK (UnitPrice >= 0),
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID),
    FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID)
);

-- 7. Location Table (Warehouse Bins/Shelves)
CREATE TABLE Location (
    LocationID INT AUTO_INCREMENT PRIMARY KEY,
    WarehouseZone CHAR(1) NOT NULL, -- E.g., 'A', 'B', 'C'
    AisleNumber INT NOT NULL,
    ShelfNumber INT NOT NULL,
    BinNumber VARCHAR(10) NOT NULL,
    UNIQUE KEY (WarehouseZone, AisleNumber, ShelfNumber, BinNumber)
);

-- 8. Inventory Table (Current Stock Levels)
CREATE TABLE Inventory (
    InventoryID INT AUTO_INCREMENT PRIMARY KEY,
    ProductID INT UNIQUE NOT NULL, -- 1:1 relationship with Product for simplicity
    LocationID INT NOT NULL,
    StockQuantity INT NOT NULL CHECK (StockQuantity >= 0),
    LastUpdateDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
    FOREIGN KEY (LocationID) REFERENCES Location(LocationID)
);

-- 9. Orders Table (Customer Purchase)
CREATE TABLE Orders (
    OrderID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT NOT NULL,
    OrderDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    RequiredShippingDate DATE,
    ActualShippingDate DATE,
    TotalAmount DECIMAL(10, 2) NOT NULL,
    Status ENUM('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled') NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- 10. OrderItems Table (Details of what was ordered)
CREATE TABLE OrderItems (
    OrderItemID INT AUTO_INCREMENT PRIMARY KEY,
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    UnitPriceAtOrder DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
    UNIQUE KEY (OrderID, ProductID)
);

-- 11. GoodsReceipts Table (Inbound from Supplier)
CREATE TABLE GoodsReceipts (
    ReceiptID INT AUTO_INCREMENT PRIMARY KEY,
    SupplierID INT NOT NULL,
    ReceiptDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Status ENUM('Pending', 'Received', 'Cancelled') NOT NULL,
    FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID)
);

-- 12. ReceiptItems Table (Details of what was received)
CREATE TABLE ReceiptItems (
    ReceiptItemID INT AUTO_INCREMENT PRIMARY KEY,
    ReceiptID INT NOT NULL,
    ProductID INT NOT NULL,
    QuantityReceived INT NOT NULL CHECK (QuantityReceived > 0),
    UnitCost DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (ReceiptID) REFERENCES GoodsReceipts(ReceiptID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- 13. Shipments Table (Outbound Logistics)
CREATE TABLE Shipments (
    ShipmentID INT AUTO_INCREMENT PRIMARY KEY,
    OrderID INT UNIQUE NOT NULL,
    TrackingNumber VARCHAR(100) UNIQUE,
    Carrier VARCHAR(50),
    ShipmentDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    DeliveryDate DATE,
    Status ENUM('In Transit', 'Out for Delivery', 'Delivered', 'Failed') NOT NULL,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

