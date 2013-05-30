require 'net/http'

module Fech

  # Fech::Search is an interface for the FEC's electronic filing search
  # (http://www.fec.gov/finance/disclosure/efile_search.shtml)
  class Search

    # @param [Hash] search_params a hash of parameters to be
    # passed to the search form.
    def initialize(search_params={})
      @search_params = validate_params(make_params(search_params))
      @search_url = 'http://query.nictusa.com/cgi-bin/dcdev/forms/'
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
      if @search_params['date'] != ''
        results_from_date_search(&block)
      else
        results_from_nondate_search(&block)
      end
    end

    # Parse the results from a search that does not include a date.
    # Will return an array of results if called directly, or will
    # yield the results one by one if a block is passed.
    def results_from_nondate_search(&block)
      parsed_results = []
      regex = /<DT>(.*?)<P/m
      match = body.match regex
      return [] if match.nil?
      content = match[1]
      committee_sections = content.split(/<DT>/)
      committee_sections.each do |section|
        data = parse_committee_section(section)
        data.each do |result|
          search_result = SearchResult.new(result)

          if block_given?
            yield search_result
          else
            parsed_results << search_result
          end
        end
      end
      block_given? ? nil : parsed_results
    end

    # For results of a search that does not include a date, parse
    # the section giving information on the committee that submitted
    # the filing.
    # @param [String] section
    def parse_committee_section(section)
      data = []
      section.gsub!(/^<BR>/, '')
      rows = section.split(/\n/)
      committee_data = parse_committee_row(rows.first)
      rows[1..-1].each do |row|
        data << committee_data.merge(parse_filing_row(row))
      end
      data
    end

    # Parse the results from a search that includes a date.
    # Will return an array of results if called directly, or will
    # yield the results one by one if a block is passed.
    def results_from_date_search(&block)
      parsed_results = []
      dl = body.match(/<DL>(.*?)<BR><P/m)[0]
      rows = dl.split('<DT>')[1..-1].map { |row| row.split("\n") }
      rows.each do |committee, *filings|
        committee = parse_committee_row(committee)
        filings.each do |filing|
          next if filing == "<BR><P"
          data = committee.merge(parse_filing_row(filing))
          search_result = SearchResult.new(data)
          if block_given?
            yield search_result
          else
            parsed_results << search_result
          end
        end
      end
      block_given? ? nil : parsed_results
    end

    # For results of a search that includes a date, parse
    # the portion of the results with information on the
    # committee that submitted the filing.
    # @param [String] row
    # @return [Hash] the committee name and ID
    def parse_committee_row(row)
      regex = /
              '>
              (.*?)
              \s-\s
              (C\d{8})
              /x
      match = row.match regex
      {:committee_name => match[1], :committee_id => match[2]}
    end

    # Parse a result row with information on the filing itself.
    # @param [String] row
    # @return [Hash] the filing ID, form type, period, date filed, description
    # and, optionally, the filing that amended this filing.
    def parse_filing_row(row)
      regex = /
              FEC-(\d+)
              \s
              Form
              \s
              (F.*?)
              \s\s-\s
              (period\s([-\/\d]+),\s)?
              filed
              \s
              ([\/\d]+)
              \s
              (-\s
               (.*?)
               ($|<BR>.*?FEC-(\d+))
              )?
              /x
      match = row.match regex
      {:filing_id => match[1],
       :form_type => match[2],
       :period => match[4],
       :date_filed => match[5],
       :description => match[7],
       :amended_by => match[9]
      }
    end

  end

end

