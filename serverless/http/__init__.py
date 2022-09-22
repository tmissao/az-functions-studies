import azure.functions as func
from .handler import run


def main(req: func.HttpRequest, sender: func.Out[str]) -> func.HttpResponse:
    return run(req, sender)
