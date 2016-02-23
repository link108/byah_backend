require 'mem_info'

require './influxdb_bridge'
require './byah_config'


sec_in_hour = 60 * 60
sec_in_day = sec_in_hour * 24


config = ByahConfig.new()
influxdb = InfluxdbBridge.new(config)
# memInfo = MemInfo.new()


influxdb.delete_database()
influxdb.create_database()


500.times.each do |num|
  if num % 100 == 0
    puts "num: #{num}"
  end
  mock_memory = rand(100)
  mock_time = (Time.now - (sec_in_day / 2) * num).to_i
  influxdb.write_meminfo(mock_memory, mock_time)
end

influxdb.query_last_n_min('memory', '5d')

puts 'seeded database'

