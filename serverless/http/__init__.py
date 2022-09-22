import logging

import azure.functions as func
from .handler import run

# def parse_json(json):
#     logging.info(json)
#     for key, value in json.items():
#         logging.info(f"key: {key}, value: {value}")



def main(req: func.HttpRequest, sender: func.Out[str]) -> func.HttpResponse:
    return run(req, sender)
