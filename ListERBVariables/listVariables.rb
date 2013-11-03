require 'erb'
require 'ostruct'
require 'set'

class AbsorbingObject
  def method_missing(method, *args)
    self
  end

  def to_s
    ''
  end
end

class Namespace
  attr_accessor :vars

  def initialize
    @vars = Set.new
  end

  def method_missing(method, *args, &block)
    @vars.add(method)
    if block_given?
      yield
    end
    AbsorbingObject.new
  end

  def get_binding
    binding
  end
end
simple_template = File.new(ARGV[0], 'r').read

ns = Namespace.new
ERB.new(simple_template).result(ns.get_binding)
ns.vars.each {|x| puts x}

