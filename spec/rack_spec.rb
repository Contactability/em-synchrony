# -*- coding: utf-8 -*-
require "spec/helper/all"
require 'em-synchrony'
require 'em-synchrony/rack'


require 'rack/lobster'
describe EM::Synchrony do
  let(:app) do
    Rack::Builder.new do
      use Rack::CommonLogger
      map "/lobster" do
        use Rack::Lint
        use Rack::ContentLength
        run Rack::Lobster.new
      end
    end
  end
  # it "должен иметь синхронный интерфейс, но использовать AIO" do
  #   EM.synchrony do
  #     EM::Synchrony::Rack.run app, host: '127.0.0.1', port: 3000
  #     res = EM::HttpRequest.new('http://127.0.0.1:3000/lobster').get
  #     res.response.should match(/Lobstericious/)
  #     EM.stop
  #   end
  # end

end

