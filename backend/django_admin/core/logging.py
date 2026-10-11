# core/logging.py
import logging
import json
from contextvars import ContextVar
from datetime import datetime
from typing import Any, Dict

request_id_context: ContextVar[str] = ContextVar('request_id', default='-')


class RequestIDFilter(logging.Filter):
    """Attach the active request ID to every log record."""

    def filter(self, record: logging.LogRecord) -> bool:
        if not getattr(record, 'request_id', None):
            record.request_id = request_id_context.get()
        return True


class StructuredFormatter(logging.Formatter):
    """Format logs as JSON for better ingestion (e.g., ELK, Datadog)."""
    def format(self, record: logging.LogRecord) -> str:
        log_entry: Dict[str, Any] = {
            'timestamp': datetime.utcnow().isoformat(),
            'level': record.levelname,
            'logger': record.name,
            'message': record.getMessage(),
            'module': record.module,
            'function': record.funcName,
            'line': record.lineno,
        }
        if hasattr(record, 'request_id'):
            log_entry['request_id'] = record.request_id
        if record.exc_info:
            log_entry['exception'] = self.formatException(record.exc_info)
        return json.dumps(log_entry)


def get_logger(name: str) -> logging.Logger:
    """Return an existing logger configured by Django settings."""
    return logging.getLogger(name)
