require 'rack'
require 'erb'

module Rack

  class GoogleAnalytics

    DEFAULT = { :async => true }

    def initialize(app, options = {})
      @app, @options = app, DEFAULT.merge(options)

      # Remove the async options so we only keep the tracking options.
      @async = @options[:async]
      @options.delete :async

      if @async == true
        raise ArgumentError, "Account must be set!" unless @options[:account] and !@options[:account].empty?
      else
        raise ArgumentError, "Tracker must be set!" unless @options[:tracker] and !@options[:tracker].empty?
      end
    end

    def call(env); dup._call(env); end

    def _call(env)
      @status, @headers, @response = @app.call(env)
      return [@status, @headers, @response] unless html?
      response = Rack::Response.new([], @status, @headers)
      @response.each { |fragment| response.write inject(fragment) }
      response.finish
    end

    private

    def html?; @headers['Content-Type'] =~ /html/; end

    def inject(response)
      file = @async ? 'async' : 'sync'
      @template ||= ::ERB.new ::File.read ::File.expand_path("../templates/#{file}.erb",__FILE__)
      if @async
        response.gsub(%r{</head>}, @template.result(binding).gsub(/\n/,'') + "</head>")
      else
        response.gsub(%r{</body>}, @template.result(binding).gsub(/\n/,'') + "</body>")
      end
    end

  end

end
