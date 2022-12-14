# frozen_string_literal: true

require 'roda'

module SteamBuddy
  # Web App
  class App < Roda
    plugin :halt
    plugin :all_verbs

    route do |routing| # rubocop:disable Metrics/BlockLength
      response['Content-Type'] = 'application/json'

      # GET /
      routing.root do
        message = "SteamBuddy API v1 at /api/v1/ in #{App.environment} mode"

        result_response = Representer::HttpResponse.new(
          Response::ApiResult.new(status: :ok, message:)
        )

        response.status = result_response.http_status_code
        result_response.to_json
      end

      routing.on 'api/v1' do # rubocop:disable Metrics/BlockLength
        routing.on 'players' do # rubocop:disable Metrics/BlockLength
          routing.on String do |remote_id|
            # GET /players/{remote_id}/
            routing.get do
              result = Service::AddPlayer.new.call(remote_id:)

              if result.failure?
                failed = Representer::HttpResponse.new(result.failure)
                routing.halt failed.http_status_code, failed.to_json
              end

              http_response = Representer::HttpResponse.new(result.value!)
              response.status = http_response.http_status_code
              Representer::Player.new(result.value!.message).to_json
            end

            # POST /players/{remote_id}/
            routing.post do
              result = Service::AddPlayer.new.call(remote_id:)

              if result.failure?
                failed = Representer::HttpResponse.new(result.failure)
                routing.halt failed.http_status_code, failed.to_json
              end

              http_response = Representer::HttpResponse.new(result.value!)
              response.status = http_response.http_status_code
              Representer::Player.new(result.value!.message).to_json
            end
          end

          routing.is do
            # GET /players?list={base64_json_array_of_players_remote_id}
            routing.get do
              list_req = Request::EncodedPlayersList.new(routing.params)
              result = Service::ListPlayers.new.call(list_request: list_req)

              if result.failure?
                failed = Representer::HttpResponse.new(result.failure)
                routing.halt failed.http_status_code, failed.to_json
              end

              http_response = Representer::HttpResponse.new(result.value!)
              response.status = http_response.http_status_code
              Representer::PlayersList.new(result.value!.message).to_json
            end
          end
        end
      end
    end
  end
end
