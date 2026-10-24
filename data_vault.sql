

BEGIN;

CREATE SCHEMA IF NOT EXISTS data_vault_lab1;


CREATE TABLE IF NOT EXISTS data_vault_lab1.hub_car (
    hub_car_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    vin VARCHAR(50) NOT NULL UNIQUE CHECK (char_length(vin) = 17), -- BK
    load_dts TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(50) NOT NULL DEFAULT 'lab1_3nf'
);


CREATE TABLE IF NOT EXISTS data_vault_lab1.hub_customer (
    hub_customer_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_bk VARCHAR(50) NOT NULL UNIQUE,
    load_dts TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(50) NOT NULL DEFAULT 'lab1_3nf'
);


CREATE TABLE IF NOT EXISTS data_vault_lab1.hub_employee (
    hub_employee_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    employee_bk VARCHAR(50) NOT NULL UNIQUE,
    load_dts TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(50) NOT NULL DEFAULT 'lab1_3nf'
);

CREATE TABLE IF NOT EXISTS data_vault_lab1.link_sale (
    link_sale_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sale_bk VARCHAR(50) NOT NULL UNIQUE,
    hub_car_id INTEGER NOT NULL REFERENCES data_vault_lab1.hub_car(hub_car_id),
    hub_customer_id INTEGER NOT NULL REFERENCES data_vault_lab1.hub_customer(hub_customer_id),
    hub_employee_id INTEGER NOT NULL REFERENCES data_vault_lab1.hub_employee(hub_employee_id),
    load_dts TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(50) NOT NULL DEFAULT 'lab1_3nf'
);


CREATE TABLE IF NOT EXISTS data_vault_lab1.sat_car (
    hub_car_id INTEGER NOT NULL REFERENCES data_vault_lab1.hub_car(hub_car_id),
    load_dts TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    model_name VARCHAR(100) NOT NULL,
    price NUMERIC(15, 2) NOT NULL CHECK (price > 0),
    record_source VARCHAR(50) NOT NULL DEFAULT 'lab1_3nf',
    PRIMARY KEY (hub_car_id, load_dts)
);


CREATE TABLE IF NOT EXISTS data_vault_lab1.sat_customer (
    hub_customer_id INTEGER NOT NULL REFERENCES data_vault_lab1.hub_customer(hub_customer_id),
    load_dts TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    record_source VARCHAR(50) NOT NULL DEFAULT 'lab1_3nf',
    PRIMARY KEY (hub_customer_id, load_dts)
);


CREATE TABLE IF NOT EXISTS data_vault_lab1.sat_employee (
    hub_employee_id INTEGER NOT NULL REFERENCES data_vault_lab1.hub_employee(hub_employee_id),
    load_dts TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    full_name VARCHAR(100) NOT NULL,
    position VARCHAR(50) NOT NULL,
    record_source VARCHAR(50) NOT NULL DEFAULT 'lab1_3nf',
    PRIMARY KEY (hub_employee_id, load_dts)
);


CREATE TABLE IF NOT EXISTS data_vault_lab1.sat_sale (
    link_sale_id INTEGER NOT NULL REFERENCES data_vault_lab1.link_sale(link_sale_id),
    load_dts TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    sale_date DATE NOT NULL,
    sale_price NUMERIC(15, 2) NOT NULL CHECK (sale_price > 0),
    record_source VARCHAR(50) NOT NULL DEFAULT 'lab1_3nf',
    PRIMARY KEY (link_sale_id, load_dts)
);


INSERT INTO data_vault_lab1.hub_car (vin) VALUES
    ('JTDBR32E720012345'),
    ('KMHDU41D77U123456'),
    ('WVWZZZ1JZXW000001')
ON CONFLICT (vin) DO NOTHING;

INSERT INTO data_vault_lab1.hub_customer (customer_bk) VALUES
    ('C001'), ('C002')
ON CONFLICT (customer_bk) DO NOTHING;

INSERT INTO data_vault_lab1.hub_employee (employee_bk) VALUES
    ('E001'), ('E002')
ON CONFLICT (employee_bk) DO NOTHING;

INSERT INTO data_vault_lab1.sat_car (hub_car_id, model_name, price)
SELECT h.hub_car_id, v.model_name, v.price
FROM (VALUES
    ('JTDBR32E720012345', 'Toyota Corolla', 2100000.00::NUMERIC),
    ('KMHDU41D77U123456', 'Hyundai Elantra', 2450000.00::NUMERIC),
    ('WVWZZZ1JZXW000001', 'Volkswagen Golf', 2600000.00::NUMERIC)
) AS v(vin, model_name, price)
JOIN data_vault_lab1.hub_car h ON h.vin = v.vin
WHERE NOT EXISTS (
    SELECT 1 FROM data_vault_lab1.sat_car s WHERE s.hub_car_id = h.hub_car_id
);

