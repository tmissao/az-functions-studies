import logging

import azure.functions as func
from shared.models import Message


def run(msg: func.ServiceBusMessage):
    message:Message = Message.from_json_str(msg.get_body().decode('utf-8'))
    logging.info(f'Message {message} processed')