CREATE DATABASE IF NOT EXISTS inventario_db;

USE inventario_db;

CREATE TABLE IF NOT EXISTS productos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    cantidad INT NOT NULL
);

INSERT INTO productos (nombre, cantidad) VALUES
    ('Laptop', 10),
    ('Monitor', 5),
    ('Mouse', 25);
