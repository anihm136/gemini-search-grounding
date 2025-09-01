import os
import requests
from .search import SearchService

class BraveSearchService(SearchService):
    def __init__(self):
        self.api_key = os.getenv("BRAVE_API_KEY")
        if not self.api_key:
            raise ValueError("BRAVE_API_KEY environment variable is not set.")
        self.search_url = "https://api.search.brave.com/res/v1/web/search"

    def search(self, query: str) -> list:
        headers = {
            "Accept": "application/json",
            "X-Subscription-Token": self.api_key,
        }

        params = {"q": query, "count": "5"}
        resp = requests.get(self.search_url, headers=headers, params=params, timeout=10)
        resp.raise_for_status()
        data = resp.json()

        results = []
        if "web" in data and "results" in data["web"]:
            for item in data["web"]["results"]:
                results.append(
                    {
                        "url": item.get("url", ""),
                        "snippet": item.get("description", ""),
                    }
                )
        return results
