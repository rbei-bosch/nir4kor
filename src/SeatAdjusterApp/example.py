import logging

from opentelemetry import trace
from opentelemetry.sdk.resources import Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.instrumentation.logging import LoggingInstrumentor

LoggingInstrumentor().instrument(set_logging_format=True)
provider = TracerProvider()
trace.set_tracer_provider(provider)
tracer = trace.get_tracer(__name__)
logger = logging.getLogger(__name__)

logger.info("NO TRACING")

with tracer.start_as_current_span("foo"):
    logger.info("Jackdaws love my big sphinx of quartz.")
    
with tracer.start_as_current_span("foo2"): 
    logger.info("test2")