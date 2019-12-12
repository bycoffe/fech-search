require 'net/http'
require 'nokogiri'

module Fech

  # Fech::Search is an interface for the FEC's electronic filing search
  # (http://www.fec.gov/finance/disclosure/efile_search.shtml)
  class Search

    # @param [Hash] search_params a hash of parameters to be
    # passed to the search form.
    def initialize(search_params={})
      @search_params = validate_params(make_params(search_params))
      @search_url = 'http://query.nictusa.com/cgi-bin/dcdev/forms/'
      @search_url = 'https://docquery.fec.gov/cgi-bin/forms/'
      @response = search
    end

    # Convert the search parameters passed to @initialize to use
    # the format and keys needed for the form submission.
    # @return [Hash]
    def make_params(search_params)
      {
        'comid' => search_params[:committee_id] || '',
        'name' => search_params[:committee_name] || '',
        'state' => search_params[:state] || '',
        'party' => search_params[:party] || '',
        'type' => search_params[:committee_type] || '',
        'rpttype' => search_params[:report_type] || '',
        'date' => search_params[:date] ? search_params[:date].strftime('%m/%d/%Y') : '',
        'frmtype' => search_params[:form_type] || ''
      }
    end

    def validate_params(params)
      raise ArgumentError, "At least one search parameter must be given" if params.values.all? { |x| x.empty? }
      nonempty_keys = params.select { |k, v| !v.empty? }.keys
      raise ArgumentError, ":committee_id cannot be used with other search parameters" if nonempty_keys.include?("comid") && nonempty_keys.size > 1
      raise ArgumentError, ":form_type must be used with at least one other search parameter" if nonempty_keys.include?("frmtype") && nonempty_keys.size == 1
      params
    end

    # Performs the search of the FEC's electronic filing database.
    def search
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.read_timeout = 5000
      request = Net::HTTP::Post.new(uri.request_uri)
      request.set_form_data(@search_params)
      @response = http.request(request)
    end

    # A parsed URI for the search
    def uri
      uri = URI.parse(@search_url)
    end

    def body
      @response ? @response.body : nil
    end

    # The results page is formatted differently depending
    # on whether the search includes a date. Use the correct
    # method for parsing the results depending on whether
    # a date was used in the search. Will return an array of
    # results if called directly, or will yield the results one
    # by one if a block is passed.
    def results(&block)
      lines = body.split("\n")
      parsing = false
      committee = nil
      parsed_results = []
      lines.each do |line|
        if line.match(/^<TABLE style='border:0;'>$/)
          parsing = true
        end
        next unless parsing
        if line.match(/<td colspan='8'>/)
          committee = parse_committee_line(line)
        end
        if line.match(/>FEC-\d+</)
          merged = parse_filing_line(line).merge(committee)
          search_result = SearchResult.new(merged)
          if block_given?
            yield search_result
          else
            parsed_results << search_result
          end
        end
      end
      parsed_results
    end

    # Parse a line that contains committee information
    def parse_committee_line(line)
      match = line.match(/<A.*?>(?<name>.*?) - (?<id>C\d{8})<\/A/)
      {committee_name: match['name'], committee_id: match['id']}
    end

    # Parse a line that contains a filing
    def parse_filing_line(line)
      doc = Nokogiri::HTML(line)
      cells = doc.css("td").map(&:text)
      fields = [:form_type, :filing_id, :amended_by, :from, :to, :date_filed, :description]
      Hash[fields.zip(cells)]
    end

  end

end
