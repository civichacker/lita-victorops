# Copyright 2020 Civic Hacker LLC <opensource@civichacker.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'eventmachine'
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
            @ws.send login.to_json
          end
          @ws.onmessage do |msg, type|
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
                log.info(m)
              end
            end
          end
        end
        robot.trigger(:connected)
      end

      def shut_down
        @ws.close
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
