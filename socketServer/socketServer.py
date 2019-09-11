#!/usr/bin/env python
#coding=utf8

import logging
import tornado.escape
import tornado.ioloop
import tornado.options
import tornado.web
import tornado.websocket

from tornado.options import define, options

define("port", default=8888, help="run on the given port", type=int)

class SocketServer(tornado.web.Application):
    def __init__(self):
        
        handlers = [(r"/", SocketServerHandler)]
        settings = dict(
            cookie_secret="__TODO:_GENERATE_YOUR_OWN_RANDOM_VALUE_HERE__",
            # template_path=os.path.join(os.path.dirname(__file__), "templates"),
            # static_path=os.path.join(os.path.dirname(__file__), "static"),
            xsrf_cookies=True,
            websocket_ping_interval = 10,
            websocket_ping_timeout = 30
        )
        super(SocketServer, self).__init__(handlers, **settings)

class SocketServerHandler(tornado.websocket.WebSocketHandler):
    def open(self):
        print("socket open")

    def on_close(self):
        print("socket on close")

    def on_message(self, message):
        print("got message %r", message)
        self.write_message(message)
        
def main():
    tornado.options.parse_command_line()
    server = SocketServer()
    server.listen(options.port)
    tornado.ioloop.IOLoop.current().start()

if __name__ == "__main__":
    main()
