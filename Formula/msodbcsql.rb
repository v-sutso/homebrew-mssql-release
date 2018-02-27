class Msodbcsql < Formula
  desc "ODBC Driver for Microsoft(R) SQL Server(R)"
  homepage "https://msdn.microsoft.com/en-us/library/mt654048(v=sql.1).aspx"
  url "https://download.microsoft.com/download/1/9/A/19AF548A-6DD3-4B48-88DC-724E9ABCEB9A/msodbcsql-17.0.1.1.tar.gz"
  version "17.0.1.1"
  sha256 "6e7b6e5283adc4f38a2265d1566d70e9bb556fa3d4fa461ba1632f7cfbf6536b"

  option "without-registration", "Don't register the driver in odbcinst.ini"

  def caveats; <<-EOS.undent
    If you installed this formula with the registration option (default), you'll
    need to manually remove [ODBC Driver 17 for SQL Server] section from
    odbcinst.ini after the formula is uninstalled. This can be done by executing
    the following command:
        odbcinst -u -d -n "ODBC Driver 17 for SQL Server"
    EOS
  end

  depends_on "unixodbc"
  depends_on "openssl"

  attr_accessor :var
  
  @@a="n"
  @var="no"

  
  if Formula["msodbcsql13@13.1"].installed?
    #puts "Formula[msodbcsql13@13.1].installed? = #{Formula["msodbcsql13@13.1"].installed?}"
    depends_on "mssql-tools@13" => "with-ENV[ACCEPT_EULA]=Y"
    @@a = "y"
    @var ="yes"
  end 
  link_overwrite "/usr/local/include"    

  resource "mssql-tools14" do
    url "https://go.microsoft.com/fwlink/?linkid=848963"
    sha256 "b31cfe98ff3c8f60a98fd02a1ebbe7cf7a2172320239adccd073ad3870786bf9"
  end
  resource "htmldoc" do
    url "https://downloads.sourceforge.net/project/zsh/zsh-doc/5.4.2/zsh-5.4.2-doc.tar.xz"
    mirror "https://www.zsh.org/pub/zsh-5.4.2-doc.tar.xz"
    sha256 "5229cc93ebe637a07deb5b386b705c37a50f4adfef788b3c0f6647741df4f6bd"
  end


  def check_eula_acceptance
    if ENV["ACCEPT_EULA"] != "y" and ENV["ACCEPT_EULA"] != "Y" then
      puts "The license terms for this product can be downloaded from"
      puts "https://aka.ms/odbc170eula and found in"
      puts "/usr/local/share/doc/msodbcsql/LICENSE.txt . By entering 'YES',"
      puts "you indicate that you accept the license terms."
      puts ""
      while true do
        puts "Do you accept the license terms? (Enter YES or NO)"
        accept_eula = STDIN.gets.chomp
        if accept_eula then
          if accept_eula.upcase == "YES" then
            break
          elsif accept_eula.upcase == "NO" then
            puts "Installation terminated: License terms not accepted."
            return false
          else
            puts "Please enter YES or NO"
          end
        else
        f Formula["msodbcsql13@13.1"].installed?  puts "Installation terminated: Could not prompt for license acceptance."
          puts "If you are performing an unattended installation, you may set"
          puts "ACCEPT_EULA to Y to indicate your acceptance of the license terms."
          return false
        end
      end
    end
    return true
  end

  def install

    puts " Entering def install"

    if build.with? "ENV[ACCEPT_EULA]=Y"
      puts "ENV[ACCEPT_EULA]=Y"
    end

    if !check_eula_acceptance
      return false
    end


    args = %W[
      --prefix=#{prefix}
      --enable-fndir=#{pkgshare}/functions
      --enable-scriptdir=#{pkgshare}/scripts
      --enable-site-fndir=#{HOMEBREW_PREFIX}/share/zsh/site-functions
      --enable-site-scriptdir=#{HOMEBREW_PREFIX}/share/zsh/site-scripts
      --enable-runhelpdir=#{pkgshare}/help
      --enable-cap
      --enable-maildir-support
      --enable-multibyte
      --enable-zsh-secure-free
      --with-tcsetpgrp
    ]
    puts "args = #{args}"


    puts "Prefix = #{prefix.to_s}"
    if File.exist?("/usr/local/include/msodbcsql.h")
      puts "msodbcsql.h exists"
      curTime = Time.now.to_s
      curTime = DateTime.parse(curTime).strftime("%Y-%m-%d_%H-%M-%S")
      oldFileName = "/usr/local/include/msodbcsql.h"
      newFileName = "/usr/local/include/msodbcsql.h." + curTime
      puts "New file name is #{newFileName}"
      File.chmod(0777, "/usr/local/include/msodbcsql.h") rescue nil
      # File.rename(oldFileName,newFileName) 
    end
       

    chmod 0444, "lib/libmsodbcsql.17.dylib"
    chmod 0444, "share/msodbcsql/resources/en_US/msodbcsqlr17.rll"
    chmod 0755, "include/msodbcsql.h"
    chmod 0644, "odbcinst.ini"
    chmod 0644, "share/doc/msodbcsql/LICENSE.txt"
    chmod 0644, "share/doc/msodbcsql/RELEASE_NOTES"

    # bin.install_symlink "#{prefix.to_s}/include/msodbcsql.h" => "/usr/local/include/msodbcsql.h"
    # chmod 0755, "/usr/local/include/msodbcsql.h"
    # bin.install_symlink "include/msodbcsql.h" => "/usr/local/include/msodbcsql.h"
    rm_rf "/usr/local/include/msodbcsql.h"
    #(prefix).install_symlink "include/msodbcsql.h" => "/usr/local/include/msodbcsql.h"     
    #(prefix/"include").install_symlink "msodbcsql.h" => "/usr/local/include/msodbcsql.h"
    (prefix/"include").install_symlink "msodbcsql.h" => "/usr/local/include/msodbcsql.h"
    # (prefix/"share/doc/msodbcsql").install_symlink "LICENSE.txt" => "/usr/local/share/doc/msodbcsql/LICENSE.txt"
    # (prefix/"share/doc/msodbcsql").install_symlink "RELEASE_NOTES" => "/usr/local/share/doc/msodbcsql/RELEASE_NOTES"

