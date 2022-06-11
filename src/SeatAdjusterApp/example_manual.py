import logging

import sys
from opentelemetry import trace
from opentelemetry.sdk.resources import Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.instrumentation.logging import LoggingInstrumentor

class ContextFilter(logging.Filter):
    """
    This is a filter which injects contextual information into the log.
    """
    def filter(self, record):
        record.otelTraceID = trace.get_current_span().get_span_context().trace_id
        record.otelSpanID = trace.get_current_span().get_span_context().span_id
        record.otelServiceName = sys.argv[0]
        return True



provider = TracerProvider()
trace.set_tracer_provider(provider)
tracer = trace.get_tracer(__name__)

logging.basicConfig(format="%(asctime)s %(levelname)s [%(name)s] [%(filename)s:%(lineno)d] [trace_id=%(otelTraceID)s span_id=%(otelSpanID)s resource.service.name=%(otelServiceName)s] - %(message)s")
logging.getLogger().setLevel("INFO")
logger = logging.getLogger(__name__)
logger.addFilter(ContextFilter())

logger.info("NO TRACING")

with tracer.start_as_current_span("foo") as sp:
    logger.info("Jackdaws love my big sphinx of quartz.")

with tracer.start_as_current_span("foo2"): 
    logger.info("test2")