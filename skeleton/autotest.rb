SIMULATOR_VERSION = "3.0"
class String
  attr_accessor :colour
  RESET="\e[00;m"

  def coloured(colour = nil)
    colour||=@colour
    "#{colour_code(colour)}#{self}#{RESET}"
  end

  private 
  def colour_code colour
    case colour
    when :red : "\e[01;31m"
    when :green : "\e[01;32m"
    end
  end
end

module AutoTest
  def self.test_and_report
    failure_line = test
    report failure_line   
  end
  
  def self.report failure_line
    if failure_line
      notice = ['Fail', failure_line.chomp]
    else
      notice = ['Pass']
    end
    AutoTest::growl *notice
    puts failure_line.coloured if failure_line
    notice    
  end
  
  def self.run_test
    puts "Build: #{Time::now}"
    output = `xcodebuild -target "Unit Test" -configuration Debug -sdk iphonesimulator#{SIMULATOR_VERSION} 2>&1`
    failure_line = nil
    output.each do |line|
      if line =~ /error:|^Executed.*(\d+) failures|Undefined symbols|PurpleSystemEventPort|FAILED|Segmentation fault/
        if $1.nil? || $1.to_i > 0
          failure_line||= line
          line.colour = :red
        else
          line.colour = :green
        end
      end
      print line.coloured unless line =~/Merge mismatch|setenv/
    end
    failure_line
  end
  
  def self.unable_to_run_test
    "Unable to run tests as the simulator is already running"
  end
  
  def self.simulator_running?
    !`ps -AO command`.split("\n").grep(/iPhoneSimulator.platform\/Developer\/Applications\/iPhone Simulator\.app/).empty?
  end
  
  def self.test
    if simulator_running?
      unable_to_run_test
    else
      run_test
    end
  end

  def self.growl title, msg =""
    img = "~/.autotest_images/#{title.downcase}.png"
    `growlnotify -H localhost -n autotest --image #{img} -p 0 -m #{msg.inspect} #{title}` 
  end

end
