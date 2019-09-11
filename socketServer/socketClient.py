#!/usr/bin/env python
#coding=utf8

import base64
import datetime
import json
import logging
import threading
import time
from collections import defaultdict

import websocket

logger = logging.getLogger('websocket')
logging.basicConfig(level=logging.DEBUG)

TIMER_INTERVAL = 10

# tools
def generate_ts():
    ts = datetime.datetime.now()
    ts = time.strftime("%Y-%m-%d %H:%M:%S")
    return ts

# def keep_alive(ws):
#    def send_heart_beat(ws):
#         ts = generate_ts()
#         logging.info("send heart beats: {}".format(ts))

#     threading.Timer(TIMER_INTERVAL, send_heart_beat, (ws,)).start()

# client callback
def on_open(ws):
    logging.debug(ws)
    logging.info("### socket opened ###")
    # keep_alive()
    ws.send("hello")

    time.sleep(10)

def on_message(ws, message):
    logging.debug(ws)
    logging.info("### socket receive message: {msg} ###".format(message))

def on_error(ws, error):
    logging.debug(ws)
    logging.error("### socket receive error: {} ###".format(error))

def on_close(ws):
    logging.debug(ws)
    logging.info("### socket closed ###")


def on_data(ws, data_str, data_type, continue_flag):
    '''
    callback object which is called when a message received.
          This is called before on_message or on_cont_message,
          and then on_message or on_cont_message is called.
          on_data has 4 argument.
          The 1st argument is this class object.
          The 2nd argument is utf-8 string which we get from the server.
          The 3rd argument is data type. ABNF.OPCODE_TEXT or ABNF.OPCODE_BINARY will be came.
          The 4th argument is continue flag. if 0, the data continue
    '''
    logging.debug(ws)
    logging.info(
        "### socket on_data: {str} , data type: {type}, continue flag: {flag} ###".format(str=data_str, type=data_type,
                                                                                          flag=continue_flag))

def main():
    '''
    program entrance
    '''
    websocket.enableTrace(True)
    ws = websocket.WebSocketApp("ws://127.0.0.1:8888",
                                # on_message=on_message,
                                on_error=on_error,
                                on_close=on_close,
                                on_data=on_data,
                                on_open=on_open)
    ws.run_forever(ping_interval=10,
                    ping_timeout=5)

if __name__ == "__main__":
    main()
