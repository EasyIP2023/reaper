require 'darkshadow/reap/constants'
require 'optparse'

module Bash
  class Options
    def self.parse(args)
      options = {}
      parser = OptionParser.new do |opt|
        opt.banner = "Usage: #{DARK_SHADOW} #{log_me(D_WARNING, EXEC)} [options]\nExample: #{DARK_SHADOW} #{log_me(D_WARNING, EXEC)} -l d\n\t #{DARK_SHADOW} #{log_me(D_WARNING, EXEC)} --sf \"test\\ folder/\""
        opt.separator ''
        opt.separator 'Options:'

        opt.on('-s', '--sudo', 'Execute with sudo permissions') do
          options[:sudo] = true
        end

        opt.on('--install-peda', 'Install the Python Exploit Development Assistance for GDB') do
          options[:peda] = true
        end

        opt.on('--shred file1,file2,file3', Array, 'shred a file wiping bits to zero') do |f|
          options[:file]  = f.map(&:to_s)
          options[:shred] = true
        end

        opt.on('--sf "<folder name>"', String, 'shred files in folder wiping bits to zero (Be sure to add "<folder>")') do |folder|
          options[:folder]       = folder
          options[:shred_folder] = true
        end

        opt.on('-l <(e/d) enable/disable ASLR>', String, 'Setting Linux into a vulnerable state by temp disabling ASLR') do |ed|
          options[:vuln]    = true
          options[:enable]  = %w[e enable].include?(ed) ? true : false
          options[:disable] = %w[d disable].include?(ed) ? true : false
        end

        opt.on_tail('-h', '--help', 'Show this message') do
          $stdout.puts opt
          exit
        end
      end

      parser.parse!(args)

      raise OptionParser::MissingArgument, "No options set, try #{DARK_SHADOW} #{log_me(D_WARNING, EXEC)} -h for usage" if options.empty?

      options
    end
  end

  class Driver
    def initialize
      @opts = Options.parse(ARGV)
    rescue OptionParser::ParseError => e
      warn "[x] #{e.message}"
      exit
    end

    def run
      if @opts[:shred]
        @opts[:file].each { |f| `#{'sudo' if @opts[:sudo]} shred -n 30 -uvz #{f}` }
      elsif @opts[:shred_folder]
        `#{'sudo' if @opts[:sudo]} find #{@opts[:folder]} -type f -exec shred -n 30 -uvz {} \\;`
        `#{'sudo' if @opts[:sudo]} rm -rfv #{@opts[:folder]}`
      elsif @opts[:peda]
        `git clone https://github.com/longld/peda.git ~/peda && echo "source ~/peda/peda.py" >> ~/.gdbinit && echo "DONE! debug your program with gdb and enjoy"` unless File.exist?('~/peda/peda.py')
      elsif @opts[:vuln]
        if @opts[:disable]
          # Temporarily disable ASLR && Allow ptrace processes
          `sudo sysctl -w kernel.randomize_va_space=0 && sudo sysctl -w kernel.yama.ptrace_scope=0`
          puts 'Temporarily disabled linux Adress Space Layout Randomization(ASLR)...'
          puts 'Allowing ptrace processes...'
        end
        if @opts[:enable]
          `sudo sysctl -w kernel.randomize_va_space=2 && sudo sysctl -w kernel.yama.ptrace_scope=1`
          puts 'Enabled Linux Adress Space Layout Randomization(ASLR)...'
          puts 'Reset ptrace processes...'
        end
      end
    end
  end
end

@driver = Bash::Driver.new
begin
  @driver.run
rescue ::StandardError => e
  warn "[x] #{e.class}: #{e.message}"
end
