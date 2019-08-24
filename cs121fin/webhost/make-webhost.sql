-- [Problem 1.3]
-- DROP TABLE statements
DROP TABLE IF EXISTS server_software;
DROP TABLE IF EXISTS customer_software;
DROP TABLE IF EXISTS software;
DROP TABLE IF EXISTS basic_customer;
DROP TABLE IF EXISTS preferred_customer;
DROP TABLE IF EXISTS dedicated_server;
DROP TABLE IF EXISTS shared_server;
DROP TABLE IF EXISTS customer_acct;
DROP TABLE IF EXISTS servers;

-- Table holding customer information
CREATE TABLE customer_acct (
    username     VARCHAR(20)    NOT NULL,
    email        VARCHAR(50)    NOT NULL,
    url          VARCHAR(200)   NOT NULL,
    -- the time the customer opened the account
    account_open TIMESTAMP      NOT NULL,
    -- the price the customer pays for a subscription
    sub_price    NUMERIC(12, 2) NOT NULL,
    -- basic or preferred account
    account_type CHAR(1)        NOT NULL,
    PRIMARY KEY (username),
    -- This has to be a unique key so account_type can
    -- be a foreign key
    UNIQUE KEY (username, account_type),
    UNIQUE KEY (url),
    -- make sure the account is either basic or preferred
    -- and not both
    CHECK (account_type IN ('B', 'P'))
);

-- Table holding server information
CREATE TABLE servers (
    -- hostname of the server
    hostname   VARCHAR(40)   NOT NULL,
    -- i.e. linux, windows, etc.
    os_type    VARCHAR(20)   NOT NULL,
    -- number of sites a server can hold
    max_sites  INTEGER       NOT NULL,
    PRIMARY KEY (hostname),
    -- this has to be unique so max_sites can be
    -- foreign key
    UNIQUE KEY(hostname, max_sites)
);

-- Table containing just shared servers
CREATE TABLE shared_server (
    hostname   VARCHAR(40)   NOT NULL,
    max_sites  INTEGER       NOT NULL,
    FOREIGN KEY (hostname, max_sites) REFERENCES servers(hostname, max_sites)
                                      ON DELETE CASCADE
                                      ON UPDATE CASCADE,
    PRIMARY KEY (hostname),
    -- shared servers are by definition shared so the max is 
    -- more than one
    CHECK (max_sites > 1)
);

-- Table containing just dedicated servers
CREATE TABLE dedicated_server (
    hostname   VARCHAR(40)   NOT NULL,
    max_sites  INTEGER       NOT NULL,
    FOREIGN KEY (hostname, max_sites) REFERENCES servers(hostname, max_sites)
                                      ON DELETE CASCADE
                                      ON UPDATE CASCADE,
    PRIMARY KEY (hostname),
    -- it is dedicated because the max sites is 1 so were checking that
    CHECK (max_sites = 1)
);

-- Table containing just basic customers
CREATE TABLE basic_customer (
    username    VARCHAR(20)    NOT NULL,
    account_type CHAR(1)       NOT NULL,
    hostname    VARCHAR(40)    NOT NULL,
    PRIMARY KEY (username),
    FOREIGN KEY (username, account_type) REFERENCES 
                                         customer_acct(username, account_type)
                                         ON DELETE CASCADE
                                         ON UPDATE CASCADE,
    FOREIGN KEY (hostname) REFERENCES shared_server(hostname)
                           ON DELETE CASCADE
                           ON UPDATE CASCADE,
    -- must be basic customers
    CHECK (account_type = 'B')
);

-- Table containing just preferred customers 
CREATE TABLE preferred_customer (
    username    VARCHAR(20)    NOT NULL,
    account_type CHAR(1)       NOT NULL,
    hostname    VARCHAR(40)    NOT NULL,
    PRIMARY KEY (username),
    -- preferred customers is one to one with dedicated servers
    -- so this is a unique key
    UNIQUE KEY (hostname),
    FOREIGN KEY (username, account_type) REFERENCES 
                                         customer_acct(username, account_type)
                                         ON DELETE CASCADE
                                         ON UPDATE CASCADE,
    FOREIGN KEY (hostname) REFERENCES dedicated_server(hostname)
                           ON DELETE CASCADE
                           ON UPDATE CASCADE,
    -- must be preferred customers
    CHECK (account_type = 'P')
);
    
-- Table containing software
CREATE TABLE software (
    package_name    VARCHAR(40)    NOT NULL,
    package_version VARCHAR(20)    NOT NULL,
    -- description of package 
    package_desc    VARCHAR(1000)  NOT NULL,
    package_price   NUMERIC(12, 2) NOT NULL,
    -- can have multiple packages of the same name 
    -- but a different version
    PRIMARY KEY (package_name, package_version)
);

-- Table showing which customers have which software
CREATE TABLE customer_software (
    username    VARCHAR(20)        NOT NULL,
    package_name    VARCHAR(40)    NOT NULL,
    package_version VARCHAR(20)    NOT NULL,
    PRIMARY KEY (username, package_name, package_version),
    FOREIGN KEY (username) REFERENCES customer_acct(username)
                           ON DELETE CASCADE
                           ON UPDATE CASCADE,
    FOREIGN KEY (package_name, package_version) 
                REFERENCES software(package_name, package_version)
                ON DELETE CASCADE
                ON UPDATE CASCADE
);

-- Table showing which servers have what software
CREATE TABLE server_software (
    hostname    VARCHAR(40)    NOT NULL,
    package_name    VARCHAR(40)    NOT NULL,
    package_version VARCHAR(20)    NOT NULL,
    PRIMARY KEY (hostname, package_name, package_version),
    FOREIGN KEY (hostname) REFERENCES servers(hostname)
                           ON DELETE CASCADE
                           ON UPDATE CASCADE,
    FOREIGN KEY (package_name, package_version) 
                REFERENCES software(package_name, package_version)
                ON DELETE CASCADE
                ON UPDATE CASCADE 
);
