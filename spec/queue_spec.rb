# -*- coding: utf-8 -*-
require "spec/helper/all"
require 'em-synchrony/queue'
require 'em-synchrony/event'
describe EM::Synchrony::Queue do
  let(:q) { EM::Synchrony::Queue.new }

  it "должна работать" do
    i = 0
    Fiber.new do
      while t = q.pop
        i += t
      end
    end.resume
    q << 1
    i.should == 1
    q << 3
    i.should == 4
  end

  describe EM::Synchrony::JoinableQueue do
    let(:q) { EM::Synchrony::JoinableQueue.new }
    it "Должна дожидаться окончания всех тасков" do
      EM.synchrony do
        i = 0
        Fiber.new do
          while t = q.pop
            EM::Synchrony.sleep(0.1)
            i += t
            q.task_done
          end
        end.resume
        q << 1
        q << 3
        i.should == 0
        q.join
        i.should == 4
        EM.stop
      end
    end
  end
end