import functions_framework
import json
import os
from flask import jsonify
from .search import get_search_service


@functions_framework.http
def custom_search_wrapper(request):
    """
    HTTP Cloud Function to provide a minimal, fixed response for Gemini grounding.
    """
    if request.method != "POST":
        return "Only POST requests are accepted", 405

    request_json = request.get_json(silent=True)

    if not request_json or "query" not in request_json:
        return (
            jsonify(
                {"error": "Invalid request. JSON body with 'query' field is required."}
            ),
            400,
        )

    user_query = request_json["query"]

    search_provider = os.getenv("SEARCH_PROVIDER", "brave")
    search_service = get_search_service(search_provider)
    results = search_service.search(user_query)

    return jsonify(results)
