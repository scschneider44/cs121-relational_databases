-- [Problem 5]


-- DROP TABLE commands:
DROP TABLE IF EXISTS ticket;
DROP TABLE IF EXISTS purchase;
DROP TABLE IF EXISTS traveler;
DROP TABLE IF EXISTS purchaser;
DROP TABLE IF EXISTS customer_phones;
DROP TABLE IF EXISTS flight;
DROP TABLE IF EXISTS seat;
DROP TABLE IF EXISTS airplane;
DROP TABLE IF EXISTS plane_customer;


-- CREATE TABLE commands:
-- Table with airplane types
CREATE TABLE airplane (
    -- IATA airplane code
    type_code   CHAR(3)      NOT NULL,
    -- company of the plane
    company     VARCHAR(100) NOT NULL,
    -- model of the airplane
    model       VARCHAR(25)  NOT NULL,
    PRIMARY KEY (type_code)
);

-- Table of flights
CREATE TABLE flight (
    -- flight number of flight i.e. "QF110"
    flight_number  VARCHAR(10) NOT NULL,
    -- Date of flight
    flight_date    DATE        NOT NULL,
    -- time of flight
    flight_time    TIME        NOT NULL,
    -- where the plane is flying from
    source_airport CHAR(3)     NOT NULL,
    -- where the plane is flying to
    destination    CHAR(3)     NOT NULL,
    -- flag if the flight is international
    international  BOOLEAN     NOT NULL,
    -- IATA code from airplane
    -- a flight can't happen on a non existant plane so we cascade
    type_code      CHAR(3)     NOT NULL 
                               REFERENCES airplane (type_code)
                               ON DELETE CASCADE
                               ON UPDATE CASCADE,
    PRIMARY KEY (flight_number, flight_date)
);

-- seats in a plane
CREATE TABLE seat (
    -- IATA code from airplane 
    -- seats can't exist without a plane so we cascade
    type_code   CHAR(3)     NOT NULL
                            REFERENCES airplane(type_code)
                            ON DELETE CASCADE
                            ON UPDATE CASCADE,
    -- number of seat i.e "34B"
    seat_number VARCHAR(5)  NOT NULL,
    -- seat class i.e. business class
    seat_class  VARCHAR(25) NOT NULL,
    -- type of seat i.e. middle or window
    seat_type   VARCHAR(25) NOT NULL,
    -- flag if seat is in the exit row
    exit_row    BOOLEAN     NOT NULL,
    PRIMARY KEY (type_code, seat_number)
);
    
-- customers, either purchasers or travelers
CREATE TABLE plane_customer (
    -- id of customer, auto generated
    customer_id INTEGER     NOT NULL AUTO_INCREMENT,
    -- first name of customer
    first_name  VARCHAR(20) NOT NULL,
    -- last name of customer
    last_name   VARCHAR(20) NOT NULL,
    -- email of customer
    email       VARCHAR(30) NOT NULL,
    PRIMARY KEY (customer_id)
);

-- phone numbers for customers
CREATE TABLE customer_phones (
    -- customer ids from plane_customer
    -- cascades because this is part of customer in the ER relatioship
    customer_id  INTEGER NOT NULL REFERENCES plane_customer (customer_id)
                                  ON DELETE CASCADE
                                  ON UPDATE CASCADE,
    -- phone number for customers, they can have many numbers
    phone_number VARCHAR(15) NOT NULL,
    PRIMARY KEY (customer_id, phone_number)
);

-- table of people who purchase tickets
CREATE TABLE purchaser (
    -- customer ids from plane_customer
    -- cascades because this is part of a hierachical relationship
    customer_id INTEGER     NOT NULL
                            REFERENCES plane_customer (customer_id)
                            ON DELETE CASCADE
                            ON UPDATE CASCADE,
    -- credit card number
    cc_number         INTEGER,
    -- expiration date of credit card
    exp_date          CHAR(5),
    -- verification code of credit card
    verification_code INTEGER,
    PRIMARY KEY (customer_id)
);

-- table of people who travel 
CREATE TABLE traveler (
    -- customer ids from plane_customer 
    -- cascades because this is part of a hierachical relationship
    customer_id INTEGER     NOT NULL
                            REFERENCES plane_customer (customer_id)
                            ON DELETE CASCADE
                            ON UPDATE CASCADE,
    -- passport number
    passport_number    VARCHAR(40),
    -- country where the person is from
    country            VARCHAR(30),
    -- name of a emergency contact
    emergency_contact  VARCHAR(50),
    -- phone number of the emergency contact
    ec_phone_number       VARCHAR(15),
    -- frequent flyer number
    ff_number          CHAR(7) UNIQUE,
    PRIMARY KEY (customer_id),
    -- these are clearly unique
    UNIQUE KEY (passport_number, country)
    
);

-- table of ticket purchases
CREATE TABLE purchase (
    -- auto generated purchase ids
    purchase_id         INTEGER   NOT NULL AUTO_INCREMENT,
    -- time of purchase
    purchase_time       TIMESTAMP NOT NULL,
    -- confirnmation number of purchase which is unique
    confirmation_number CHAR(6)   NOT NULL UNIQUE,
    -- customer id from plane_customer since puchase doesn't
    -- make sense without a customer we case the cascade conditions
    customer_id         INTEGER   NOT NULL
                                  REFERENCES plane_customer (customer_id)
                                  ON DELETE CASCADE
                                  ON UPDATE CASCADE,
    PRIMARY KEY (purchase_id)
);

-- table of tickets
CREATE TABLE ticket (
    -- auto generated ticket id
    ticket_id     INTEGER       NOT NULL AUTO_INCREMENT,
    -- price ticket sells at
    sale_price    NUMERIC(6, 2) NOT NULL,
    -- flight number from flight
    flight_number VARCHAR(10)   NOT NULL,
    -- date of flight from flight
    flight_date   DATE          NOT NULL,
    -- type code from seat
    type_code     CHAR(3)       NOT NULL,
    -- seat number from seat
    seat_number   VARCHAR(5)    NOT NULL,
    -- purchase id from purchase
    purchase_id   INTEGER       NOT NULL,
    -- customer id from plane_customer
    customer_id   INTEGER       NOT NULL,
    -- these foreign keys have delete and update cascades because tickets don't
    -- make sense if the purchase, customer, seat, or flight doesn't exist
    FOREIGN KEY (purchase_id) REFERENCES purchase(purchase_id) ON DELETE CASCADE
                                                              ON UPDATE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES traveler(customer_id) ON DELETE CASCADE
                                                              ON UPDATE CASCADE,
    FOREIGN KEY (type_code, seat_number) 
                REFERENCES seat(type_code, seat_number)     ON DELETE CASCADE
                                                            ON UPDATE CASCADE,
    FOREIGN KEY (flight_number, flight_date) 
                REFERENCES flight(flight_number, flight_date) ON DELETE CASCADE
                                                              ON UPDATE CASCADE,
    PRIMARY KEY (ticket_id),
    -- these keys have to be unique or else you could have 2 
    -- different tickets for
    -- the same seat on the same flight
    UNIQUE KEY (flight_number, flight_date, seat_number),
    -- sale price will never exceed $10000
    CHECK (sale_price < 10000)
);





