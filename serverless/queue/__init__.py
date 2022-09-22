import azure.functions as func
from .handler import run


def main(msg: func.ServiceBusMessage):
    run(msg)
