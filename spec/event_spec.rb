# -*- coding: utf-8 -*-
require "spec/helper/all"
require 'em-synchrony/event'
describe EM::Synchrony::Event do
  let(:e) { EM::Synchrony::Event.new }
  it "Должен ожидать ивента во всех файберах" do
    i = 0
    5.times do
      Fiber.new { e.wait; i += 1}.resume
    end
    i.should == 0
    e.set
    i.should == 5
  end

  it "Должен корректно отрабатывать, если ожидание было выставлено после срабатывания ивента" do
    e.set(:ok)
    e.wait.should == :ok
  end
end