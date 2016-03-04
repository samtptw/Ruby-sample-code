#使用 zipruby 壓縮
require 'rubygems'
require 'zip'
require "Date"                     #使用Date 為判斷日期   
require 'net/ftp'                  # For FTP                     

Zip.unicode_names = true           #考慮檔名用 unicode 設定
#Zip.default_compression = Zlib::NO_COMPRESSION

FOLDER="e:/workspace/HelloWorld/emma/"                      #CSV檔案所在位置, windows 用 /
FTP_SERVER="127.0.0.1"                                      #FTP server ip or domain name
FTP_USER="sam"                                              #FTP login user
FTP_PWD="1234"                                              #FTP login password
#input_filename ="emma_20160206.csv"                         #CSV 檔名
input_filename = nil

#判斷在所在目錄中CSV檔及 抓CSV檔名
Dir.glob(FOLDER+"*.csv").select do |csv|
  #puts File.file?(csv)
  input_filename = csv.split("/").last
end
  #print input_filename.is_a?(String)


#產生zip檔名規則:   檔名皆須emma_年月日，如(emma_20160205).zip
zip_filename = FOLDER+"emma_#{Date.today.strftime("%Y%m%d")}.zip"        #需要Require Date
  
#產生密碼  :密碼規則為年月日期+99 day
def gpwd
  pwd = Date.today.next_day(99).strftime("%Y%m%d")
end
puts "Password:#{gpwd}"                                           #看密碼是什麼

#Zip 加密在抓到的CSV檔
    buffer = Zip::OutputStream.write_buffer(::StringIO.new(''), Zip::TraditionalEncrypter.new(gpwd)) do |zip|           #zip 內容產生
      zip.put_next_entry(input_filename)                      #設定 Zip中的內容
      #zip.print "Hello World"                                #內容寫入
      zip.print IO.binread(FOLDER+input_filename)              #讀取檔案及寫入進 Stream, in MS Window should change binary mode to read file
    end.string 
    
   
#Zip檔案產生
File.open(zip_filename,"wb:UTF-8") do |outfile|                 #zip file由Stream 產生, in MS Window should change binary mode to write file
    outfile.print(buffer)
end

#FTP 上傳
Net::FTP.open(FTP_SERVER,FTP_USER,FTP_PWD) do |ftp|
  ftp.putbinaryfile(zip_filename)                              #FTP put zip file by binary mode 
end
