class DarknetHankai < Formula
    desc "Darknet: neural network framework for object detection (CPU-only build)"
    homepage "https://github.com/hank-ai/darknet"
    url "https://github.com/hank-ai/darknet.git"
    version "3.0"
    license "Apache-2.0"
    head "https://github.com/hank-ai/darknet.git", branch: "master"
  
    depends_on "cmake" => :build
    depends_on "git" => :build
    depends_on "opencv"
  
    def install
      # Create directories that might be needed
      (prefix/"cfg").mkpath
      (prefix/"data").mkpath
      
      # Patch CMakeLists.txt and other files to prevent installation to /opt
      # Find all files that might contain hardcoded /opt paths
      files_to_patch = Dir["**/*{.cmake,.txt,.cpp,.c,.h}"]
      
      files_to_patch.each do |file|
        next unless File.file?(file) && File.read(file).include?("/opt/darknet")
        
        inreplace file, "/opt/darknet", prefix.to_s do |s|
          puts "Patched hardcoded path in #{file}" if verbose?
        end
      end
      
      # Special handling for CMakeLists.txt to ensure proper installation paths
      if File.exist?("CMakeLists.txt") && File.read("CMakeLists.txt").include?("install")
        inreplace "CMakeLists.txt" do |s|
          # Add or modify variables for installation directories
          if s.match?(/set\s*\(\s*INSTALL_[A-Z_]+_DIR/)
            # Already has installation variables, make sure they're using our prefix
            s.gsub!(/set\s*\(\s*INSTALL_BIN_DIR.*?\)/, "set(INSTALL_BIN_DIR \"${CMAKE_INSTALL_PREFIX}/bin\")")
            s.gsub!(/set\s*\(\s*INSTALL_LIB_DIR.*?\)/, "set(INSTALL_LIB_DIR \"${CMAKE_INSTALL_PREFIX}/lib\")")
            s.gsub!(/set\s*\(\s*INSTALL_INCLUDE_DIR.*?\)/, "set(INSTALL_INCLUDE_DIR \"${CMAKE_INSTALL_PREFIX}/include\")")
            s.gsub!(/set\s*\(\s*INSTALL_CFG_DIR.*?\)/, "set(INSTALL_CFG_DIR \"${CMAKE_INSTALL_PREFIX}/cfg\")")
            s.gsub!(/set\s*\(\s*INSTALL_DATA_DIR.*?\)/, "set(INSTALL_DATA_DIR \"${CMAKE_INSTALL_PREFIX}/data\")")
          else
            # Add installation variables at the beginning
            install_vars = <<~EOS
              # Installation directories (added by Homebrew)
              set(INSTALL_BIN_DIR "${CMAKE_INSTALL_PREFIX}/bin")
              set(INSTALL_LIB_DIR "${CMAKE_INSTALL_PREFIX}/lib")
              set(INSTALL_INCLUDE_DIR "${CMAKE_INSTALL_PREFIX}/include")
              set(INSTALL_CFG_DIR "${CMAKE_INSTALL_PREFIX}/cfg")
              set(INSTALL_DATA_DIR "${CMAKE_INSTALL_PREFIX}/data")
            EOS
            s.sub!(/cmake_minimum_required.*?\n/m, "\\0\n#{install_vars}\n")
          end
          
          # Fix any install commands to use our variables
          s.gsub!(/install\s*\(\s*DIRECTORY\s+.*?cfg.*?DESTINATION\s+.*?\)/) do |match|
            "install(DIRECTORY cfg/ DESTINATION ${INSTALL_CFG_DIR})"
          end
          s.gsub!(/install\s*\(\s*DIRECTORY\s+.*?data.*?DESTINATION\s+.*?\)/) do |match|
            "install(DIRECTORY data/ DESTINATION ${INSTALL_DATA_DIR})"
          end
        end
      end
      
      # Also check for installation scripts and patch them
      if File.exist?("install.sh")
        inreplace "install.sh", "/opt/darknet", prefix.to_s
      end
  
      # Build Darknet
      mkdir "build" do
        system "cmake", "..",
               "-DCMAKE_BUILD_TYPE=Release",
               "-DCMAKE_INSTALL_PREFIX=#{prefix}",
               "-DGPU=OFF",
               "-DINSTALL_BIN_DIR=#{bin}",
               "-DINSTALL_LIB_DIR=#{lib}",
               "-DINSTALL_INCLUDE_DIR=#{include}",
               "-DINSTALL_CFG_DIR=#{prefix}/cfg",
               "-DINSTALL_DATA_DIR=#{prefix}/data"
        
        system "make", "-j#{ENV.make_jobs}"
        
        # Install manually if needed
        if File.exist?("src/darknet")
          bin.install "src/darknet"
        end
        
        if Dir.exist?("../cfg")
          (prefix/"cfg").install Dir["../cfg/*"]
        end
        
        if Dir.exist?("../data")
          (prefix/"data").install Dir["../data/*"]
        end
        
        # Try the regular install as well
        system "make", "install"
      end
  
      # Final check for any binaries that might still have hardcoded paths
      bin.find do |path|
        if path.file? && path.executable?
          inreplace path, "/opt/darknet", prefix.to_s if File.read(path).include?("/opt/darknet")
        end
      end
    end
  
    test do
      system "#{bin}/darknet", "--version"
    rescue
      # Some versions might not support --version flag
      system "#{bin}/darknet"
    end
  end