# frozen_string_literal: true

module SteamBuddy
  module Response
    SUCCESS = Set.new(
      %i[ok created processing no_content]
    ).freeze

    FAILURE = Set.new(
      %i[forbidden not_found bad_request conflict cannot_process internal_error processing]
    ).freeze

    CODES = SUCCESS | FAILURE

    ApiResult = Struct.new(:status, :message) do
      def initialize(status:, message:)
        raise(ArgumentError, 'Invalid status') unless CODES.include? status

        super(status, message)
      end
    end
  end
end
