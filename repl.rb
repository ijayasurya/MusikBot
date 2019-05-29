module Repl
  class Session
    require 'mysql2'
    require 'httparty'

    def initialize(opts)
      @logging = opts.delete(:log)
      @client = Mysql2::Client.new(opts)
      @db = opts[:db]
      @getter = HTTParty
      @base_uri = 'https://xtools.wmflabs.org/api/user'
    end

    def count_articles_created(username)
      @getter.get(
        "#{@base_uri}/pages_count/#{@db}"
      )['counts']['count']
    end

    def count_namespace_edits(username, namespace = 0)
      @getter.get(
        "#{@base_uri}/namespace_totals/#{@db}/#{username}"
      )['namespace_totals'][namespace]
    end

    def count_nonautomated_edits(username)
      @getter.get(
        "#{@base_uri}/automated_editcount/en.wikipedia.org/#{URI.escape(username.score)}"
      )['nonautomated_editcount']
    end

    def count_nonautomated_namespace_edits(username, namespace)
      @getter.get(
        "#{@base_uri}/automated_editcount/en.wikipedia.org/#{URI.escape(username.score)}/#{namespace}"
      )['nonautomated_editcount']
    end

    def count_tool_edits(username, tool)
      countAutomatedEdits(username, false, tool)
    end

    def query(sql)
      puts sql if @logging
      @client.query(sql)
    end

    def prepare(sql)
      puts sql if @logging
      @client.prepare(sql)
    end

    def escape(string)
      @client.escape(string)
    end

    private

    def count(sql)
      query(sql).first.values[0].to_i
    end
  end
end
