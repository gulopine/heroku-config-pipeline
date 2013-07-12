# manage config variables using pipelines
#
class Heroku::Command::Config

  DOWNSTREAM_APP = "DOWNSTREAM_APP"

  # config:diff
  #
  # compare the config of this app to its downstream app
  #
  def diff
    downstream_app, config_vars = split_config_vars(app)
    verify_downstream! downstream_app

    print_and_flush "Comparing #{app} to #{downstream_app}..."

    downstream_vars = api.get_config_vars(downstream_app).body
    differences = diff_config(config_vars, downstream_vars)

    if differences.empty?
      display "no differences"
    else
      display "#{differences.size} config vars are different"

      # Generate a format string using the size of the longest key
      format = "%%-%ds %%s" % (differences.map{|key, a, b| key.size}.max + 2)

      differences.each do |key, a, b|
        unless b.nil?
          # Key and value as they appear in the downstream app
          display format % ["-#{key}:", b]
        end
        unless a.nil?
          # Key and value as they appear in the current app
          display format % ["+#{key}:", a]
        end
      end
    end
  end

  # pipeline:promote
  #
  # promote the current config of this app to its downstream app
  #
  def promote
    downstream_app, config_vars = split_config_vars(app)
    verify_downstream! downstream_app

    unless args.size > 0
      error("Usage: heroku config:promote KEY1 [KEY2 ...]\nMust specify at least one KEY to promote.")
    end

    # Make sure all the arguments match real config vars
    invalid_keys = args.reject{|a| config_vars.keys.include? a}
    unless invalid_keys.empty?
      error("Unknown config vars: #{invalid_keys.join(', ')}")
    end

    # Set the config vars on the downstream app using config:set
    set_args = format_args config_vars.to_a.select{|k, v| args.include? k}
    command = Heroku::Command::Config.new(set_args, :app => downstream_app)
    command.set
  end

  protected

  def verify_downstream!(downstream_app)
    if downstream_app.nil?
      raise Heroku::Command::CommandFailed, "Downstream app not specified. Use `heroku pipeline:add DOWNSTREAM_APP` to add one."
    end
  end

  def split_config_vars(app)
    config_vars = api.get_config_vars(app).body
    downstream_app = config_vars.delete DOWNSTREAM_APP
    [downstream_app, config_vars]
  end

  def diff_config(a, b)
    a.keys.inject([]) do |memo, key|
      unless a[key] == b[key]
        memo << [key, a[key], b[key]]
      end
      memo.sort
    end
  end

  def format_args(config_vars)
    config_vars.map{|k, v| "#{k}=#{v}"}
  end

  def print_and_flush(str)
    print str
    $stdout.flush
  end

end
