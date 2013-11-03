#!/usr/bin/env ruby

class AutoRetry
  def initialize
    @pattern = []
  end

  def method_missing(name, *args, &block)
    begin
      if @runindex == @pattern.size
        ret = @obj.send name, *args, &block
        @pattern << {ret: ret, name: name, args: args, block: block}
        @runindex += 1
        return ret
      else
        # assert name == @pattern[name]
        ret = @pattern[@runindex][:ret]
        @runindex += 1
        return ret
      end
    rescue => e
      # TODO log that something happened
      raise e
    end
  end

  def self.run(obj, &block)
    AutoRetry.new.run(obj, &block)
  end

  def run(obj, &block)
    @obj = obj
    start &block
  end

  def start(&block)
    @runindex = 0
    begin
      yield self
    rescue => e
      start &block
    end
  end
end

class Unreliable
  def say(x)
    puts x
  end
  def roulette
    puts 'take a spin...'
    if Random.rand(5) != 0
      raise RuntimeError.new "you lost the draw"
    end
  end
end

Random.srand

def main
  foo = Unreliable.new
  
  AutoRetry.run(foo) do |foo|
    foo.say('Starting')
    foo.roulette
    foo.say('one')
    foo.roulette
    foo.say('two')
    foo.roulette
    foo.say('Done')
  end
end

main
