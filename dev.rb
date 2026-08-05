require 'webrick'

require_relative 'gen'

RELOAD_SCRIPT = '<script>new EventSource("/system/reload").onmessage=()=>location.reload()</script>'

# Fans builds out to the live-reload connections, one queue each.
class BuildSignal
  def initialize
    @mutex = Mutex.new
    @queues = []
  end

  # Returns a queue yielding one value per build, then nil once stopped.
  def subscribe
    Thread::Queue.new.tap { |queue| @mutex.synchronize { @queues << queue } }
  end

  def unsubscribe(queue)
    @mutex.synchronize { @queues.delete(queue) }
  end

  def bump
    @mutex.synchronize { @queues.each { |queue| queue.push(true) } }
  end

  # Releases the readers so that they don't hold up shutdown.
  def stop
    @mutex.synchronize { @queues.each(&:close) }
  end
end

# Serves public/, splicing the reload listener into every HTML page.
class ReloadingFileHandler < WEBrick::HTTPServlet::FileHandler
  def do_GET(req, res)
    super
    return unless res['content-type'].to_s.start_with?('text/html')

    body = res.body.respond_to?(:read) ? res.body.read : res.body.to_s
    res.body = body.sub('</body>', RELOAD_SCRIPT + '</body>')
    res.content_length = res.body.bytesize
  end
end

# Holds the connection open and sends an event after each build.
class ReloadServlet < WEBrick::HTTPServlet::AbstractServlet
  def initialize(server, signal)
    super(server)
    @signal = signal
  end

  def do_GET(_req, res)
    res['content-type'] = 'text/event-stream'
    res['cache-control'] = 'no-cache'
    res.chunked = true
    queue = @signal.subscribe
    res.body = proc do |out|
      out.write("data: reload\n\n") while queue.pop
    ensure
      @signal.unsubscribe(queue)
    end
  end
end

def mtimes
  paths = Dir.glob('src/**/*') + ['gen.rb'] + Dir.glob('view/**/*')
  paths.select { |path| File.file?(path) }.to_h { |path| [path, File.mtime(path)] }
end

def build
  Gen.build
rescue StandardError => e
  STDERR.puts("failed to build: #{e}")
end

def watch(signal)
  prev = mtimes
  loop do
    sleep 1
    next if (current = mtimes) == prev

    # The generator is loaded into this process, so its own edits need a restart.
    exec(RbConfig.ruby, $0) if current['gen.rb'] != prev['gen.rb']

    build
    signal.bump
    prev = mtimes
  end
end

if __FILE__ == $0
  build

  signal = BuildSignal.new
  Thread.new { watch(signal) }

  server = WEBrick::HTTPServer.new(
    Port: 8000,
    AccessLog: [],
    Logger: WEBrick::Log.new($stderr, WEBrick::Log::WARN)
  )
  server.mount('/', ReloadingFileHandler, 'public')
  server.mount('/system/reload', ReloadServlet, signal)

  # A queue push is one of the few things a trap handler may do; taking a lock
  # is not, and shutting down needs one.
  interrupts = Thread::Queue.new
  trap('INT') { interrupts.push(true) }
  Thread.new do
    interrupts.pop
    signal.stop # shutdown joins the connections, so let them finish first
    server.shutdown
  end

  puts 'Serving at http://localhost:8000'
  server.start
end
