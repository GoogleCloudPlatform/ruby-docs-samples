# Copyright 2019, Google LLC.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# [START getting_started_session]
require "google/cloud/firestore"
require "rack/session/abstract/id"

module Rack
  module Session
    class FirestoreSession < Abstract::Persisted
      def initialize app, options = {}
        super

        @firestore = Google::Cloud::Firestore.new
        @col = @firestore.col "sessions"
      end

      def find_session _req, session_id
        return [generate_sid, {}] if session_id.nil?

        doc = @col.doc session_id
        fields = doc.get.fields || {}
        [session_id, stringify_keys(fields)]
      end

      def write_session _req, session_id, new_session, _opts
        doc = @col.doc session_id
        doc.set new_session, merge: true
        session_id
      end

      def delete_session _req, session_id, _opts
        doc = @col.doc session_id
        doc.delete
        generate_sid
      end

      def stringify_keys hash
        new_hash = {}
        hash.each do |k, v|
          new_hash[k.to_s] =
            if v.is_a? Hash
              stringify_keys v
            else
              v
            end
        end
        new_hash
      end
    end
  end
end
# [END getting_started_session]
