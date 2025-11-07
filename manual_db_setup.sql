-- Kelontong Database Setup Script
-- This script creates the complete database structure for the local grocery store management system
-- Compatible with XAMPP MySQL

-- Create the database
CREATE DATABASE IF NOT EXISTS kelontong_db;
USE kelontong_db;

-- Table: admin
-- Stores administrator login credentials
CREATE TABLE IF NOT EXISTS admin (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) UNIQUE NOT NULL,
  password VARCHAR(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table: kategori
-- Product categories for organizing items
CREATE TABLE IF NOT EXISTS kategori (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nama VARCHAR(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table: barang
-- Product inventory with barcode support
CREATE TABLE IF NOT EXISTS barang (
  id INT AUTO_INCREMENT PRIMARY KEY,
  kode_barcode VARCHAR(50) UNIQUE,
  nama VARCHAR(100) NOT NULL,
  harga DECIMAL(10,2) NOT NULL,
  stok INT NOT NULL DEFAULT 0,
  kategori_id INT,
  is_archived TINYINT(1) DEFAULT 0,
  tanggal_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (kategori_id) REFERENCES kategori(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table: transaksi
-- Transaction header information
CREATE TABLE IF NOT EXISTS transaksi (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tanggal TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  total DECIMAL(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table: detail_transaksi
-- Transaction line items (products sold in each transaction)
CREATE TABLE IF NOT EXISTS detail_transaksi (
  id INT AUTO_INCREMENT PRIMARY KEY,
  transaksi_id INT NOT NULL,
  barang_id INT NOT NULL,
  jumlah INT NOT NULL,
  harga_satuan DECIMAL(10,2) NOT NULL,
  subtotal DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (transaksi_id) REFERENCES transaksi(id) ON DELETE CASCADE,
  FOREIGN KEY (barang_id) REFERENCES barang(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert default admin user
-- Username: admin
-- Password: admin123
INSERT INTO admin (username, password) VALUES ('admin', 'admin123');

-- Insert default product categories
INSERT INTO kategori (nama) VALUES 
  ('Sembako'),
  ('Makanan'),
  ('Minuman'),
  ('Rumah Tangga');

-- Insert sample products (optional - uncomment if you want sample data)
INSERT INTO barang (kode_barcode, nama, harga, stok, kategori_id, is_archived) VALUES
  ('8991234567890', 'Beras Premium 5kg', 75000, 20, 1, 0),
  ('8991234567891', 'Minyak Goreng 1L', 15000, 30, 1, 0),
  ('8991234567892', 'Gula Pasir 1kg', 12000, 25, 1, 0),
  ('8991234567893', 'Mie Instan Ayam', 3500, 100, 2, 0),
  ('8991234567894', 'Susu UHT 1L', 18000, 15, 3, 0),
  ('8991234567895', 'Sabun Mandi', 5000, 40, 4, 0),
  ('8991234567896', 'Kecap Manis 500ml (Archived)', 22000, 0, 1, 1);

-- Create indexes for better performance
CREATE INDEX idx_barang_kategori ON barang(kategori_id);
CREATE INDEX idx_barang_barcode ON barang(kode_barcode);
CREATE INDEX idx_barang_archived ON barang(is_archived);
CREATE INDEX idx_detail_transaksi_transaksi ON detail_transaksi(transaksi_id);
CREATE INDEX idx_detail_transaksi_barang ON detail_transaksi(barang_id);
CREATE INDEX idx_transaksi_tanggal ON transaksi(tanggal);

-- Verify table creation
SHOW TABLES;

-- Display admin user info
SELECT 'Admin user created:' AS info, username, 'Password: admin123' AS note FROM admin WHERE username = 'admin';

-- Display categories
SELECT 'Categories created:' AS info, COUNT(*) AS total FROM kategori;

-- Final success message
SELECT 'Database setup completed successfully!' AS status;

-- Migration: Add payment fields to transaksi
-- Run this if your existing database is missing payment_received / change_amount columns
ALTER TABLE transaksi 
  ADD COLUMN IF NOT EXISTS payment_received DECIMAL(12,2) DEFAULT 0,
  ADD COLUMN IF NOT EXISTS change_amount DECIMAL(12,2) DEFAULT 0;