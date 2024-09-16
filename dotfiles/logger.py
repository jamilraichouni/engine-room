import logging

COLORS = {
    "WARNING": "\033[33m",  # yellow
    "INFO": "\033[32m",  # green
    "DEBUG": "\033[3;90m",  # Italic and dark gray
    "CRITICAL": "\033[1;31m",  # Bold and red
    "ERROR": "\033[31m",  # red
}

RESET_SEQ = "\033[0m"


class ColoredFormatter(logging.Formatter):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

    def format(self, record):
        levelname = record.levelname
        formatted_level_name = levelname
        while len(formatted_level_name) < 8:
            formatted_level_name += " "
        msg = record.msg

        if levelname in COLORS:
            levelname_color = (
                COLORS[levelname] + formatted_level_name + RESET_SEQ
            )
            msg_color = COLORS[levelname] + msg + RESET_SEQ
        else:
            levelname_color = levelname
            msg_color = msg

        record.levelname = levelname_color
        record.msg = msg_color

        return super().format(record)


def setup_logging():
    logger = logging.getLogger()
    ch = logging.StreamHandler()
    formatter = ColoredFormatter(
        "%(asctime)s.%(msecs)03d|%(name)s|%(threadName)-24s|"
        "%(levelname)-8s | %(message)s",
        datefmt="%Y-%m-%d|%H:%M:%S",
    )
    ch.setFormatter(formatter)
    logger.addHandler(ch)


setup_logging()
