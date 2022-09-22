import json
import logging
import azure.functions as func
from typing import Dict, Any
from shared.models import Message
from .model import Payload, Response

def run(req: func.HttpRequest, sender: func.Out[str]) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')
    payload: Payload = Payload(req.get_json())
    logging.info(payload)
    message: Message = Message(id = None, message = payload.message, date = payload.date)
    logging.info(message)
    sender.set(message.to_json())

    return func.HttpResponse(
        Response(f'Message: {message} sent with Success').to_json(),
        status_code=200,
        mimetype="application/json",
    )