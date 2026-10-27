-- Repeatable script: re-runs whenever its contents change. Good for views/procedures.
-- {{ env }} comes from --vars in the workflow (Jinja templating).
CREATE OR REPLACE VIEW DEMO.V_CUSTOMER
    COMMENT = 'Deployed by schemachange ({{ env }})'
AS
SELECT CUSTOMER_ID, CUSTOMER_NAME, EMAIL, CREATED_AT
FROM DEMO.CUSTOMER;
