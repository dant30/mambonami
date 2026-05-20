from .health import router as health
from .metrics import router as metrics
from .proxy import router as proxy

__all__ = [
    'health',
    'metrics',
    'proxy',
]
