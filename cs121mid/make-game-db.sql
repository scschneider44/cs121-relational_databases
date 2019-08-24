-- [Problem 1]
DROP TABLE IF EXISTS game_score;
DROP TABLE IF EXISTS game;
DROP TABLE IF EXISTS geezer;
DROP TABLE IF EXISTS game_type;

-- [Problem 2]
-- This table contains retiree personal information
CREATE TABLE geezer (
    -- Auto incremented ID, not null because it's primary key
    person_id      INTEGER      AUTO_INCREMENT,
    -- name of retiree
    person_name    VARCHAR(100)  NOT NULL,
    -- retiree gender, must be 'M' or 'F'
    gender         CHAR(1)      NOT NULL,
    -- retiree birthday
    birth_date     DATE         NOT NULL,
    -- prescriptions for retiree, if any
    prescriptions  VARCHAR(1000),
    PRIMARY KEY (person_id),
    CHECK (gender IN ('M', 'F'))
);

-- This table holds information about all the types of games at the home
CREATE TABLE game_type (
    -- primary key, auto incrementing integer
    type_id      INTEGER      AUTO_INCREMENT,
    -- name of game
    type_name    VARCHAR(20)  NOT NULL UNIQUE,
    -- description of game
    game_desc    VARCHAR(1000) NOT NULL,
    -- minimum number of players who can play a certain game, must be
    -- more than 0
    min_players  INTEGER      NOT NULL,
    -- maximum number of players who can play a certain game, cannot
    -- be less than minimum amount of players
    max_players  INTEGER,
    PRIMARY KEY (type_id),
    CHECK (min_players > 0),
    CHECK (max_players >= min_players OR max_players IS NULL)
);


-- Table holding information of each instance of a game being played
-- including the date and type of game.
CREATE TABLE game (
    -- primary key, integer which serves as a unique game id
    game_id   INTEGER   AUTO_INCREMENT,
    -- type of game that was played
    type_id   INTEGER   NOT NULL REFERENCES game_type (type_id),
    -- date of game
    game_date TIMESTAMP DEFAULT NOW() NOT NULL,
    PRIMARY KEY (game_id)
);

-- Table that has the scores of all the games played
CREATE TABLE game_score (
    -- id of game played, from game table
    game_id   INTEGER  REFERENCES game (game_id),
    -- id of person who played game, from geezer
    person_id INTEGER  REFERENCES geezer (person_id),
    -- the score one person got for the game they played
    score     INTEGER NOT NULL,
    PRIMARY KEY (game_id, person_id)
);



