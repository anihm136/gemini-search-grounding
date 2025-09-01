#! /usr/bin/env bash

set -euo pipefail

set -a
source "$(dirname "$0")/args.sh"
set +a

log() {
	echo "\n**************** $* ****************\n"
}

log "DELETING API GATEWAY"
gcloud api-gateway gateways delete "${GATEWAY_NAME}" --location="${REGION}" --quiet

gcloud api-gateway api-configs delete v1 --api="${API_NAME}" --quiet

gcloud api-gateway apis delete "${API_NAME}" --quiet

log "DELETING SEARCH FUNCTION"
gcloud functions delete "${FUNCTION_NAME}" --region="${REGION}" --quiet

log "DELETING SERVICE ACCOUNT AND REMOVING PERMISSIONS"
gcloud functions remove-invoker-policy-binding "${FUNCTION_NAME}" --region="${REGION}" --member=serviceAccount:"${SERVICE_ACCOUNT_ID}" --quiet

gcloud projects remove-iam-policy-binding ${GOOGLE_PROJECT_ID} --member=serviceAccount:"${SERVICE_ACCOUNT_ID}" --role=roles/iam.serviceAccountUser --quiet

gcloud iam service-accounts delete "${SERVICE_ACCOUNT_ID}" --quiet

gcloud projects remove-iam-policy-binding ${GOOGLE_PROJECT_ID} \
	--member=serviceAccount:${GOOGLE_PROJECT_NUMBER}-compute@developer.gserviceaccount.com \
	--role=roles/cloudbuild.builds.builder --quiet

echo "Undeployment complete."
