# -*- coding: utf-8 -*-
require "spec/helper/all"
require 'em-synchrony/local'
require 'em-synchrony/group'

describe EM::Synchrony::Local do
  it "должен создавать файбер-локальный объект" do
    EM.synchrony do
      g = EM::Synchrony::Group.new
      l = EM::Synchrony::Local.new
      l.number = 42
      res = []
      Fiber.new do
        g.add
        l.number = 10
        EM::Synchrony.sleep(0.01)
        res << l.number
        g.done
      end.resume

      Fiber.new do
        g.add        
        EM::Synchrony.sleep(0.01)
        l.number = 12
        res << l.number
        g.done
      end.resume
      g.wait
      res << l.number
      res.reduce(0, &:+).should == 64
      EM.stop
    end
  end
end