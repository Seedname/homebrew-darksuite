class DarknetHankai < Formula
    desc "Darknet: neural network framework for object detection (CPU-only build)"
    homepage "https://github.com/hank-ai/darknet"
    url "https://github.com/hank-ai/darknet.git"
    version "3.0"
    sha256 :no_check
    license "Apache-2.0"
    head "https://github.com/hank-ai/darknet.git", branch: "master"
  
    depends_on "cmake" => :build
    depends_on "git" => :build
    depends_on "opencv"
  
    def install
      inreplace "Makefile", "/opt/darknet/cfg", "#{etc}/darknet/cfg"
  
      mkdir "build" do
        system "cmake", "..",
                        "-DCMAKE_BUILD_TYPE=Release",
                        "-DCMAKE_INSTALL_PREFIX=#{prefix}",
                        "-DGPU=OFF"  # CPU-only build
        system "make", "-j#{ENV.make_jobs}"
        system "make", "install"
      end
    end
  
    test do
      assert_match "version", shell_output("#{bin}/darknet --version", 2)
    end
  end
  