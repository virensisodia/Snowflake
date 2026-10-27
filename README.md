# Snowflake CI/CD with schemachange + GitHub Actions

```
.github/workflows/snowflake-schemachange.yml   <- the pipeline
migrations/
  V1.1.0__create_demo_schema.sql               <- versioned: runs once
  V1.1.1__add_customer_email.sql
  R__customer_view.sql                         <- repeatable: re-runs when changed
```

| Event                     | What happens                          |
|---------------------------|---------------------------------------|
| Pull request into `main`  | `schemachange deploy --dry-run`       |
| Push / merge to `main`    | Real deploy to Snowflake              |
| Manual (Actions tab)      | Dry run or deploy, your choice        |

---

## 1. Create a key pair (on your machine)

Snowflake is phasing out password-only logins, so the pipeline uses key-pair auth.

```bash
openssl genrsa 2048 | openssl pkcs8 -topk8 -inform PEM -out rsa_key.p8 -nocrypt
openssl rsa -in rsa_key.p8 -pubout -out rsa_key.pub
```

Keep `rsa_key.p8` private. Never commit it.

## 2. Snowflake setup (run once as ACCOUNTADMIN)

Run [setup/snowflake_setup.sql](setup/snowflake_setup.sql) in a Snowsight worksheet.
It creates warehouse `CICD_WH`, database `CICD_DEMO_DB`, role `CICD_DEPLOY_ROLE`
and service user `CICD_SVC_USER` (key-pair auth).

## 3. GitHub secrets

Repo → **Settings → Secrets and variables → Actions → New repository secret**:

| Secret                  | Example                                       |
|-------------------------|-----------------------------------------------|
| `SNOWFLAKE_ACCOUNT`     | `SCPCJGH-PMB02268` (account identifier, no `.snowflakecomputing.com`) |
| `SNOWFLAKE_USER`        | `CICD_SVC_USER`                               |
| `SNOWFLAKE_ROLE`        | `CICD_DEPLOY_ROLE`                            |
| `SNOWFLAKE_WAREHOUSE`   | `CICD_WH`                                  |
| `SNOWFLAKE_DATABASE`    | `CICD_DEMO_DB`                                       |
| `SNOWFLAKE_PRIVATE_KEY` | full contents of `rsa_key.p8`, including BEGIN/END lines |
| `SNOWFLAKE_PRIVATE_KEY_PASSPHRASE` | only if you encrypted the key (optional) |

Optional: **Settings → Environments → `production` → Required reviewers** to make
every deploy wait for an approval.

## 4. Push and test

```bash
git init
git add .
git commit -m "Add schemachange CI/CD"
git branch -M main
git remote add origin https://github.com/virensisodia/Snowflake.git
git push -u origin main
```

Watch the **Actions** tab. After it succeeds, check in Snowflake:

```sql
SELECT * FROM CICD_DEMO_DB.SCHEMACHANGE.CHANGE_HISTORY ORDER BY INSTALLED_ON DESC;
```

## Day-to-day workflow

1. Create a branch, add a new script with a **higher version**, e.g. `V1.1.2__add_orders_table.sql`.
2. Open a PR → the pipeline does a dry run and lists what would deploy.
3. Merge → the pipeline deploys it.

Rules: never edit a versioned (`V`) script after it has run — add a new one instead.
`R__` scripts may be edited freely; they re-run when their content changes.
`A__` scripts (always) run on every deploy.
