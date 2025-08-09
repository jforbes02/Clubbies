import logging
from enum import StrEnum

LOG_FORMAT_DEBUG = "%(asctime)s - %(name)s - %(levelname)s - %(message)s - %(lineno)d - %(pathname)s"

class LogLevels(StrEnum):
    info = "INFO"
    warning = "WARN"
    error = "ERROR"
    debug = "DEBUG"


def configure_logging(log_level: str = LogLevels.error):
    log_level = str(log_level).upper() #makes sure its uppercased
    log_levels = [level.value for level in LogLevels] #finds level

    #makes sure its valid log level
    if log_level not in log_levels:
        logging.basicConfig(level=LogLevels.error)
        return

    #unique message for debugging
    if log_level == LogLevels.debug:
        logging.basicConfig(level=log_level, format=LOG_FORMAT_DEBUG)
        return

    logging.basicConfig(level=log_level)