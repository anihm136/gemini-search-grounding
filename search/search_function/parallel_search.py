import os
import requests
from .search import SearchService


class ParallelSearchService(SearchService):
    def __init__(self):
        self.api_key = os.getenv("PARALLEL_API_KEY")
        if not self.api_key:
            raise ValueError("PARALLEL_API_KEY environment variable is not set.")
        self.search_url = "https://api.parallel.ai/v1beta/search"

    def search(self, query: str) -> list:
        headers = {
            "x-api-key": self.api_key,
            "Content-Type": "application/json",
            "processor": "base",
            "max_results": 5,
            "max_chars_per_result": 6000,
        }

        data = {
            "search_queries": [query],
        }

        resp = requests.post(self.search_url, headers=headers, json=data, timeout=15)
        resp.raise_for_status()
        search_results = resp.json()

        results = []
        if "results" in search_results:
            for item in search_results["results"]:
                results.append(
                    {
                        "url": item.get("url", ""),
                        "snippet": "\n\n".join(item.get("excerpts", [""])),
                    }
                )
        return results
