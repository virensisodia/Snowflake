-- One-time Snowflake setup for the schemachange GitHub Actions pipeline.
-- Run the whole script in a Snowsight worksheet as ACCOUNTADMIN ("Run All").
-- Account: SCPCJGH-PMB02268

USE ROLE ACCOUNTADMIN;

-- 1. Warehouse for the pipeline (XSMALL, suspends after 60s idle)
CREATE WAREHOUSE IF NOT EXISTS CICD_WH
  WAREHOUSE_SIZE = XSMALL
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  INITIALLY_SUSPENDED = TRUE
  COMMENT = 'Used by GitHub Actions schemachange pipeline';

-- 2. Target database (schemachange also keeps its history table here)
CREATE DATABASE IF NOT EXISTS CICD_DEMO_DB
  COMMENT = 'Target database for schemachange CI/CD pipeline';

-- 3. Deploy role
CREATE ROLE IF NOT EXISTS CICD_DEPLOY_ROLE
  COMMENT = 'Role used by GitHub Actions schemachange pipeline';
GRANT ROLE CICD_DEPLOY_ROLE TO ROLE SYSADMIN;

GRANT USAGE, OPERATE ON WAREHOUSE CICD_WH TO ROLE CICD_DEPLOY_ROLE;
GRANT USAGE, CREATE SCHEMA ON DATABASE CICD_DEMO_DB TO ROLE CICD_DEPLOY_ROLE;

-- 4. Service user with key-pair auth (public key only; the private key stays on your PC / in GitHub secrets)
CREATE USER IF NOT EXISTS CICD_SVC_USER
  TYPE = SERVICE
  DEFAULT_ROLE = CICD_DEPLOY_ROLE
  DEFAULT_WAREHOUSE = CICD_WH
  DEFAULT_NAMESPACE = CICD_DEMO_DB
  RSA_PUBLIC_KEY = 'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAzcmHbDNvIIzTpsNvWIBhrrtfmlwlwRnUUIQl34CYjKxvABuG7knxAgypl8xtUfR7fHi3qn+tApww0B4QCw1tDGjH6MVVZlqjLPZ/8kmYkk4IO/oeIKbnKzO2UsF1FyyToxnGM7YSduWb1HEn3s7Cdr0e9oHpDwTRF4wqCmDR5bz3IXjV5i3K4Wg2kE3wDr29FKOfHYil19ovwPjrzeYBxgQOrl5FNN43WirLd/1pH+vZtGi2204BoUYh9kqgBD3PuYTl0JpMEyfoUgo9ZIfM2fIv7APPP4K/tQ1V0ZDNCwjSbDaNH+CId9EzISkTkCC3bn+4oVqPbbCV8gWz2kX6pwIDAQAB'
  COMMENT = 'GitHub Actions schemachange service user';

GRANT ROLE CICD_DEPLOY_ROLE TO USER CICD_SVC_USER;

-- 5. Check
DESC USER CICD_SVC_USER;
