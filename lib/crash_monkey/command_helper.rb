module UIAutoMonkey
  module CommandHelper
    require 'open3'

    def shell(cmds)
      puts "Shell: #{cmds.inspect}"
      Open3.popen3(*cmds) do |stdin, stdout, stderr|
        stdin.close
        return stdout.read
      end
    end

    # def run_process(cmds)
    #   puts "Run: #{cmds.inspect}"
    #   Kernel.system(cmds[0], *cmds[1..-1])
    # end

    def relaunch_app(device,app)
      `idevicedebug -u #{device} run #{app} >/dev/null 2>&1 &`
    end

    def run_process(cmds)
      puts "Run: #{cmds.inspect}"
      device = cmds[2]
      app = cmds[-7]
      Open3.popen3(*cmds) do |stdin, stdout, stderr, thread|
        @tmpline = ""
        t = Thread.start{
          sleep 30
          while true
            current_line = @tmpline
            sleep 20
            after_sleep_line = @tmpline
            if current_line == after_sleep_line
              puts "App has hanged! Re-Launch it!"
              relaunch_app(device, app)
            end
          end
        }
        stdin.close
        stdout.each do |line|
          @tmpline = line
          puts line
        end
        t.kill
      end
    end

    def kill_all(process_name, signal=nil)
      signal = signal ? "-#{signal}" : ''
      # puts "killall #{signal} #{process_name}"
      Kernel.system("killall #{signal} '#{process_name}' >/dev/null 2>&1")
    end

    def xcode_path
      @xcode_path ||= shell(%w(xcode-select -print-path)).strip
    end

  end
end
