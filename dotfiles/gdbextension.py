# Python Exception <class 'gdb.error'>: Too few arguments in function call.
# Error occurred in Python: Too few arguments in function call.
import gdb

def lock_GIL(func):
    def wrapper(*args):
        state = gdb.parse_and_eval("PyGILState_Ensure()")
        result = func(*args)
        gdb.parse_and_eval(f"PyGILState_Release({state})")
        return result

    return wrapper


class Py(gdb.Command):
    def __init__(self):
        super(Py, self).__init__ (
            "py",
            gdb.COMMAND_NONE
        )

    @lock_GIL
    def invoke(self, command, from_tty):
        if command[0] in ('"', "'",):
            command = command[1:]
        if command[-1:] in ('"', "'",):
            command = command[:-1]
        cmd_string = f"exec('{command}')"
        gdb.execute(f'call PyRun_SimpleString("{cmd_string}")')


class PyFile(gdb.Command):
    def __init__(self):
        super(PyFile, self).__init__ (
            "pyfile",
            gdb.COMMAND_NONE
        )

    @lock_GIL
    def invoke(self, filename, from_tty):
        cmd_string = f"with open('{filename}') as f: exec(f.read())"
        gdb.execute(f'call PyRun_SimpleString("{cmd_string}")')

Py()
PyFile()

