# -*- coding: utf-8 -*-
require "spec/helper/all"
require 'em-synchrony/zmq'

describe ZMQ::Socket do
  it "должен иметь синхронный интерфейс, но использовать AIO" do
    EM.synchrony do
      ctx = ZMQ::Context.new
      rep = ctx.socket(ZMQ::REP)
      req = ctx.socket(ZMQ::REQ)
      rep.bind('inproc://test')
      req.connect('inproc://test')

      Fiber.new do
        str = ''
        rep.recv_string(str)
        str.should == 'hello'
        EM.stop
      end.resume

      EM::Synchrony.sleep 0.1
      req.send_string 'hello'
    end
  end

end

