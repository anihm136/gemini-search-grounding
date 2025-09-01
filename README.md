# Grounded Generation with Custom Search

This example demonstrates how to use the Gemini API with a custom search provider to ground generation results.

## How to Run

First, clone the repository. This example will be easiest to run on the [Google Cloud Shell](https://cloud.google.com/shell/docs)
```
git clone https://github.com/anihm136/gemini-search-grounding.git
```

### 1. Deploy the Search Service

The `search` directory contains a simple search service that can be deployed to Google Cloud. This service uses a third-party search provider (e.g., Brave) to perform searches.

To deploy the service, first open `search/args.sh` in your editor and set the appropriate parameter values. Then, run the deploy script:

```bash
cd search
./deploy.sh
```

This script will:

1.  Enable the necessary Google Cloud services.
2.  Create a service account and assign permissions.
3.  Deploy a Cloud Function that wraps the search provider.
4.  Deploy an API Gateway to expose the Cloud Function as a protected API.

To create an API key to access your new search API, follow the instructions [here](https://cloud.google.com/vertex-ai/generative-ai/docs/grounding/grounding-with-your-search-api#set-up-search-api-endpoint:~:text=dev/v0/search-,Create%20and%20restrict%20an%20API%20Key,-%3A%20You%20must%20create)

At the end of the script, it will output the `SEARCH_ENDPOINT` value. You will need this value in the next step.

### 2. Run the Example

The `main.py` script shows how to use the custom search service with the Gemini API.

Before running the script, you need to update the following variables in `main.py` with the values from the previous step:

-   `SEARCH_ENDPOINT`: The URL of the API Gateway
-   `SEARCH_API_KEY`: The API key you created

Once you have updated the variables, you can run the script:

```bash
uv sync
. .venv/bin/activate
python main.py
```

This will send a request to the Gemini API, which will use the custom search service to ground the generation results.
