# realestate-infrastructure

Terraform for the realestate system: everything it runs on in GCP.

## What it creates (per environment)

| Resource | Notes |
|---|---|
| Project `realestate-<env>-NNNNNN` | Inside the `realestate` folder owned by root-infrastructure, linked to billing, no default network. |
| Project APIs | artifactregistry, compute, iam, iamcredentials, run, secretmanager, servicenetworking, sqladmin (enabled up front for the resources that come later). |
| Artifact Registry `containers` | Images for all realestate apps. Keeps the 10 newest, deletes others after 30 days. |
| Cloud Run `realestate-api` | Public, 1 vCPU / 512Mi, scales 0–2, billed per request. Runs as its own SA `realestate-api` (no roles yet). |
| SA `deploy-realestate-api` | `sysdev-se/realestate-api` impersonates it via WIF to push images and deploy `realestate-api`. Nothing else. |

The database and the network come in later changes.

## Deploying an app

Terraform creates each Cloud Run service with Google's placeholder image and then
ignores the image: **app repos own the image, this repo owns everything else**
(env vars, scaling, IAM).

The app repo needs these secrets:

| Secret | Value |
|---|---|
| `GCP_WIF_PROVIDER` | same as in this repo |
| `GCP_SERVICE_ACCOUNT` | output `api_deployer_service_account` |

Its workflow then pushes to `<output artifact_registry>/realestate-api:<sha>` and runs
`gcloud run deploy realestate-api --image <image> --region asia-southeast1 --project realestate-prod-000001`.
Pass only `--image`: any other setting (env vars, memory, labels, ...) would be
reverted by the next `terraform apply`. For the same reason, don't use the
`google-github-actions/deploy-cloudrun` action without `skip_default_labels: true`.

## Layout

```
environments/<env>/   one Terraform root (own project, own state prefix) per environment
modules/              building blocks shared by the environments
```

Only `prod` exists today. To add an environment:

1. `cp -r environments/prod environments/<env>`
2. `environments/<env>/backend.tf`: `prefix = "<env>"`
3. `environments/<env>/terraform.tfvars`: `environment = "<env>"` and a new `project_id`
4. `.github/workflows/terraform.yml`: add `<env>` to `matrix.environment`

## How changes are applied

`.github/workflows/terraform.yml` runs when `environments/**`, `modules/**` or the
workflow itself changes:

- PR to `main`: `fmt -check`, `init`, `validate`, `plan` for every environment.
- Push (merge) to `main`: `terraform apply -auto-approve`.

CI authenticates via WIF as `tf-realestate`, which only has access to the
`realestate` folder and the `sysdev-tfstate-realestate` bucket. Both are created by
root-infrastructure (`bootstrap/systems.tf`).

Repo secrets:

| Secret | Value |
|---|---|
| `GCP_WIF_PROVIDER` | root-infrastructure output `wif_provider_name` |
| `GCP_TF_SERVICE_ACCOUNT` | root-infrastructure output `systems.realestate.terraform_service_account` |

## Running locally

```sh
gcloud auth application-default login \
  --impersonate-service-account=tf-realestate@root-infrastructure-485309.iam.gserviceaccount.com
cd environments/prod && terraform init && terraform plan
```

Impersonating requires `roles/iam.serviceAccountTokenCreator` on `tf-realestate`.
