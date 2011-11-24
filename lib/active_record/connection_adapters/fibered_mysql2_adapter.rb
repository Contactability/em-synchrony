# encoding: utf-8

require 'active_record/connection_adapters/abstract_adapter'
require 'active_record/connection_adapters/mysql2_adapter'

module ActiveRecord
  class Base
    def self.fibered_mysql2_connection(config)
      client = EM::Synchrony::ConnectionPool.new(size: config[:real_pool]) do
        Mysql2::EM::Client.new(config.symbolize_keys)
      end
      options = [config[:host], config[:username], config[:password], config[:database], config[:port], config[:socket], 0]
      ConnectionAdapters::Mysql2Adapter.new(client, logger, options, config)
    end
  end
end
