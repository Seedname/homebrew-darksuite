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
      # Create directories that might be hardcoded in the build
      (prefix/"cfg").mkpath
      (prefix/"data").mkpath
      (prefix/"include").mkpath
      (prefix/"lib").mkpath
      (prefix/"bin").mkpath
  
      # If there's a relative path used in the source, create it
      (buildpath/"cfg").mkpath
      (buildpath/"data").mkpath
  
      mkdir "build" do
        system "cmake", "..",
               "-DCMAKE_BUILD_TYPE=Release",
               "-DCMAKE_INSTALL_PREFIX=#{prefix}",
               "-DGPU=OFF",
               "-DCMAKE_INSTALL_RPATH=#{prefix}/lib",
               "-DINSTALL_BIN_DIR=#{bin}",
               "-DINSTALL_LIB_DIR=#{lib}",
               "-DINSTALL_INCLUDE_DIR=#{include}",
               "-DINSTALL_CFG_DIR=#{prefix}/cfg",
               "-DINSTALL_DATA_DIR=#{prefix}/data"
        
        # Edit any generated files if needed to replace /opt paths
        system "grep", "-r", "/opt", ".", :err => "/dev/null"
        
        system "make", "-j#{ENV.make_jobs}"
        system "make", "install"
      end
  
      # If there are still hardcoded paths after installation
      inreplace Dir["#{bin}/*"], "/opt/darknet/cfg", "#{prefix}/cfg"
      inreplace Dir["#{bin}/*"], "/opt/darknet/data", "#{prefix}/data"
    end
  
    test do
      assert_match "version", shell_output("#{bin}/darknet --version", 2)
    end
  end