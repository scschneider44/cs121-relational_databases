-- [Problem 1]
-- Clean up tables if they already exist.
DROP TABLE IF EXISTS owns;
DROP TABLE IF EXISTS participated;
DROP TABLE IF EXISTS accident;
DROP TABLE IF EXISTS car;
DROP TABLE IF EXISTS person;

-- Table containing drivers 
CREATE TABLE person (
    driver_id    CHAR(10)    NOT NULL,
    name         VARCHAR(30) NOT NULL,
    address      VARCHAR(75) NOT NULL,
    PRIMARY KEY (driver_id)
);

-- Table containing cars
CREATE TABLE car (
    license     CHAR(7)    NOT NULL,
    model       VARCHAR(30),
    year        YEAR,
    PRIMARY KEY (license)
);

-- Table that shows who owns what car
CREATE TABLE owns (
    driver_id    CHAR(10)    NOT NULL,
    license      CHAR(7)     NOT NULL,
    PRIMARY KEY (driver_id, license),
    FOREIGN KEY (driver_id) REFERENCES person(driver_id)
                            ON DELETE CASCADE
                            ON UPDATE CASCADE,
    FOREIGN KEY (license)   REFERENCES car(license)
                            ON DELETE CASCADE
                            ON UPDATE CASCADE
);

-- Table that has date, time, and physical location of
-- accidents which includes a report number
CREATE TABLE accident (
    report_number INTEGER      NOT NULL AUTO_INCREMENT,
    date_occured  TIMESTAMP    NOT NULL,
    location      VARCHAR(400) NOT NULL,
    description   TEXT,
    PRIMARY KEY (report_number)
);

-- Table has people who participated in specific accidents
CREATE TABLE participated (
    driver_id     CHAR(10)    NOT NULL,
    license       CHAR(7)     NOT NULL,
    report_number INTEGER     NOT NULL,
    damage_amount NUMERIC(12, 2),
    PRIMARY KEY (driver_id, license, report_number), 
    FOREIGN KEY (driver_id) REFERENCES person(driver_id)
                            ON UPDATE CASCADE,
    FOREIGN KEY (license) REFERENCES car(license)
                          ON UPDATE CASCADE,
    FOREIGN KEY (report_number) REFERENCES accident(report_number)
                                ON UPDATE CASCADE
);



