from google import genai
from google.genai import types

SEARCH_ENDPOINT = ""
SEARCH_API_KEY = ""


def main():
    client = genai.Client(vertexai=True, project="gp-search-grounding", location="us-west1")
    custom_search_tool = types.Tool(
        retrieval=types.Retrieval(
            external_api=types.ExternalApi(
                api_spec=types.ApiSpec.SIMPLE_SEARCH,
                endpoint=SEARCH_ENDPOINT,
                api_auth=types.ApiAuth(
                    api_key_config=types.ApiAuthApiKeyConfig(
                        api_key_string=SEARCH_API_KEY
                    )
                ),
            )
        )
    )

    res = client.models.generate_content(
        model="gemini-2.5-pro",
        contents="What are the latest updates in HR policy in India in the last two weeks?",
        config=types.GenerateContentConfig(tools=[custom_search_tool]),
    )

    print(res.text)


if __name__ == "__main__":
    main()
