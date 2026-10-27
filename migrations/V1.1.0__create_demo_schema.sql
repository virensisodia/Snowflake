-- Versioned script: runs exactly once, in version order.
-- Naming: V<version>__<description>.sql  (two underscores)
CREATE SCHEMA IF NOT EXISTS DEMO;

CREATE TABLE IF NOT EXISTS DEMO.CUSTOMER (
    CUSTOMER_ID   NUMBER        NOT NULL,
    CUSTOMER_NAME VARCHAR(200)  NOT NULL,
    CREATED_AT    TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);
