require 'thor'
require 'logger'
require 'pathname'
require 'openssl'
require 'open3'

class Command < Thor
  LOGGER = Logger.new(STDOUT)

  desc 'submit', 'ZIPファイルをsubmitする'
  def submit(submission_url, private_id)
    download_command = "curl -L -s -S -f -o submission.zip #{submission_url} "
		LOGGER.info(download_command)
    system download_command
    unless File.exists?('submission.zip')
			LOGGER.info("submission.zipのダウンロードに失敗")
      exit
		end

    shasum_command = "shasum -a 256 submission.zip"
		LOGGER.info(shasum_command)
    o, e, s = Open3.capture3(shasum_command)
    sha256, filename = o.chomp.split

    submit_command = [
      "curl -L ",
      "--data-urlencode action=submit ",
      "--data-urlencode privateID=#{private_id} ",
      "--data-urlencode submissionURL=#{submission_url} ",
      "--data-urlencode submissionSHA=#{sha256} ",
      "https://script.google.com/macros/s/AKfycbzQ7Etsj7NXCN5thGthCvApancl5vni5SFsb1UoKgZQwTzXlrH7/exec"
    ].join
    LOGGER.info(submit_command)
    o, e, s = Open3.capture3(submit_command)
    LOGGER.info(o)
  end
end