INSERT INTO data_vault_lab1.sat_customer (hub_customer_id, full_name, phone)
SELECT h.hub_customer_id, v.full_name, v.phone
FROM (VALUES
    ('C001', 'Иванов Иван Иванович', '+79991111111'),
    ('C002', 'Петрова Анна Сергеевна', '+79992222222')
) AS v(customer_bk, full_name, phone)
JOIN data_vault_lab1.hub_customer h ON h.customer_bk = v.customer_bk
WHERE NOT EXISTS (
    SELECT 1 FROM data_vault_lab1.sat_customer s
    WHERE s.hub_customer_id = h.hub_customer_id
);

INSERT INTO data_vault_lab1.sat_employee (hub_employee_id, full_name, position)
SELECT h.hub_employee_id, v.full_name, v.position
FROM (VALUES
    ('E001', 'Смирнов Алексей Олегович', 'Менеджер по продажам'),
    ('E002', 'Кузнецова Мария Игоревна', 'Менеджер по продажам')
) AS v(employee_bk, full_name, position)
JOIN data_vault_lab1.hub_employee h ON h.employee_bk = v.employee_bk
WHERE NOT EXISTS (
    SELECT 1 FROM data_vault_lab1.sat_employee s
    WHERE s.hub_employee_id = h.hub_employee_id
);

INSERT INTO data_vault_lab1.link_sale
    (sale_bk, hub_car_id, hub_customer_id, hub_employee_id)
SELECT v.sale_bk, c.hub_car_id, cu.hub_customer_id, e.hub_employee_id
FROM (VALUES
    ('S001', 'JTDBR32E720012345', 'C001', 'E001'),
    ('S002', 'KMHDU41D77U123456', 'C002', 'E002')
) AS v(sale_bk, vin, customer_bk, employee_bk)
JOIN data_vault_lab1.hub_car c ON c.vin = v.vin
JOIN data_vault_lab1.hub_customer cu ON cu.customer_bk = v.customer_bk
JOIN data_vault_lab1.hub_employee e ON e.employee_bk = v.employee_bk
WHERE NOT EXISTS (
    SELECT 1 FROM data_vault_lab1.link_sale l WHERE l.sale_bk = v.sale_bk
);

INSERT INTO data_vault_lab1.sat_sale (link_sale_id, sale_date, sale_price)
SELECT l.link_sale_id, v.sale_date, v.sale_price
FROM (VALUES
    ('S001', DATE '2026-10-10', 2050000.00::NUMERIC),
    ('S002', DATE '2026-10-20', 2390000.00::NUMERIC)
) AS v(sale_bk, sale_date, sale_price)
JOIN data_vault_lab1.link_sale l ON l.sale_bk = v.sale_bk
WHERE NOT EXISTS (
    SELECT 1 FROM data_vault_lab1.sat_sale s WHERE s.link_sale_id = l.link_sale_id
);

COMMIT;


SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'data_vault_lab1' AND table_type = 'BASE TABLE'
ORDER BY table_name;


SELECT
    l.sale_bk,
    car.vin,
    sc.model_name,
    customer.full_name AS customer,
    employee.full_name AS employee,
    employee.position,
    ss.sale_date,
    ss.sale_price
FROM data_vault_lab1.link_sale l
JOIN data_vault_lab1.hub_car car ON car.hub_car_id = l.hub_car_id
JOIN LATERAL (
    SELECT model_name FROM data_vault_lab1.sat_car s
    WHERE s.hub_car_id = l.hub_car_id
    ORDER BY load_dts DESC LIMIT 1
) sc ON TRUE
JOIN LATERAL (
    SELECT full_name FROM data_vault_lab1.sat_customer s
    WHERE s.hub_customer_id = l.hub_customer_id
    ORDER BY load_dts DESC LIMIT 1
) customer ON TRUE
JOIN LATERAL (
    SELECT full_name, position FROM data_vault_lab1.sat_employee s
    WHERE s.hub_employee_id = l.hub_employee_id
    ORDER BY load_dts DESC LIMIT 1
) employee ON TRUE
JOIN LATERAL (
    SELECT sale_date, sale_price FROM data_vault_lab1.sat_sale s
    WHERE s.link_sale_id = l.link_sale_id
    ORDER BY load_dts DESC LIMIT 1
) ss ON TRUE
ORDER BY l.sale_bk;


