#!/usr/bin/env python
#coding=utf8

import logging
import tornado.escape
import tornado.ioloop
import tornado.options
import tornado.web
import tornado.websocket
import uuid
import json

from tornado.options import define, options

define("port", default=8888, help="run on the given port", type=int)

class SocketServer(tornado.web.Application):
    def __init__(self):
        
        handlers = [(r"/", SocketServerHandler)]
        settings = dict(
            # template_path=os.path.join(os.path.dirname(__file__), "templates"),
            # static_path=os.path.join(os.path.dirname(__file__), "static"),
            xsrf_cookies=True,
            websocket_ping_interval = 10,
            websocket_ping_timeout = 30
        )
        super(SocketServer, self).__init__(handlers, **settings)

class SocketServerHandler(tornado.websocket.WebSocketHandler):
    waiters = set()
    cache = []
    cache_size = 200

    @classmethod
    def update_cache(cls, chat):
        cls.cache.append(chat)
        if len(cls.cache) > cls.cache_size:
            cls.cache = cls.cache[-cls.cache_size :]

    @classmethod
    def send_updates(cls, chat):
        logging.info("sending message to %d waiters", len(cls.waiters))
        for waiter in cls.waiters:
            try:
                waiter.write_message(chat)
            except:
                logging.error("Error sending message", exc_info=True)

    def open(self):
        logging.info("socket open")
        SocketServerHandler.waiters.add(self)
        logging.info(SocketServerHandler.cache)
        cache_str = json.dumps(SocketServerHandler.cache)
        self.write_message(cache_str)

    def on_close(self):
        logging.info("socket on close")
        SocketServerHandler.waiters.remove(self)

    def on_message(self, message):
        logging.info("got message %r", message)
        parsed = tornado.escape.json_decode(message)
        chat = {"id": str(uuid.uuid4()), "body": parsed["body"]}
        SocketServerHandler.update_cache(chat)
        SocketServerHandler.send_updates(chat)
        

def main():
    tornado.options.parse_command_line()
    server = SocketServer()
    server.listen(options.port)
    tornado.ioloop.IOLoop.current().start()

if __name__ == "__main__":
    main()
