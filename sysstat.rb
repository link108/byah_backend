class Sysstat



  def get_cpu()
    raw_cpu_data = %x{sar -P ALL}
    put ''
  end





end


Sysstat.get_cpu()