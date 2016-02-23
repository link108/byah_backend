require 'influxdb'

class InfluxdbBridge

  def initialize(config)
    @database = config.get('database')
    @percision = config.get('percision')
    @host = config.get('host')
    @port = config.get('port')
    puts ''
    @influxdb = InfluxDB::Client.new(@database,
                                     {
                                         :host => @host ,
                                         :port => @port
                                     }
    )
    puts ''
  end

  def delete_database
    @influxdb.delete_database(@database)
  end

  def create_database
    @influxdb.create_database(@database)
  end

  def write_to_influx(series, values, tags=nil, timestamp=nil)
    data = [
        {
            :series => series,
            # :values => { :value => cpu },
            # :tags  => { :username => reported_user, :ou => reported_ou}
            :values => values,
            :tags  => tags
        }
    ]
    if timestamp
      data[0][:timestamp] = timestamp
      @influxdb.write_points(data)
    else
      @influxdb.write_points(data, @percision)
    end
  end

  def write_cpu
    series = 'cpu'
    values = {}
  end

  def write_meminfo(memory, timestamp)
    series = 'memory'
    values = {:memoryKB => memory}
    tags = nil
    write_to_influx(series, values, tags, timestamp=timestamp)
  end


  def query_last_n_min(series, timeperiod)
    total = 0
    returned_data = { series => {} }
    query = "select * from #{series} where time > now() - #{timeperiod}"
    @influxdb.query(query) do |name, tags, points|
      points.each do |point|
        returned_data[name][point['time']] = point['memoryKB']
      end
    end
    return returned_data
  end

end