#OFT
   
   #puts "a: #{a}"
   
   puts @@a
   puts "var :  #{@var}" 
   
   puts "Version: #{version}"
   puts "Share: #{share}"
   puts "Path: #{path}"
   puts "Bin: #{bin}"
   puts "Formula[msoqbcsql]: #{Formula["v-sutso/mssql-release/msodbcsql"].opt_bin}"
   puts "ENV.cc -MacOS.prefer_64_bit : #{ENV.cc} -m#{MacOS.prefer_64_bit? ? 64 :32}"
   puts "libexec: #{libexec}"
   puts "Man: #{man}"
   puts "Lib: #{lib}"
   puts "Etc: #{etc}"
   #puts "Installed version: #{Formula["v-sutso/mssql-release/msodbcsql13"].installed_version}"
   puts "Installed version: #{Formula["msodbcsql13@13.1"].installed_version}"
   if Formula["msodbcsql13@13.1"].installed?
     puts "Formula[msodbcsql13@13.1].installed? = #{Formula["msodbcsql13@13.1"].installed?}"
     #depends_on "mssql-tools@14@14"
   end   

   puts "buildpath: #{buildpath}"
   #puts "toolprefix: #{toolprefix}"
   puts "name: #{name}"   
   puts "info: #{info}"

   puts "pkgshare: #{pkgshare}"
   puts "HOMEBREW_PREFIX: #{HOMEBREW_PREFIX}"
   # puts "libdir: $(libdir).to_s" 
   # puts "tzsh: $(tzsh).to_s"  
   # puts "VERSION: $(VERSION).to_s"

   #puts "Dir[]: #{Dir["Doc"]}"


    # Do not version installation directories.
    out_file = File.new("Makefile", "w")
    out_file.close

    out_file1 = File.new("Makefile1", "w")
    out_file1.close


    #inreplace ["Makefile", "Makefile1"],
    #  "$(libdir)/$(tzsh)/$(VERSION)", "$(libdir)"
    #puts "Makefile: $(Makefile)"


    puts "Dir[]: #{Dir["Doc"]}"
    File.open("Makefile", "r") do |file|
      while line = file.gets
        puts line
      end
    end



   #puts "f: #{f}"
 
   resources.each { |r| pkgshare.install r }
#OFT

    cp_r ".", "#{prefix}"

    if !build.without? "registration"
        system "odbcinst -u -d -n \"ODBC Driver 17 for SQL Server\""
        system "odbcinst -i -d -f ./odbcinst.ini"
    end
  end
end
