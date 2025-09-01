import os
import requests
from .search import SearchService

class TavilySearchService(SearchService):
    def __init__(self):
        self.api_key = os.getenv("TAVILY_API_KEY")
        if not self.api_key:
            raise ValueError("TAVILY_API_KEY environment variable is not set.")
        self.search_url = "https://api.tavily.com/search"

    def search(self, query: str) -> list:
        headers = {
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json",
        }

        data = {
            "query": query,
            "search_depth": "basic",
            "max_results": 5,
        }

        resp = requests.post(self.search_url, headers=headers, json=data, timeout=10)
        resp.raise_for_status()
        search_results = resp.json()

        results = []
        if "results" in search_results:
            for item in search_results["results"]:
                results.append(
                    {
                        "url": item.get("url", ""),
                        "snippet": item.get("content", ""),
                    }
                )
        return results
