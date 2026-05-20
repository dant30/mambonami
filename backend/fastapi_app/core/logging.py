# backend/fastapi_app/core/logging.py
import logging
import sys
from loguru import logger

class InterceptHandler(logging.Handler):
    def emit(self, record):
        logger_opt = logger.opt(depth=6, exception=record.exc_info)
        logger_opt.log(record.levelno, record.getMessage())


def setup_logging():
    # Remove default loguru handler
    logger.remove()
    # Add JSON format for production, pretty for development
    log_format = "{time:YYYY-MM-DD HH:mm:ss.SSS} | {level: <8} | {name} | {message}"
    logger.add(sys.stderr, format=log_format, level="INFO")
    # Intercept standard logging
    logging.basicConfig(handlers=[InterceptHandler()], level=0, force=True)
