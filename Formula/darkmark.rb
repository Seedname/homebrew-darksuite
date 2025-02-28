class Darkmark < Formula
    desc "DarkMark: GUI for Darknet and DarkHelp"
    homepage "https://github.com/stephanecharette/DarkMark"
    url "https://github.com/jpfleischer/DarkMark.git"
    version "1.10.18"
    license "MIT"
    head "https://github.com/jpfleischer/DarkMark.git", branch: "master"
  
    depends_on "cmake" => :build
    depends_on "git" => :build
    depends_on "darkhelp"
    depends_on "darknet-hankai"
    depends_on "opencv"
    depends_on "libx11"
    depends_on "freetype"
    depends_on "libxrandr"
    depends_on "libxinerama"
    depends_on "libxcursor"
    depends_on "poppler"
  
    def install
      # Ensure necessary directories exist
      (prefix/"bin").mkpath
      (prefix/"lib").mkpath
      (prefix/"include").mkpath
  
      mkdir "build" do
        system "cmake", "..",
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