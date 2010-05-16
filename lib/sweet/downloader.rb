require 'rubygems'
require 'open-uri'
require 'zippy'

class Downloader
  def download_swt(opts = {})
    platform = system_qualifier(opts)
    puts "Downloading SWT #{platform}"

    # TODO support other SWT versions
    open("http://mirrors.ibiblio.org/pub/mirrors/eclipse/eclipse/downloads/drops/R-3.5.2-201002111343/swt-3.5.2-#{platform}.zip") do |remote|
      Zippy.open(remote.path) do |zip|
        File.open(File.join(File.dirname(__FILE__), '../../swt/swt.jar'), 'wb') do |f|
          f.write zip['swt.jar']
        end
      end
    end
  end

  # TODO integrate user input to all feasible platforms
  def system_qualifier(opts = {})
    props = Java.java.lang.System.properties
    os = (opts[:os] || props['os.name']).downcase

    arch = (opts[:arch] || props['os.arch']).downcase
    arch = 'x86' if arch =~ /..86$/

    wish_tk = opts[:tk]
    tk = case os
    when *%w{linux solaris sunos}
      os = 'solaris' if os == 'sunos'
      %w{gtk motif}.member?(wish_tk) ? wish_tk : 'gtk'
    when 'mac os x'
      os = 'macosx'
      arch = nil if arch != 'x86_64'
      %w{carbon cocoa}.member?(wish_tk) ? wish_tk : 'cocoa'
    when 'qnx'
      arch = 'x86'
      'photon'
    when 'aix'
      arch = 'ppc'
      'motif'
    when 'hp-ux'
      os = 'hpux'
      arch = 'ia64_32'
      'motif'
    when 'windows vista'
      os = 'win32'
      arch = 'x86' if wish_tk == 'wpf'
      %w{wpf win32}.member?(wish_tk) ? wish_tk : 'win32'
    when /windows/
      os = 'win32' # returns win32 as tk also
    end

    [tk, os, arch].compact.join('-')
  end
end

if __FILE__ == $0
  Downloader.new.download_swt
end