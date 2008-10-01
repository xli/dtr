# Copyright (c) 2007-2008 Li Xiao
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

module DTR
  module FileService
    CHUNK_SIZE=(16 * 1024)
    CODEBASE_FILENAME = 'dtr_codebase.zip'
    
    def send_file(path, socket)
      File.open(path, "rb") do |f|
        while chunk = f.read(CHUNK_SIZE) and chunk.length > 0
          socket.write(chunk)
        end
      end
    end

    def request_file(host, port)
      request = TCPSocket::new(host, port)
      begin
        request.write("GET CODEBASE")
        File.open("copy_#{CODEBASE_FILENAME}", 'w') do |f|
          while chunk = request.readpartial(CHUNK_SIZE) and chunk.length > 0
            f.syswrite(chunk)
          end
        end
      rescue EOFError,Errno::ECONNRESET,Errno::EPIPE,Errno::EINVAL,Errno::EBADF
      ensure
        request.close rescue nil
      end
    end

    def start_server(port)
      @server = TCPServer::new("0.0.0.0", port)
      @acceptor = Thread.new do
        begin
          loop do
            begin
              request = @server.accept
              Thread.start(request) {|request| process_request(request) }
            rescue Errno::ECONNABORTED
              # request closed the socket even before accept
              request.close rescue nil
            rescue Exception => e
              DTR.error("#{Time.now.httpdate}: Unhandled listen loop exception #{e.message}.")
              DTR.error(e.backtrace.join("\n"))
            end
          end
        ensure
          @server.close
        end
      end
    end

    def process_request(request)
      send_file(CODEBASE_FILENAME, request)
    rescue EOFError,Errno::ECONNRESET,Errno::EPIPE,Errno::EINVAL,Errno::EBADF
    rescue Exception => e
      DTR.error("Unhandled exception while processing request: #{e.message}.")
      DTR.error(e.backtrace.join("\n"))
    ensure
      request.close rescue nil
    end
  end
end
