#! /usr/bin/env bash

set -euo pipefail

set -a
source "$(dirname "$0")/args.sh"
set +a

log() {
	echo "\n**************** $* ****************\n"
}

log "ENABLING GOOGLE CLOUD SERVICES"
gcloud services enable cloudfunctions.googleapis.com run.googleapis.com cloudbuild.googleapis.com apigateway.googleapis.com servicecontrol.googleapis.com serviceusage.googleapis.com

log "CREATING SERVICE ACCOUNT AND ASSIGNING PERMISSIONS"
gcloud projects add-iam-policy-binding ${GOOGLE_PROJECT_ID} \
	--member=serviceAccount:${GOOGLE_PROJECT_NUMBER}-compute@developer.gserviceaccount.com \
	--role=roles/cloudbuild.builds.builder
gcloud iam service-accounts create "${SERVICE_ACCOUNT_NAME}" --display-name="Custom Search API invoker"

ATTEMPTS=0
MAX_ATTEMPTS=10
until gcloud iam service-accounts describe "${SERVICE_ACCOUNT_ID}" &>/dev/null; do
	if [ $ATTEMPTS -ge $MAX_ATTEMPTS ]; then
		echo "Service account ${SERVICE_ACCOUNT_ID} not found after $(($MAX_ATTEMPTS * 2)) seconds"
		exit 1
	fi
	sleep 2
	ATTEMPTS=$((ATTEMPTS + 1))
	echo "Waiting for service account to be created... (attempt ${ATTEMPTS}/${MAX_ATTEMPTS})"
done
gcloud projects add-iam-policy-binding ${GOOGLE_PROJECT_ID} --member=serviceAccount:"${SERVICE_ACCOUNT_ID}" --role=roles/iam.serviceAccountUser

log "DEPLOYING SEARCH FUNCTION"
gcloud functions deploy "${FUNCTION_NAME}" \
	--source search_function \
	--runtime python311 \
	--trigger-http \
	--entry-point custom_search_wrapper \
	--region "${REGION}" \
	--no-allow-unauthenticated \
	--gen2 \
	--set-env-vars=SEARCH_PROVIDER="${SEARCH_PROVIDER}",BRAVE_API_KEY="${BRAVE_API_KEY}",PARALLEL_API_KEY="${PARALLEL_API_KEY}",TAVILY_API_KEY="${TAVILY_API_KEY}"

gcloud functions add-invoker-policy-binding "${FUNCTION_NAME}" --region="${REGION}" --member=serviceAccount:"${SERVICE_ACCOUNT_ID}"

export CLOUD_FUNCTION_URL=$(gcloud functions describe ${FUNCTION_NAME} --region ${REGION} --format='get(url)')
envsubst <api_gateway/openapi-spec.template.yaml >api_gateway/openapi-spec.yaml

log "DEPLOYING API GATEWAY"
gcloud api-gateway apis create "${API_NAME}"

gcloud api-gateway api-configs create v1 \
	--api="${API_NAME}" \
	--openapi-spec=api_gateway/openapi-spec.yaml \
	--backend-auth-service-account="${SERVICE_ACCOUNT_ID}" \
	--display-name="Version 1"

gcloud api-gateway gateways create "${GATEWAY_NAME}" \
	--api="${API_NAME}" \
	--api-config=v1 \
	--location="${REGION}"

GATEWAY_SERVICE_NAME="$(gcloud api-gateway apis describe ${API_NAME} --format='get(managedService)')"
gcloud services enable "${GATEWAY_SERVICE_NAME}"

GATEWAY_URL="$(gcloud api-gateway gateways describe ${GATEWAY_NAME}) --location ${REGION} --format='get(defaultHostname)'"

echo "Your custom search API can be accessed at https://${GATEWAY_URL}/search. Use this as SEARCH_ENDPOINT"
