class ByahConfig

  def initialize(config_file='config.txt')
    @config = {}
    if config_file
      update_config(config_file)
    end
  end

  def update_config(config_file)
    File.open(config_file) do |file|
      file.each do |line|
        line_info = line.split(':')
        key = line_info[0]
        value = line_info[1..-1].join('').gsub("\n",'')
        @config[key] = value
      end
    end
  end

  def get(key)
    return @config[key]
  end

end