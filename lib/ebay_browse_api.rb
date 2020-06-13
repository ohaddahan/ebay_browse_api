# frozen_string_literal: true
require "ebay_browse_api/version"
require 'date'
require 'typhoeus'
require 'base64'
require 'oj'


module EbayBrowseApi
  class Error < StandardError; end
  # Your code goes here...
  class EbayBrowseApiClient
    attr_reader :ru_name, :client_id, :secret_id, :ebay_marketplace_id, :enc, :get_access_token_headers
    attr_reader :get_access_token_body, :get_access_token_options, :access_token, :search_headers, :search_options
    attr_reader :search_filter_params, :get_access_token_resp, :get_access_token_json, :search_resp, :search_json
    attr_reader :init_time, :expires_in, :expire_date

    class << self
      attr_reader :get_access_token_url, :search_url

      def parse_json(json, **kwargs)
        begin
          ( json.is_a?(String) && !json.empty? ) ? hash = Oj.load(json, **kwargs) : hash = {}
        rescue Oj::ParseError
          hash = {}
        end
        hash
      end

      def date_time(year: nil, month: nil, day: nil, diff_year: 0, diff_month: 0, diff_day: 0)
        now = DateTime.now
        DateTime.new((year || now.year) - diff_year,
                     (month || now.month) - diff_month,
                     (day || now.day) - diff_day).
          strftime("%Y-%m-%dT00:00:00Z")
      end
    end

    @get_access_token_url = 'https://api.ebay.com/identity/v1/oauth2/token'
    @search_url = 'https://api.ebay.com/buy/browse/v1/item_summary/search'


    def initialize(
      ru_name: ENV["RU_NAME"],
      client_id: ENV["CLIENT_ID"],
      secret_id: ENV["SECRET_ID"],
      ebay_marketplace_id: "EBAY_US"
    )
      @init_time = nil
      @expires_in = nil
      @expire_date = nil
      @ru_name = ru_name
      @client_id = client_id
      @secret_id = secret_id
      @ebay_marketplace_id = ebay_marketplace_id
      @enc = Base64.encode64("#{@client_id}:#{@secret_id}").gsub(/\n/,'')
      @search_filter_params = {}
      @access_token = nil
      @get_access_token_resp = nil
      @get_access_token_json = nil
      @search_resp = nil
      @search_json = nil
    end

    def clear_search_params
      @search_filter_params.clear
    end

    def prepare_get_access_token
      @get_access_token_headers = {
        'Content-Type' => 'application/x-www-form-urlencoded',
        'Accept' => 'application/json',
        'Accept-Charset' => 'utf-8',
        'Authorization' => "Basic #{@enc}",
        'X-EBAY-C-MARKETPLACE-ID' => @ebay_marketplace_id,
      }
      @get_access_token_body = "grant_type=client_credentials&redirect_uri=#{@ru_name}&scope=https://api.ebay.com/oauth/api_scope"
      @get_access_token_options = {
        headers: @get_access_token_headers,
        followlocation: true,
        body: @get_access_token_body
      }
    end

    def get_access_token
      prepare_get_access_token
      @init_time = DateTime.now
      @get_access_token_resp = Typhoeus::Request.post(EbayBrowseApiClient.get_access_token_url, @get_access_token_options)
      @get_access_token_json = EbayBrowseApiClient.parse_json(@get_access_token_resp.response_body)
      @expires_in = @get_access_token_json.fetch('expires_in',nil).to_i
      @expire_date = @init_time + @expires_in
      @access_token = @get_access_token_json.fetch('access_token',nil)
    end

    def prepare_search
      @search_headers = {
        'Accept' => 'application/json',
        'Accept-Charset' => 'utf-8',
        'Authorization' => "Bearer #{@access_token}",
        'X-EBAY-C-MARKETPLACE-ID' => @ebay_marketplace_id,
        'Content-Type' => 'application/json'
      }
    end

    def add_search_param(param_name, param_value)
      @search_filter_params[param_name] ||= String.new
      @search_filter_params[param_name] << "#{param_value}"
    end

    def add_search_param_filter(param_name, param_value)
      @search_filter_params[:filter] ||= String.new
      @search_filter_params[:filter] << "&" unless @search_filter_params[:filter].empty?
      @search_filter_params[:filter] << "#{param_name}:#{param_value}"
    end

    def run_search(params = nil)
      prepare_search
      @search_filter_params = params unless params.nil?
      @search_options = {
        headers: @search_headers,
        followlocation: true,
        params: @search_filter_params
      }
      @search_resp = Typhoeus::Request.get(EbayBrowseApiClient.search_url, @search_options)
      @search_json = EbayBrowseApiClient.parse_json(@search_resp.response_body)
    end
  end
end
