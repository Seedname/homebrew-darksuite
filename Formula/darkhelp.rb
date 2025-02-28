class Darkhelp < Formula
    desc "DarkHelp: C++ helper class for Darknet's C API"
    homepage "https://github.com/stephanecharette/DarkHelp"
    url "https://github.com/stephanecharette/DarkHelp.git"
    version "1.9.6"
    license "MIT"
    head "https://github.com/stephanecharette/DarkHelp.git", branch: "master"
  
    depends_on "cmake" => :build
    depends_on "git" => :build
    depends_on "darknet-hankai"
    depends_on "tclap"
    depends_on "opencv"
  
    def install
      buildsrc = buildpath/"buildsrc"
      cp_r ".", buildsrc
  
      inreplace buildsrc/"CMakeLists.txt", "/opt/darknet/cfg", "#{etc}/darknet/cfg" if File.read(buildsrc/"CMakeLists.txt").include?("/opt/darknet/cfg")
  
      mkdir "build" do
        system "cmake", "-S", buildsrc, "-B", ".",
                        "-DCMAKE_BUILD_TYPE=Release",
                        "-DCMAKE_INSTALL_PREFIX=#{prefix}"
        system "make", "-j#{ENV.make_jobs}"
        system "make", "install"
      end
    end
  
    test do
      system "false"
    end
  end
  