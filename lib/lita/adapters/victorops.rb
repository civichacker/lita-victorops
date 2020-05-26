require 'eventmachine'
require "em-eventsource"
require "websocket"
require 'net/http'
require 'websocket-eventmachine-client'
require 'securerandom'
require 'json'


module Lita
  module Adapters
    class Victorops < Adapter

      config :token, type: String, required: true

      def initialize(robot)
        super
      end

      def run
        EventMachine.run do
          @ws = WebSocket::EventMachine::Client.connect(:uri => 'wss://chat.victorops.com/chat')
          @ws.onopen do
            log.info("opened #{config.token}")
            # m = login
            # log.info("sending: #{m.to_json}")
            @ws.send login.to_json
            # @ws.send send_messages('', "connected!")
          end
          @ws.onmessage do |msg, type|
            # log.info("Received message: #{msg}")
            header, payload = msg.split(/\n/)
            m = JSON.parse(payload)
						log.info(payload)
            if m['MESSAGE'] == 'CHAT_NOTIFY_MESSAGE'
              if m['PAYLOAD']['CHAT']['TEXT'].start_with?("@bo")
                chat = m['PAYLOAD']['CHAT']
                command = chat['TEXT']
								u = Lita::User.create(chat['USER_ID'])
                if command.downcase == '@bo ping'
                  log.info("#{chat['USER_ID']} said \"#{chat['TEXT']}\"")
                  send_messages("", "PONG")
                elsif command.downcase == '@bo kill'
                  send_messages("", "Exiting")
                  shut_down
                else
                  log.info("#{chat['USER_ID']} said \"#{chat['TEXT']}\"")
                  source = Source.new(user: u, room: chat['ROOM_ID'])
                  message = Lita::Message.new(robot, command.downcase, source)
									log.info(command)
                  robot.receive(message)
                end
              else
              #  chat = m['PAYLOAD']['CHAT']
                log.info(m)
              end
            end
            # @ws.send message
            # shut_down
          end
        end
        robot.trigger(:connected)
      end

      def shut_down
        @ws.close
        log.info("closed")
        EM.stop if EM.reactor_running?
      end

      def part(room_id)
      end

      def join(room_id)
      end

      def build_message(message)
        m = {
          "MESSAGE": "CHAT_ACTION_MESSAGE",
            "TRANSACTION_ID": generate_uuid,
            "PAYLOAD": {
              "CHAT": {
                "IS_ONCALL": false,
                "IS_ROBOT": true,
                "TEXT": message,
                "ROOM_ID": "*"
              }
            }
        }
        "VO-MESSAGE: #{m.to_json.length}\n" + m.to_json
      end


      def send_messages(target, messages)
				if messages.kind_of?(Array)
					@ws.send build_message(messages.join("\n"))
				else
					@ws.send build_message(messages)
				end
      end

      private

      def generate_uuid
        SecureRandom.uuid
      end

      def login
        {
          "MESSAGE": "ROBOT_LOGIN_REQUEST_MESSAGE",
          "TRANSACTION_ID": generate_uuid,
          "PAYLOAD": {
            "PROTOCOL": "1.0",
            "NAME": "bo",
            "KEY": config.token,
            "DEVICE_NAME": "hubot"
          }
        }
      end

      def log
        Lita.logger
      end

      def stream_url
        "wss://chat.victorops.com/chat"
      end

      def http
          @http ||= EventMachine::HttpRequest.new(
            stream_url,
            keepalive: true,
            connect_timeout: 0,
            inactivity_timeout: 0,
          )
      end

      def start_request
        http.get(
          head: {
            'Accept' => 'application/json',
            'Authorization' => "Bearer #{config.token}",
          }
        )
      end

    end
    Lita.register_adapter(:victorops, Victorops)
  end
end
