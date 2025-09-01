from abc import ABC, abstractmethod

class SearchService(ABC):
    @abstractmethod
    def search(self, query: str) -> list:
        pass

def get_search_service(name: str) -> SearchService:
    if name == "brave":
        from .brave_search import BraveSearchService
        return BraveSearchService()
    elif name == "parallel":
        from .parallel_search import ParallelSearchService
        return ParallelSearchService()
    elif name == "tavily":
        from .tavily_search import TavilySearchService
        return TavilySearchService()
    else:
        raise ValueError(f"Unknown search service: {name}")
