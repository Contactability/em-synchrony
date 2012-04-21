# -*- coding: utf-8 -*-
require "spec/helper/all"
require 'em-synchrony/group'
describe EM::Synchrony::Group do
  let(:group) { EM::Synchrony::Group.new }
  it "должен дожидаться окончания всех тасков" do
    EM.synchrony do
      i = 0
      5.times do        
        Fiber.new do 
          group.add
          EM::Synchrony.sleep(0.1)
          i += 1
          group.done
        end.resume
      end
      group.wait
      i.should == 5
      EM.stop
    end
  end

  it "должен возвращать модифицированный блок" do
    EM.synchrony do
      i = 0
      5.times do
        Fiber.new(&group.with do
          EM::Synchrony.sleep(0.1)
          i += 1
        end).resume
      end
      group.wait
      i.should == 5
      EM.stop
    end
  end

  it "должен корректно работать при отсутсвии ожидаемых" do
    EM.synchrony do
      group.wait
      EM.stop
    end
  end
end