module Fech

  # Fech:SearchResult is a class representing a search result
  # from Fech::Search.
  class SearchResult
    attr_reader :committee_name, :committee_id, :filing_id, :form_type, :period, :date_filed, :description, :amended_by

    # @param [Hash] attrs The attributes of the search result.
    def initialize(attrs)
      @date_format = '%m/%d/%Y'

      @committee_name = attrs[:committee_name]
      @committee_id   = attrs[:committee_id]
      @filing_id      = attrs[:filing_id].sub(/FEC-/, '').to_i
      @form_type      = attrs[:form_type]
      @period         = parse_period(attrs[:from], attrs[:to])
      @date_filed     = Date.strptime(attrs[:date_filed], @date_format)
      @description    = attrs[:description]
      @amended_by     = attrs[:amended_by]
    end

    # Parse the strings representing a filing period.
    # @param [String] period a string representing a filing period
    # @return [Hash, nil] a hash representing the start and end
    # of a filing period.
    def parse_period(from, to)
      return unless valid_date(from.to_s) && valid_date(to.to_s)
      from = Date.strptime(from, @date_format)
      to = Date.strptime(to, @date_format)
      {:from => from, :to => to}
    end

    # Check whether a date string is valid
    def valid_date(s)
      s.match(/\d\d?\/\d\d?\/\d{4}/)
    end

    # The Fech filing object for this search result
    # @return [Fech::Filing]
    def filing(opts={})
      Fech::Filing.new(self.filing_id, opts)
    end
  end

end
