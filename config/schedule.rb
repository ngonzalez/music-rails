# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

HLS_FOLDER = "/tmp/hls"

every 10.hours do
  command "find #{HLS_FOLDER} -atime +10h -print0 | xargs -0 rm"
end