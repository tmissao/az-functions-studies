import json
import random
from typing import Dict, Any
from datetime import datetime
from dateutil import parser

class Message:

    def __init__(self, id: int, message: str, date: datetime):
      if id:
        self.id = id
      else:
        self.id = random.randint(0,9)
      self.message = message
      self.date = date

    def __str__(self):
        return (f'Message(id={self.id}, message={self.message}, date={self.date.isoformat()})')

    @classmethod
    def from_json_str(cls, data):
      obj = json.loads(data)
      instance = cls(obj['id'], obj['message'], parser.parse(obj['date']))
      return instance

    def to_json(self):
        obj: Dict[str, Any] = {
          "id": self.id,
          "message": self.message,
          "date": self.date.isoformat()
        }
        return json.dumps(obj)