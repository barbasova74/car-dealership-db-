
BEGIN;

CREATE TABLE cars (
    car_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    vin VARCHAR(17) NOT NULL UNIQUE,
    model_name VARCHAR(100) NOT NULL,
    price NUMERIC(12, 2) NOT NULL CHECK (price > 0),
    CONSTRAINT chk_car_vin_length CHECK (CHAR_LENGTH(vin) = 17)
);

CREATE TABLE customers (
    customer_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    phone VARCHAR(20) NOT NULL
);

CREATE TABLE employees (
    employee_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL
);


CREATE TABLE sales (
    sale_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    car_id INTEGER NOT NULL UNIQUE REFERENCES cars(car_id),
    customer_id INTEGER NOT NULL REFERENCES customers(customer_id),
    employee_id INTEGER NOT NULL REFERENCES employees(employee_id),
    sale_date DATE NOT NULL,
    sale_price NUMERIC(12, 2) NOT NULL CHECK (sale_price > 0)
);


INSERT INTO cars (vin, model_name, price) VALUES
    ('JTDBR32E720012345', 'Toyota Corolla', 2100000.00),
    ('KMHDU41D77U123456', 'Hyundai Elantra', 2450000.00),
    ('WVWZZZ1JZXW000001', 'Volkswagen Golf', 2600000.00);

INSERT INTO customers (full_name, phone) VALUES
    ('Иванов Иван Иванович', '+79991111111'),
    ('Петрова Анна Сергеевна', '+79992222222');

INSERT INTO employees (full_name) VALUES
    ('Смирнов Алексей Олегович'),
    ('Кузнецова Мария Игоревна');


INSERT INTO sales (car_id, customer_id, employee_id, sale_date, sale_price) VALUES
    (1, 1, 1, DATE '2026-10-10', 2050000.00),
    (2, 2, 2, DATE '2026-10-20', 2390000.00);

COMMIT;
