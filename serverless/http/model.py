import json
import os
from typing import Dict, Any
from dateutil import parser

class Payload:

    def __init__(self, json: Dict[str, Any]):
      self.message = json['message']
      self.date = parser.parse(json['date'])
      if json['error']:
        raise ValueError('Throw makes it go boom!')

    def __str__(self):
        return f"Payload: message={self.message}, date={self.date.isoformat()}"


class Response:

    def __init__(self, message: str):
      self.success = True
      self.message = message
      self.env1 = os.environ["ENV1"]
      self.env2 = os.environ["ENV2"]
      self.secret1 = os.environ["MYSECRET1"]
      self.secret2 = os.environ["MYSECRET2"]

    def __str__(self):
        return (f'Response(success={self.success}, message={self.message}, '
                f'env1={self.env1}, env2={self.env2} '
                f'secret1={self.secret1}, secret2={self.secret2})')

    def to_json(self):
        obj: Dict[str, Any] = {
          "success": self.success,
          "message": self.message,
          "env1": self.env1,
          "env2": self.env2,
          "secret1": self.secret1,
          "secret2": self.secret2,
        }
        return json.dumps(obj)