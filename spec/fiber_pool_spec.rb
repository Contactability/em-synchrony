# -*- coding: utf-8 -*-
require "spec/helper/all"
require 'em-synchrony/fiber_pool'
describe EM::Synchrony::FiberPool do
  let(:fp) { EM::Synchrony::FiberPool.new }

  describe "waitall" do
    it "должен дожаться выполнения всех задач" do
      EM.synchrony do
        foo = 0
        fp.spawn do
          EM::Synchrony.sleep(0.1)
          foo += 1
        end
        fp.spawn do
          EM::Synchrony.sleep(0.1)
          foo += 1
        end
        fp.waitall
        foo.should == 2
        EM.stop
      end
    end
  end

  describe "execute" do
    it "должен дожидаться результата выполнения" do
      EM.synchrony do
        res = fp.execute do
          EM::Synchrony.sleep(0.1)
          :foo
        end
        res.should == :foo
        EM.stop
      end
    end

    it "должен работать, если в блоке не было Fiber.yield" do
      EM.synchrony do
        res = fp.execute do
          :foo
        end
        res.should == :foo
        EM.stop
      end
    end
  end

  describe "fp_iterate" do
    it "должен запускать блок на всех объектак в файбер-пуле" do
      EM.synchrony do
        fp = EM::Synchrony::FiberPool.new 2
        i = 0
        fp.iterate([1, 2, 3]) do |v|
          EM::Synchrony.sleep(0.1)
          i += v
        end
        i.should == 6
        EM.stop
      end
    end
  end
end