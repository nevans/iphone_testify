require 'fileutils'

module IphoneTestify
  
  module Setup
    SKELETONDIR = GEMDIR + "/skeleton"
    extend FileUtils
    def self.setup
      cp_r "#{SKELETONDIR}/.", "."
      mv 'gitignore', '.gitignore', :force=>true
      mkdir_p "UnitTests"
    end
  end
end