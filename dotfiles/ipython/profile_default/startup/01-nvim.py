import os

NVIM_SERVER_ADDRESS = os.getenv("NVIM", "")
if NVIM_SERVER_ADDRESS:
    try:
        import pynvim

        vim = pynvim.attach("socket", path=NVIM_SERVER_ADDRESS)
    except ModuleNotFoundError:
        pass
