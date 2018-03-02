class Msodbcsql17AT17005 < Formula
  desc "ODBC Driver for Microsoft(R) SQL Server(R)"
  homepage "https://msdn.microsoft.com/en-us/library/mt654048(v=sql.1).aspx"
  url "http://download.microsoft.com/download/4/9/5/495639C0-79E4-45A7-B65A-B264071C3D9A/msodbcsql-17.0.0.5.tar.gz"
  version "17.0.0.5"
  sha256 "fa20f657332147193af102ca2f239791c51609bba66934463a969472f50f973b"

  option "without-registration", "Don't register the driver in odbcinst.ini"


  keg_only :versioned_formula

  depends_on "unixodbc"
  depends_on "openssl"

  def check_eula_acceptance?
    if ENV["ACCEPT_EULA"] != "y" && ENV["ACCEPT_EULA"] != "Y"
      puts "The license terms for this product can be downloaded from"
      puts "https://aka.ms/odbc170eula and found in"
      puts "/usr/local/share/doc/msodbcsql/LICENSE.txt . By entering 'YES',"
      puts "you indicate that you accept the license terms."
      puts ""
      loop do
        puts "Do you accept the license terms? (Enter YES or NO)"
        accept_eula = STDIN.gets.chomp
        if accept_eula
          if accept_eula.upcase == "YES"
            break
          elsif accept_eula.upcase == "NO"
            puts "Installation terminated: License terms not accepted."
            return false
          else
            puts "Please enter YES or NO"
          end
        else
          puts "Installation terminated: Could not prompt for license acceptance."
          puts "If you are performing an unattended installation, you may set"
          puts "ACCEPT_EULA to Y to indicate your acceptance of the license terms."
          return false
        end
      end
    end
    true
  end

  def install
    return false unless check_eula_acceptance?

    chmod 0444, "lib/libmsodbcsql.17.dylib"
    chmod 0444, "share/msodbcsql17/resources/en_US/msodbcsqlr17.rll"
    chmod 0644, "include/msodbcsql17/msodbcsql.h"
    chmod 0644, "odbcinst.ini"
    chmod 0644, "share/doc/msodbcsql17/LICENSE.txt"
    chmod 0644, "share/doc/msodbcsql17/RELEASE_NOTES"

    if File.directory?("#{HOMEBREW_PREFIX}/share/doc/msodbcsql17")
      (prefix/"share/doc/msodbcsql").install_symlink "LICENSE.txt" => "#{HOMEBREW_PREFIX}/share/doc/msodbcsql17/LICENSE.txt"
      (prefix/"share/doc/msodbcsql").install_symlink "RELEASE_NOTES" => "#{HOMEBREW_PREFIX}/share/doc/msodbcsql17/RELEASE_NOTES"
    end

    cp_r ".", prefix.to_s

    if build.with? "registration"
        system "odbcinst", "-u", "-d", "-n", "\"ODBC Driver 17 for SQL Server\""
        system "odbcinst", "-i", "-d", "-f", "./odbcinst.ini"
    end
  end

  def caveats; <<-EOS.undent
    If you installed this formula with the registration option (default), you'll
    need to manually remove [ODBC Driver 17 for SQL Server] section from
    odbcinst.ini after the formula is uninstalled. This can be done by executing
    the following command:
        odbcinst -u -d -n "ODBC Driver 17 for SQL Server"
    EOS
  end

  test do
    if build.with? "registration"
      out = shell_output("#{Formula["unixodbc"].opt_bin}/odbcinst -q -d")
      assert_match "ODBC Driver 17 for SQL Server", out
    end
  end
end
