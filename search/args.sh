#! /usr/bin/env bash

## Parameters - verify and set ALL of the below parameters. Provide at least one API key (for the provider you select)
FUNCTION_NAME="brave_search"
API_NAME="custom-search-gemini-api"
GATEWAY_NAME="custom-search-gateway"
REGION="us-west2"

SEARCH_PROVIDER="brave" # One of "brave", "parallel", "tavily"
BRAVE_API_KEY=""
TAVILY_API_KEY=""
PARALLEL_API_KEY=""
## END Parameters

## DO NOT edit the below!
GOOGLE_PROJECT_ID=$(gcloud config get project)
GOOGLE_PROJECT_NUMBER=$(gcloud projects describe --format='get(projectNumber)' ${GOOGLE_PROJECT_ID})
SERVICE_ACCOUNT_NAME="search-invoker"
SERVICE_ACCOUNT_ID="${SERVICE_ACCOUNT_NAME}@${GOOGLE_PROJECT_ID}.iam.gserviceaccount.com"
