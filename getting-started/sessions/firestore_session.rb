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
    class FirestoreSession < Abstract::PersistedSecure
      def initialize app, options = {}
        super

        @firestore = Google::Cloud::Firestore.new
        @col = @firestore.col "sessions"
      end

      def find_session _req, session_id
        return [generate_sid, {}] unless valid_session_id? session_id

        snapshot = @col.doc(session_id.private_id).get
        return [generate_sid, {}] unless snapshot.exists?

        [session_id, stringify_keys(snapshot.fields || {})]
      end

      def write_session _req, session_id, new_session, _opts
        session_id = generate_sid unless valid_session_id? session_id
        doc = @col.doc session_id.private_id
        doc.set stringify_keys(new_session)
        session_id
      end

      def delete_session _req, session_id, opts
        if valid_session_id? session_id
          doc = @col.doc session_id.private_id
          doc.delete
        end
        generate_sid unless opts && opts[:drop]
      end

      def valid_session_id? session_id
        session_id.is_a?(SessionId) &&
          session_id.public_id.is_a?(String) &&
          !session_id.public_id.empty?
      end

      def stringify_keys hash
        new_hash = {}
        hash.each do |k, v|
          new_hash[k.to_s] =
            if v.is_a? Hash
              stringify_keys v
            elsif v.is_a? Array
              v.map { |el| el.is_a?(Hash) ? stringify_keys(el) : el }
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
