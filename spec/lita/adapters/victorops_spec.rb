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

require "spec_helper"

describe Lita::Adapters::Victorops, lita: true do

  def with_websocket(subject, queue)
    thread = Thread.new { subject.run() }
    thread.abort_on_exception = true
    yield queue.pop
    subject.shut_down
    thread.join
  end

  let(:robot) { Lita::Robot.new(registry) }
  subject { described_class.new(robot) }
  let(:token) { '1234567890abcdef1234567890abcdef12345678' }
  let(:queue) { Queue.new }

  before do
    registry.register_adapter(:victorops, described_class)
    registry.config.adapters.victorops.token = token
  end

  it 'registers with Lita' do
    expect(Lita.adapters[:victorops]).to eql(described_class)
  end

end
